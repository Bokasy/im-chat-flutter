package com.im.controller;

import com.im.dto.PageResult;
import com.im.dto.Result;
import com.im.service.ChatService;
import com.im.vo.MessageVO;
import com.im.vo.SessionVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "聊天模块", description = "消息发送、会话管理、聊天记录")
@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @Operation(summary = "获取聊天记录", description = "分页获取与指定用户的聊天记录")
    @GetMapping("/history")
    public Result<PageResult<MessageVO>> getChatHistory(
            HttpServletRequest request,
            @Parameter(description = "目标用户/群组ID") @RequestParam Long targetId,
            @Parameter(description = "聊天类型：1-私聊 2-群聊") @RequestParam Integer chatType,
            @Parameter(description = "页码") @RequestParam(defaultValue = "1") Integer page,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "20") Integer size) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getChatHistory(userId, targetId, chatType, page, size);
    }

    @Operation(summary = "搜索聊天记录", description = "全局搜索聊天记录")
    @GetMapping("/history/search")
    public Result<List<MessageVO>> searchMessages(
            HttpServletRequest request,
            @Parameter(description = "搜索关键词") @RequestParam String keyword) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.searchMessages(userId, keyword);
    }

    @Operation(summary = "撤回消息", description = "撤回2分钟内发送的消息")
    @PostMapping("/message/recall")
    public Result<Void> recallMessage(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        String msgId = body.get("msgId").toString();
        return chatService.recallMessage(userId, msgId);
    }

    @Operation(summary = "转发消息", description = "将消息转发给其他用户")
    @PostMapping("/message/forward")
    public Result<Void> forwardMessage(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        String msgId = body.get("msgId").toString();
        @SuppressWarnings("unchecked")
        List<Long> targetIds = ((List<Number>) body.get("targetIds"))
                .stream().map(Number::longValue).toList();
        return chatService.forwardMessage(userId, msgId, targetIds);
    }

    @Operation(summary = "标记消息已读", description = "标记与指定用户的消息为已读")
    @PostMapping("/message/read")
    public Result<Void> markMessageRead(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long targetId = Long.valueOf(body.get("targetId").toString());
        Integer chatType = Integer.valueOf(body.get("chatType").toString());
        return chatService.markMessageRead(userId, targetId, chatType);
    }

    @Operation(summary = "获取会话列表", description = "获取当前用户的会话列表")
    @GetMapping("/session/list")
    public Result<List<SessionVO>> getSessionList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return chatService.getSessionList(userId);
    }

    @Operation(summary = "置顶会话", description = "设置会话置顶/取消置顶")
    @PostMapping("/session/pin")
    public Result<Void> pinSession(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long sessionId = Long.valueOf(body.get("sessionId").toString());
        Integer isPinned = Integer.valueOf(body.get("isPinned").toString());
        return chatService.pinSession(userId, sessionId, isPinned);
    }

    @Operation(summary = "设置免打扰", description = "设置会话免打扰")
    @PostMapping("/session/mute")
    public Result<Void> muteSession(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long sessionId = Long.valueOf(body.get("sessionId").toString());
        Integer isMuted = Integer.valueOf(body.get("isMuted").toString());
        return chatService.muteSession(userId, sessionId, isMuted);
    }

    @Operation(summary = "归档会话", description = "归档/取消归档会话")
    @PostMapping("/session/archive")
    public Result<Void> archiveSession(
            HttpServletRequest request,
            @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Long sessionId = Long.valueOf(body.get("sessionId").toString());
        Integer isArchived = Integer.valueOf(body.get("isArchived").toString());
        return chatService.archiveSession(userId, sessionId, isArchived);
    }
}
