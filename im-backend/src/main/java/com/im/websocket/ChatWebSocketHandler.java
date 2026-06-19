package com.im.websocket;

import cn.hutool.json.JSONUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.im.entity.Message;
import com.im.service.ChatService;
import com.im.service.GroupService;
import com.im.utils.JwtUtil;
import com.im.utils.RedisUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
@RequiredArgsConstructor
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final ChatService chatService;
    private final GroupService groupService;
    private final JwtUtil jwtUtil;
    private final RedisUtil redisUtil;
    private final ObjectMapper objectMapper;

    /**
     * 用户ID -> WebSocketSession 映射
     */
    private static final Map<Long, WebSocketSession> SESSION_MAP = new ConcurrentHashMap<>();

    private static final String USER_ONLINE_KEY = "user:online:";

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long userId = getUserIdFromSession(session);
        if (userId != null) {
            // 关闭旧连接，防止资源泄漏
            WebSocketSession oldSession = SESSION_MAP.put(userId, session);
            if (oldSession != null && oldSession.isOpen()) {
                try { oldSession.close(); } catch (Exception ignored) {}
            }
            redisUtil.set(USER_ONLINE_KEY + userId, 1, 5, TimeUnit.MINUTES);
            log.info("用户 {} WebSocket连接建立", userId);

            // 通知好友上线状态
            notifyOnlineStatus(userId, 1);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage textMessage) throws Exception {
        String payload = textMessage.getPayload();
        // 心跳消息不打印日志，避免刷屏
        if (!payload.contains("HEARTBEAT")) {
            log.info("收到消息: {}", payload);
        }

        Map<String, Object> msgMap = objectMapper.readValue(payload, Map.class);
        String type = (String) msgMap.get("type");

        if ("CHAT".equals(type)) {
            handleChatMessage(session, msgMap);
        } else if ("ACK".equals(type)) {
            handleAckMessage(msgMap);
        } else if ("TYPING".equals(type)) {
            handleTypingMessage(session, msgMap);
        } else if ("HEARTBEAT".equals(type)) {
            handleHeartbeat(session);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        Long userId = getUserIdFromSession(session);
        if (userId != null) {
            // 条件删除：只有当前session匹配时才移除，避免误删重连后的新session
            SESSION_MAP.remove(userId, session);
            redisUtil.set(USER_ONLINE_KEY + userId, 2, 5, TimeUnit.MINUTES);
            log.info("用户 {} WebSocket连接关闭", userId);

            // 通知好友离线状态
            notifyOnlineStatus(userId, 2);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket传输错误", exception);
        if (session.isOpen()) {
            session.close();
        }
    }

    /**
     * 处理聊天消息
     */
    private void handleChatMessage(WebSocketSession session, Map<String, Object> msgMap) throws IOException {
        Long senderId = getUserIdFromSession(session);
        if (senderId == null) return;

        // 参数校验，防止NPE
        Object receiverIdObj = msgMap.get("receiverId");
        Object chatTypeObj = msgMap.get("chatType");
        if (receiverIdObj == null || chatTypeObj == null) {
            log.warn("消息缺少必要字段: receiverId={}, chatType={}", receiverIdObj, chatTypeObj);
            return;
        }

        // 构建消息实体
        Message message = new Message();
        message.setSenderId(senderId);
        message.setReceiverId(Long.valueOf(receiverIdObj.toString()));
        message.setChatType(Integer.valueOf(chatTypeObj.toString()));
        message.setMsgType(msgMap.get("msgType") != null ?
                Integer.valueOf(msgMap.get("msgType").toString()) : 1);
        message.setContent((String) msgMap.get("content"));
        message.setMediaUrl((String) msgMap.get("mediaUrl"));
        message.setReplyMsgId((String) msgMap.get("replyMsgId"));
        message.setAtUserIds((String) msgMap.get("atUserIds"));

        // 保存消息
        Message savedMessage = chatService.saveMessage(message);

        // 转换为VO
        var messageVO = chatService.convertToMessageVO(savedMessage);

        // 构建响应
        Map<String, Object> response = new ConcurrentHashMap<>();
        response.put("type", "CHAT");
        response.put("data", messageVO);

        if (Integer.valueOf(2).equals(message.getChatType())) {
            // 群聊：广播给所有群成员（除发送者外）
            List<Long> memberIds = groupService.getGroupMemberIds(message.getReceiverId());
            for (Long memberId : memberIds) {
                if (memberId.equals(senderId)) continue;
                WebSocketSession memberSession = SESSION_MAP.get(memberId);
                if (memberSession != null && memberSession.isOpen()) {
                    memberSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
                } else {
                    String offlineKey = "offline:msg:" + memberId;
                    redisUtil.set(offlineKey + ":" + savedMessage.getMsgId(), messageVO, 7, TimeUnit.DAYS);
                }
            }
        } else {
            // 私聊：发送给单个接收者
            Long receiverId = message.getReceiverId();
            WebSocketSession receiverSession = SESSION_MAP.get(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                receiverSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            } else {
                String offlineKey = "offline:msg:" + receiverId;
                redisUtil.set(offlineKey + ":" + savedMessage.getMsgId(), messageVO, 7, TimeUnit.DAYS);
            }
        }

        // 发送确认给发送者
        Map<String, Object> ack = new ConcurrentHashMap<>();
        ack.put("type", "ACK");
        ack.put("msgId", savedMessage.getMsgId());
        ack.put("seqId", savedMessage.getSeqId());
        ack.put("status", "sent");
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(ack)));
    }

    /**
     * 处理消息确认
     */
    private void handleAckMessage(Map<String, Object> msgMap) {
        String msgId = (String) msgMap.get("msgId");
        // 更新消息已读状态
        log.info("收到消息确认: {}", msgId);
    }

    /**
     * 处理输入状态
     */
    private void handleTypingMessage(WebSocketSession session, Map<String, Object> msgMap) throws IOException {
        Long senderId = getUserIdFromSession(session);
        if (senderId == null) return;

        Object receiverIdObj = msgMap.get("receiverId");
        if (receiverIdObj == null) return;

        Long receiverId = Long.valueOf(receiverIdObj.toString());
        WebSocketSession receiverSession = SESSION_MAP.get(receiverId);
        if (receiverSession != null && receiverSession.isOpen()) {
            Map<String, Object> response = new ConcurrentHashMap<>();
            response.put("type", "TYPING");
            response.put("senderId", senderId);
            receiverSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
        }
    }

    /**
     * 处理心跳
     */
    private void handleHeartbeat(WebSocketSession session) throws IOException {
        Long userId = getUserIdFromSession(session);
        if (userId != null) {
            // 续期在线状态
            redisUtil.set(USER_ONLINE_KEY + userId, 1, 5, TimeUnit.MINUTES);
        }

        Map<String, Object> response = new ConcurrentHashMap<>();
        response.put("type", "HEARTBEAT");
        response.put("timestamp", System.currentTimeMillis());
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    /**
     * 通知好友在线状态变化
     */
    private void notifyOnlineStatus(Long userId, Integer status) {
        // 这里可以查询好友列表并通知
        // 简化实现：只更新Redis状态
        redisUtil.set(USER_ONLINE_KEY + userId, status, 5, TimeUnit.MINUTES);
    }

    /**
     * 从session中获取用户ID
     */
    private Long getUserIdFromSession(WebSocketSession session) {
        Object userId = session.getAttributes().get("userId");
        return userId != null ? Long.valueOf(userId.toString()) : null;
    }

    /**
     * 发送消息给指定用户
     */
    public void sendMessageToUser(Long userId, Object message) throws IOException {
        WebSocketSession session = SESSION_MAP.get(userId);
        if (session != null && session.isOpen()) {
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
        }
    }

    /**
     * 检查用户是否在线
     */
    public boolean isUserOnline(Long userId) {
        return SESSION_MAP.containsKey(userId);
    }
}
