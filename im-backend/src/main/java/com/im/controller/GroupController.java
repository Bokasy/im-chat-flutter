package com.im.controller;

import com.im.dto.Result;
import com.im.service.GroupService;
import com.im.vo.GroupInfoVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "群聊模块", description = "群组创建、成员管理")
@RestController
@RequestMapping("/api/v1/group")
@RequiredArgsConstructor
public class GroupController {

    private final GroupService groupService;

    @Operation(summary = "创建群组", description = "创建群组并邀请成员")
    @PostMapping("/create")
    public Result<GroupInfoVO> createGroup(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        String groupName = (String) body.get("groupName");
        if (groupName == null || groupName.isBlank()) {
            return Result.failed(com.im.enums.ResultCode.PARAM_ERROR);
        }
        @SuppressWarnings("unchecked")
        List<Long> memberIds = ((List<Number>) body.getOrDefault("memberIds", List.of()))
                .stream().map(Number::longValue).toList();
        return groupService.createGroup(userId, groupName, memberIds);
    }

    @Operation(summary = "获取群列表", description = "获取当前用户加入的群列表")
    @GetMapping("/list")
    public Result<List<GroupInfoVO>> getGroupList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return groupService.getGroupList(userId);
    }

    @Operation(summary = "获取群信息", description = "获取群组详细信息")
    @GetMapping("/{groupId}")
    public Result<GroupInfoVO> getGroupInfo(
            @Parameter(description = "群组ID") @PathVariable Long groupId) {
        return groupService.getGroupInfo(groupId);
    }

    @Operation(summary = "邀请成员", description = "邀请用户加入群组")
    @PostMapping("/{groupId}/invite")
    public Result<Void> inviteMembers(
            HttpServletRequest request,
            @Parameter(description = "群组ID") @PathVariable Long groupId,
            @RequestBody Map<String, List<Long>> body) {
        Long userId = (Long) request.getAttribute("userId");
        List<Long> memberIds = body.get("memberIds");
        return groupService.inviteMembers(userId, groupId, memberIds);
    }

    @Operation(summary = "退出群聊", description = "退出群组")
    @PostMapping("/{groupId}/leave")
    public Result<Void> leaveGroup(
            HttpServletRequest request,
            @Parameter(description = "群组ID") @PathVariable Long groupId) {
        Long userId = (Long) request.getAttribute("userId");
        return groupService.leaveGroup(userId, groupId);
    }
}
