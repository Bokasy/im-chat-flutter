package com.im.service;

import com.im.dto.LoginRequest;
import com.im.dto.QRCodeLoginVO;
import com.im.dto.QRCodeStatusVO;
import com.im.dto.RegisterRequest;
import com.im.dto.Result;
import com.im.vo.LoginVO;
import com.im.vo.UserVO;

public interface UserService {

    /**
     * 用户注册
     */
    Result<LoginVO> register(RegisterRequest request);

    /**
     * 用户登录
     */
    Result<LoginVO> login(LoginRequest request);

    /**
     * 获取用户信息
     */
    Result<UserVO> getUserInfo(Long userId);

    /**
     * 更新用户信息
     */
    Result<UserVO> updateUser(Long userId, UserVO userVO);

    /**
     * 更新在线状态
     */
    Result<Void> updateStatus(Long userId, Integer status);

    /**
     * 根据ID获取用户VO
     */
    UserVO getUserVOById(Long userId);

    /**
     * 生成扫码登录二维码
     */
    Result<QRCodeLoginVO> generateQRCode();

    /**
     * 手机端确认扫码登录
     */
    Result<Void> confirmQRCodeScan(Long userId, String qrToken);

    /**
     * Web端轮询二维码状态
     */
    Result<QRCodeStatusVO> checkQRCodeStatus(String qrToken);
}
