package com.im.service;

import com.im.dto.Result;
import com.im.vo.FriendApplyVO;
import com.im.vo.UserVO;

import java.util.List;

public interface FriendService {

    /**
     * 搜索用户
     */
    Result<List<UserVO>> searchUsers(Long userId, String keyword);

    /**
     * 发送好友申请
     */
    Result<Void> applyFriend(Long applicantId, Long targetId, String message);

    /**
     * 获取好友申请列表
     */
    Result<List<FriendApplyVO>> getApplyList(Long userId, Integer status);

    /**
     * 接受好友申请
     */
    Result<Void> acceptApply(Long userId, Long applyId);

    /**
     * 拒绝好友申请
     */
    Result<Void> rejectApply(Long userId, Long applyId, String reason);

    /**
     * 忽略好友申请
     */
    Result<Void> ignoreApply(Long userId, Long applyId);

    /**
     * 获取好友列表
     */
    Result<List<UserVO>> getFriendList(Long userId);

    /**
     * 删除好友
     */
    Result<Void> deleteFriend(Long userId, Long friendId);

    /**
     * 设置好友备注
     */
    Result<Void> setRemark(Long userId, Long friendId, String remark);

    /**
     * 检查是否是好友
     */
    boolean isFriend(Long userId, Long friendId);
}
