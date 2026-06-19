package com.im.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.im.dto.Result;
import com.im.entity.Friend;
import com.im.entity.FriendApply;
import com.im.entity.User;
import com.im.enums.ResultCode;
import com.im.mapper.FriendApplyMapper;
import com.im.mapper.FriendMapper;
import com.im.mapper.UserMapper;
import com.im.service.FriendService;
import com.im.utils.RedisUtil;
import com.im.vo.FriendApplyVO;
import com.im.vo.UserVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendMapper friendMapper;
    private final FriendApplyMapper friendApplyMapper;
    private final UserMapper userMapper;
    private final RedisUtil redisUtil;

    private static final String FRIEND_LIST_KEY = "friend:list:";

    @Override
    public Result<List<UserVO>> searchUsers(Long userId, String keyword) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        // 优先按用户ID号精确搜索，再按昵称模糊搜索
        wrapper.and(w -> w
                .eq(User::getUserCode, keyword)
                .or()
                .like(User::getNickname, keyword)
        );
        wrapper.ne(User::getId, userId);
        wrapper.last("LIMIT 20");

        List<User> users = userMapper.selectList(wrapper);
        List<UserVO> voList = users.stream()
                .map(this::convertToUserVO)
                .collect(Collectors.toList());

        return Result.success(voList);
    }

    @Override
    @Transactional
    public Result<Void> applyFriend(Long applicantId, Long targetId, String message) {
        // 不能添加自己
        if (applicantId.equals(targetId)) {
            return Result.failed(ResultCode.CANNOT_ADD_SELF);
        }

        // 检查是否已是好友
        if (isFriend(applicantId, targetId)) {
            return Result.failed(ResultCode.FRIEND_ALREADY_EXISTS);
        }

        // 检查是否已发送申请
        LambdaQueryWrapper<FriendApply> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendApply::getApplicantId, applicantId)
                .eq(FriendApply::getTargetId, targetId)
                .eq(FriendApply::getStatus, 0);
        if (friendApplyMapper.selectCount(wrapper) > 0) {
            return Result.failed(ResultCode.FRIEND_APPLY_EXISTS);
        }

        // 创建申请
        FriendApply apply = new FriendApply();
        apply.setApplicantId(applicantId);
        apply.setTargetId(targetId);
        apply.setMessage(message);
        apply.setStatus(0);
        apply.setCreateTime(LocalDateTime.now());
        apply.setUpdateTime(LocalDateTime.now());
        friendApplyMapper.insert(apply);

        return Result.success();
    }

    @Override
    public Result<List<FriendApplyVO>> getApplyList(Long userId, Integer status) {
        LambdaQueryWrapper<FriendApply> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendApply::getTargetId, userId);
        if (status != null) {
            wrapper.eq(FriendApply::getStatus, status);
        }
        wrapper.orderByDesc(FriendApply::getCreateTime);

        List<FriendApply> applyList = friendApplyMapper.selectList(wrapper);
        List<FriendApplyVO> voList = applyList.stream()
                .map(apply -> {
                    FriendApplyVO vo = new FriendApplyVO();
                    BeanUtil.copyProperties(apply, vo);
                    User applicant = userMapper.selectById(apply.getApplicantId());
                    if (applicant != null) {
                        vo.setApplicantName(applicant.getNickname());
                        vo.setApplicantAvatar(applicant.getAvatar());
                    }
                    return vo;
                })
                .collect(Collectors.toList());

        return Result.success(voList);
    }

    @Override
    @Transactional
    public Result<Void> acceptApply(Long userId, Long applyId) {
        FriendApply apply = friendApplyMapper.selectById(applyId);
        if (apply == null || !apply.getTargetId().equals(userId)) {
            return Result.failed(ResultCode.FRIEND_APPLY_NOT_FOUND);
        }

        // 更新申请状态
        apply.setStatus(1);
        apply.setUpdateTime(LocalDateTime.now());
        friendApplyMapper.updateById(apply);

        // 建立双向好友关系
        createFriendship(apply.getApplicantId(), apply.getTargetId());
        createFriendship(apply.getTargetId(), apply.getApplicantId());

        // 清除好友列表缓存
        redisUtil.delete(FRIEND_LIST_KEY + userId);
        redisUtil.delete(FRIEND_LIST_KEY + apply.getApplicantId());

        return Result.success();
    }

    @Override
    public Result<Void> rejectApply(Long userId, Long applyId, String reason) {
        FriendApply apply = friendApplyMapper.selectById(applyId);
        if (apply == null || !apply.getTargetId().equals(userId)) {
            return Result.failed(ResultCode.FRIEND_APPLY_NOT_FOUND);
        }

        apply.setStatus(2);
        apply.setRejectReason(reason);
        apply.setUpdateTime(LocalDateTime.now());
        friendApplyMapper.updateById(apply);

        return Result.success();
    }

    @Override
    public Result<Void> ignoreApply(Long userId, Long applyId) {
        FriendApply apply = friendApplyMapper.selectById(applyId);
        if (apply == null || !apply.getTargetId().equals(userId)) {
            return Result.failed(ResultCode.FRIEND_APPLY_NOT_FOUND);
        }

        apply.setStatus(3);
        apply.setUpdateTime(LocalDateTime.now());
        friendApplyMapper.updateById(apply);

        return Result.success();
    }

    @Override
    public Result<List<UserVO>> getFriendList(Long userId) {
        // 先从缓存获取
        Object cached = redisUtil.get(FRIEND_LIST_KEY + userId);
        if (cached instanceof List) {
            return Result.success((List<UserVO>) cached);
        }

        LambdaQueryWrapper<Friend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friend::getUserId, userId);
        List<Friend> friends = friendMapper.selectList(wrapper);

        List<UserVO> voList = friends.stream()
                .map(f -> {
                    UserVO vo = getUserVOById(f.getFriendId());
                    if (vo != null) {
                        // 可以附加备注信息
                    }
                    return vo;
                })
                .filter(vo -> vo != null)
                .collect(Collectors.toList());

        // 缓存好友列表
        redisUtil.set(FRIEND_LIST_KEY + userId, voList, 10, java.util.concurrent.TimeUnit.MINUTES);

        return Result.success(voList);
    }

    @Override
    @Transactional
    public Result<Void> deleteFriend(Long userId, Long friendId) {
        // 删除双向好友关系
        LambdaQueryWrapper<Friend> wrapper1 = new LambdaQueryWrapper<>();
        wrapper1.eq(Friend::getUserId, userId).eq(Friend::getFriendId, friendId);
        friendMapper.delete(wrapper1);

        LambdaQueryWrapper<Friend> wrapper2 = new LambdaQueryWrapper<>();
        wrapper2.eq(Friend::getUserId, friendId).eq(Friend::getFriendId, userId);
        friendMapper.delete(wrapper2);

        // 清除缓存
        redisUtil.delete(FRIEND_LIST_KEY + userId);
        redisUtil.delete(FRIEND_LIST_KEY + friendId);

        return Result.success();
    }

    @Override
    public Result<Void> setRemark(Long userId, Long friendId, String remark) {
        LambdaQueryWrapper<Friend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friend::getUserId, userId).eq(Friend::getFriendId, friendId);
        Friend friend = friendMapper.selectOne(wrapper);

        if (friend == null) {
            return Result.failed(ResultCode.FRIEND_NOT_FOUND);
        }

        friend.setRemark(remark);
        friendMapper.updateById(friend);

        // 清除缓存
        redisUtil.delete(FRIEND_LIST_KEY + userId);

        return Result.success();
    }

    @Override
    public boolean isFriend(Long userId, Long friendId) {
        LambdaQueryWrapper<Friend> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Friend::getUserId, userId).eq(Friend::getFriendId, friendId);
        return friendMapper.selectCount(wrapper) > 0;
    }

    private void createFriendship(Long userId, Long friendId) {
        Friend friend = new Friend();
        friend.setUserId(userId);
        friend.setFriendId(friendId);
        friend.setCreateTime(LocalDateTime.now());
        friendMapper.insert(friend);
    }

    private UserVO getUserVOById(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }
        return convertToUserVO(user);
    }

    private UserVO convertToUserVO(User user) {
        UserVO vo = new UserVO();
        BeanUtil.copyProperties(user, vo);
        return vo;
    }
}
