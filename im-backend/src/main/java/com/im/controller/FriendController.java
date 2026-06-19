package com.im.controller;

import com.im.dto.Result;
import com.im.service.FriendService;
import com.im.vo.FriendApplyVO;
import com.im.vo.UserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "好友模块", description = "好友搜索、申请、管理")
@RestController
@RequestMapping("/api/v1/friend")
@RequiredArgsConstructor
public class FriendController {

    private final FriendService friendService;

    @Operation(summary = "搜索用户", description = "根据用户名或昵称搜索用户")
    @GetMapping("/search")
    public Result<List<UserVO>> searchUsers(
            HttpServletRequest request,
            @Parameter(description = "搜索关键词") @RequestParam String keyword) {
        Long userId = (Long) request.getAttribute("userId");
        return friendService.searchUsers(userId, keyword);
    }

    @Operation(summary = "发送好友申请", description = "向指定用户发送好友申请")
    @PostMapping("/apply")
    public Result<Void> applyFriend(
            HttpServletRequest request,
            @RequestBody java.util.Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long targetId = Long.valueOf(body.get("targetId").toString());
        String message = body.get("message") != null ? body.get("message").toString() : null;
        return friendService.applyFriend(userId, targetId, message);
    }

    @Operation(summary = "获取好友申请列表", description = "获取收到的好友申请列表")
    @GetMapping("/apply/list")
    public Result<List<FriendApplyVO>> getApplyList(
            HttpServletRequest request,
            @Parameter(description = "状态筛选：0-待处理 1-已接受 2-已拒绝 3-已忽略") @RequestParam(required = false) Integer status) {
        Long userId = (Long) request.getAttribute("userId");
        return friendService.getApplyList(userId, status);
    }

    @Operation(summary = "接受好友申请", description = "接受指定的好友申请")
    @PostMapping("/apply/accept")
    public Result<Void> acceptApply(
            HttpServletRequest request,
            @RequestBody java.util.Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long applyId = Long.valueOf(body.get("applyId").toString());
        return friendService.acceptApply(userId, applyId);
    }

    @Operation(summary = "拒绝好友申请", description = "拒绝指定的好友申请")
    @PostMapping("/apply/reject")
    public Result<Void> rejectApply(
            HttpServletRequest request,
            @RequestBody java.util.Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long applyId = Long.valueOf(body.get("applyId").toString());
        String reason = body.get("reason") != null ? body.get("reason").toString() : null;
        return friendService.rejectApply(userId, applyId, reason);
    }

    @Operation(summary = "忽略好友申请", description = "忽略指定的好友申请")
    @PostMapping("/apply/ignore")
    public Result<Void> ignoreApply(
            HttpServletRequest request,
            @RequestBody java.util.Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long applyId = Long.valueOf(body.get("applyId").toString());
        return friendService.ignoreApply(userId, applyId);
    }

    @Operation(summary = "获取好友列表", description = "获取当前用户的好友列表")
    @GetMapping("/list")
    public Result<List<UserVO>> getFriendList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return friendService.getFriendList(userId);
    }

    @Operation(summary = "删除好友", description = "删除指定好友")
    @DeleteMapping("/delete")
    public Result<Void> deleteFriend(
            HttpServletRequest request,
            @Parameter(description = "好友用户ID") @RequestParam Long friendId) {
        Long userId = (Long) request.getAttribute("userId");
        return friendService.deleteFriend(userId, friendId);
    }

    @Operation(summary = "设置好友备注", description = "为好友设置备注名")
    @PutMapping("/remark")
    public Result<Void> setRemark(
            HttpServletRequest request,
            @RequestBody java.util.Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long friendId = Long.valueOf(body.get("friendId").toString());
        String remark = body.get("remark") != null ? body.get("remark").toString() : null;
        return friendService.setRemark(userId, friendId, remark);
    }
}
