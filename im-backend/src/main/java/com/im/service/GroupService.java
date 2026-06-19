package com.im.service;

import com.im.dto.Result;
import com.im.vo.GroupInfoVO;

import java.util.List;

public interface GroupService {

    /** 创建群组 */
    Result<GroupInfoVO> createGroup(Long userId, String groupName, List<Long> memberIds);

    /** 获取用户的群列表 */
    Result<List<GroupInfoVO>> getGroupList(Long userId);

    /** 获取群信息 */
    Result<GroupInfoVO> getGroupInfo(Long groupId);

    /** 获取群成员ID列表（用于WebSocket广播） */
    List<Long> getGroupMemberIds(Long groupId);

    /** 邀请成员 */
    Result<Void> inviteMembers(Long userId, Long groupId, List<Long> memberIds);

    /** 退出群聊 */
    Result<Void> leaveGroup(Long userId, Long groupId);
}
