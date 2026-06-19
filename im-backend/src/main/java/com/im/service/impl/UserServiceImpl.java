package com.im.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.im.dto.LoginRequest;
import com.im.dto.QRCodeLoginVO;
import com.im.dto.QRCodeStatusVO;
import com.im.dto.RegisterRequest;
import com.im.dto.Result;
import com.im.entity.User;
import com.im.enums.ResultCode;
import com.im.mapper.UserMapper;
import com.im.service.UserService;
import com.im.utils.JwtUtil;
import com.im.utils.RedisUtil;
import com.im.vo.LoginVO;
import com.im.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Base64;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;
    private final RedisUtil redisUtil;

    private static final String USER_CACHE_KEY = "user:info:";
    private static final String USER_ONLINE_KEY = "user:online:";
    private static final String QR_CODE_KEY = "qrcode:login:";
    private static final String QR_CODE_USER_KEY = "qrcode:user:";
    private static final int QR_CODE_EXPIRE_MINUTES = 5;

    @Override
    public Result<LoginVO> register(RegisterRequest request) {
        // 检查用户名是否已存在
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername());
        if (userMapper.selectCount(wrapper) > 0) {
            return Result.failed(ResultCode.USERNAME_EXISTS);
        }

        // 检查用户ID是否已存在
        LambdaQueryWrapper<User> codeWrapper = new LambdaQueryWrapper<>();
        codeWrapper.eq(User::getUserCode, request.getUserCode());
        if (userMapper.selectCount(codeWrapper) > 0) {
            return Result.failed(ResultCode.USERCODE_EXISTS);
        }

        // 创建用户
        User user = new User();
        user.setUsername(request.getUsername());
        user.setUserCode(request.getUserCode());
        user.setPassword(request.getPassword()); // 实际项目中需要加密
        user.setNickname(request.getNickname() != null ? request.getNickname() : "用户" + request.getUsername());
        user.setAvatar(request.getAvatar());
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        userMapper.insert(user);

        // 生成Token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());

        // 缓存用户信息
        UserVO userVO = convertToUserVO(user);
        redisUtil.set(USER_CACHE_KEY + user.getId(), userVO, 30, TimeUnit.MINUTES);

        return Result.success(new LoginVO(token, userVO));
    }

    @Override
    public Result<LoginVO> login(LoginRequest request) {
        // 查询用户
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, request.getUsername());
        User user = userMapper.selectOne(wrapper);

        if (user == null) {
            return Result.failed(ResultCode.USER_NOT_FOUND);
        }

        // 验证密码
        if (!user.getPassword().equals(request.getPassword())) {
            return Result.failed(ResultCode.PASSWORD_ERROR);
        }

        // 更新登录信息
        user.setLastLoginTime(LocalDateTime.now());
        user.setStatus(1);
        userMapper.updateById(user);

        // 生成Token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());

        // 缓存用户信息
        UserVO userVO = convertToUserVO(user);
        redisUtil.set(USER_CACHE_KEY + user.getId(), userVO, 30, TimeUnit.MINUTES);

        // 设置在线状态
        redisUtil.set(USER_ONLINE_KEY + user.getId(), 1, 5, TimeUnit.MINUTES);

        return Result.success(new LoginVO(token, userVO));
    }

    @Override
    public Result<UserVO> getUserInfo(Long userId) {
        // 先从缓存获取
        Object cached = redisUtil.get(USER_CACHE_KEY + userId);
        if (cached instanceof UserVO) {
            return Result.success((UserVO) cached);
        }

        // 从数据库获取
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.failed(ResultCode.USER_NOT_FOUND);
        }

        UserVO userVO = convertToUserVO(user);
        redisUtil.set(USER_CACHE_KEY + userId, userVO, 30, TimeUnit.MINUTES);

        return Result.success(userVO);
    }

    @Override
    public Result<UserVO> updateUser(Long userId, UserVO userVO) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.failed(ResultCode.USER_NOT_FOUND);
        }

        if (userVO.getNickname() != null) {
            user.setNickname(userVO.getNickname());
        }
        if (userVO.getAvatar() != null) {
            user.setAvatar(userVO.getAvatar());
        }
        if (userVO.getSignature() != null) {
            user.setSignature(userVO.getSignature());
        }
        if (userVO.getStatus() != null) {
            user.setStatus(userVO.getStatus());
        }
        user.setUpdateTime(LocalDateTime.now());

        userMapper.updateById(user);

        // 更新缓存
        UserVO updatedVO = convertToUserVO(user);
        redisUtil.set(USER_CACHE_KEY + userId, updatedVO, 30, TimeUnit.MINUTES);

        return Result.success(updatedVO);
    }

    @Override
    public Result<Void> updateStatus(Long userId, Integer status) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.failed(ResultCode.USER_NOT_FOUND);
        }

        user.setStatus(status);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);

        // 更新缓存
        redisUtil.delete(USER_CACHE_KEY + userId);

        return Result.success();
    }

    @Override
    public UserVO getUserVOById(Long userId) {
        // 先从缓存获取
        Object cached = redisUtil.get(USER_CACHE_KEY + userId);
        if (cached instanceof UserVO) {
            return (UserVO) cached;
        }

        User user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }

        UserVO userVO = convertToUserVO(user);
        redisUtil.set(USER_CACHE_KEY + userId, userVO, 30, TimeUnit.MINUTES);

        return userVO;
    }

    private UserVO convertToUserVO(User user) {
        UserVO vo = new UserVO();
        BeanUtil.copyProperties(user, vo);
        return vo;
    }

    @Override
    public Result<QRCodeLoginVO> generateQRCode() {
        // 生成唯一的二维码token
        String qrToken = IdUtil.fastSimpleUUID();

        // 存储到Redis，状态为0（待扫描）
        redisUtil.set(QR_CODE_KEY + qrToken, 0, QR_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

        // 生成二维码内容
        String qrContent = "im_app://login?token=" + qrToken;

        return Result.success(new QRCodeLoginVO(qrToken, qrContent, QR_CODE_EXPIRE_MINUTES * 60));
    }

    @Override
    public Result<Void> confirmQRCodeScan(Long userId, String qrToken) {
        // 检查二维码是否存在
        Object status = redisUtil.get(QR_CODE_KEY + qrToken);
        if (status == null) {
            return Result.failed(ResultCode.QR_CODE_EXPIRED);
        }

        // 更新二维码状态为已确认
        redisUtil.set(QR_CODE_KEY + qrToken, 2, QR_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

        // 生成Token
        User user = userMapper.selectById(userId);
        if (user == null) {
            return Result.failed(ResultCode.USER_NOT_FOUND);
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        UserVO userVO = convertToUserVO(user);

        // 存储登录信息
        LoginVO loginVO = new LoginVO(token, userVO);
        redisUtil.set(QR_CODE_USER_KEY + qrToken, loginVO, QR_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);

        return Result.success();
    }

    @Override
    public Result<QRCodeStatusVO> checkQRCodeStatus(String qrToken) {
        Object status = redisUtil.get(QR_CODE_KEY + qrToken);

        if (status == null) {
            return Result.success(new QRCodeStatusVO(3, "二维码已过期", null, null));
        }

        int statusCode = Integer.parseInt(status.toString());

        switch (statusCode) {
            case 0:
                return Result.success(new QRCodeStatusVO(0, "待扫描", null, null));
            case 1:
                return Result.success(new QRCodeStatusVO(1, "已扫描，等待确认", null, null));
            case 2:
                // 已确认，获取登录信息
                Object loginObj = redisUtil.get(QR_CODE_USER_KEY + qrToken);
                if (loginObj instanceof LoginVO) {
                    LoginVO loginVO = (LoginVO) loginObj;
                    // 清理Redis中的临时数据
                    redisUtil.delete(QR_CODE_KEY + qrToken);
                    redisUtil.delete(QR_CODE_USER_KEY + qrToken);
                    return Result.success(new QRCodeStatusVO(2, "登录成功", loginVO.getToken(), loginVO.getUserInfo()));
                }
                return Result.success(new QRCodeStatusVO(2, "登录成功", null, null));
            default:
                return Result.success(new QRCodeStatusVO(3, "未知状态", null, null));
        }
    }

    private String generateQRCodeBase64(String content) {
        // 简化实现：返回内容的Base64编码
        // 实际项目中应使用ZXing等库生成真正的二维码图片
        return Base64.getEncoder().encodeToString(content.getBytes());
    }
}
