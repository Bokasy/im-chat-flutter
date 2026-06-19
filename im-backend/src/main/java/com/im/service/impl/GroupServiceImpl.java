package com.im.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.im.entity.GroupInfo;
import com.im.entity.GroupMember;
import com.im.entity.User;
import com.im.enums.ResultCode;
import com.im.dto.Result;
import com.im.mapper.GroupInfoMapper;
import com.im.mapper.GroupMemberMapper;
import com.im.mapper.UserMapper;
import com.im.service.GroupService;
import com.im.vo.GroupInfoVO;
import com.im.vo.GroupMemberVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GroupServiceImpl implements GroupService {

    private final GroupInfoMapper groupInfoMapper;
    private final GroupMemberMapper groupMemberMapper;
    private final UserMapper userMapper;

    @Override
    @Transactional
    public Result<GroupInfoVO> createGroup(Long userId, String groupName, List<Long> memberIds) {
        // 创建群组
        GroupInfo group = new GroupInfo();
        group.setGroupName(groupName);
        group.setOwnerId(userId);
        group.setMaxMembers(500);
        group.setCreateTime(LocalDateTime.now());
        group.setUpdateTime(LocalDateTime.now());
        groupInfoMapper.insert(group);

        // 添加群主为成员
        GroupMember owner = new GroupMember();
        owner.setGroupId(group.getId());
        owner.setUserId(userId);
        owner.setRole(2); // 群主
        owner.setJoinTime(LocalDateTime.now());
        groupMemberMapper.insert(owner);

        // 添加其他成员
        if (memberIds != null) {
            for (Long memberId : memberIds) {
                if (!memberId.equals(userId)) {
                    GroupMember member = new GroupMember();
                    member.setGroupId(group.getId());
                    member.setUserId(memberId);
                    member.setRole(0); // 成员
                    member.setJoinTime(LocalDateTime.now());
                    groupMemberMapper.insert(member);
                }
            }
        }

        return Result.success(convertToGroupInfoVO(group));
    }

    @Override
    public Result<List<GroupInfoVO>> getGroupList(Long userId) {
        // 查询用户所在的群组ID
        LambdaQueryWrapper<GroupMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(GroupMember::getUserId, userId);
        List<GroupMember> memberships = groupMemberMapper.selectList(memberWrapper);

        List<GroupInfoVO> groupList = new ArrayList<>();
        for (GroupMember membership : memberships) {
            GroupInfo group = groupInfoMapper.selectById(membership.getGroupId());
            if (group != null) {
                groupList.add(convertToGroupInfoVO(group));
            }
        }

        return Result.success(groupList);
    }

    @Override
    public Result<GroupInfoVO> getGroupInfo(Long groupId) {
        GroupInfo group = groupInfoMapper.selectById(groupId);
        if (group == null) {
            return Result.failed(ResultCode.GROUP_NOT_FOUND);
        }
        return Result.success(convertToGroupInfoVO(group));
    }

    @Override
    public List<Long> getGroupMemberIds(Long groupId) {
        LambdaQueryWrapper<GroupMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupMember::getGroupId, groupId);
        return groupMemberMapper.selectList(wrapper).stream()
                .map(GroupMember::getUserId)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Result<Void> inviteMembers(Long userId, Long groupId, List<Long> memberIds) {
        GroupInfo group = groupInfoMapper.selectById(groupId);
        if (group == null) {
            return Result.failed(ResultCode.GROUP_NOT_FOUND);
        }

        for (Long memberId : memberIds) {
            // 检查是否已经是群成员
            LambdaQueryWrapper<GroupMember> checkWrapper = new LambdaQueryWrapper<>();
            checkWrapper.eq(GroupMember::getGroupId, groupId)
                    .eq(GroupMember::getUserId, memberId);
            if (groupMemberMapper.selectCount(checkWrapper) > 0) {
                continue; // 跳过已存在的成员
            }

            GroupMember member = new GroupMember();
            member.setGroupId(groupId);
            member.setUserId(memberId);
            member.setRole(0);
            member.setJoinTime(LocalDateTime.now());
            groupMemberMapper.insert(member);
        }

        return Result.success();
    }

    @Override
    @Transactional
    public Result<Void> leaveGroup(Long userId, Long groupId) {
        LambdaQueryWrapper<GroupMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupMember::getGroupId, groupId)
                .eq(GroupMember::getUserId, userId);
        groupMemberMapper.delete(wrapper);
        return Result.success();
    }

    private GroupInfoVO convertToGroupInfoVO(GroupInfo group) {
        GroupInfoVO vo = new GroupInfoVO();
        vo.setId(group.getId());
        vo.setGroupName(group.getGroupName());
        vo.setGroupAvatar(group.getGroupAvatar());
        vo.setNotice(group.getNotice());
        vo.setOwnerId(group.getOwnerId());
        vo.setCreateTime(group.getCreateTime());

        // 获取群主信息
        User owner = userMapper.selectById(group.getOwnerId());
        if (owner != null) {
            vo.setOwnerName(owner.getNickname());
        }

        // 获取成员列表
        LambdaQueryWrapper<GroupMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(GroupMember::getGroupId, group.getId());
        List<GroupMember> members = groupMemberMapper.selectList(memberWrapper);
        vo.setMemberCount(members.size());

        List<GroupMemberVO> memberVOs = members.stream().map(m -> {
            GroupMemberVO mvo = new GroupMemberVO();
            mvo.setUserId(m.getUserId());
            mvo.setGroupNickname(m.getGroupNickname());
            mvo.setRole(m.getRole());
            User user = userMapper.selectById(m.getUserId());
            if (user != null) {
                mvo.setUsername(user.getUsername());
                mvo.setNickname(user.getNickname());
                mvo.setAvatar(user.getAvatar());
                mvo.setStatus(user.getStatus());
            }
            return mvo;
        }).collect(Collectors.toList());
        vo.setMembers(memberVOs);

        return vo;
    }
}
