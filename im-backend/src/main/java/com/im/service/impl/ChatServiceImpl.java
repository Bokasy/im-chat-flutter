package com.im.service.impl;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.im.dto.PageResult;
import com.im.dto.Result;
import com.im.entity.Message;
import com.im.entity.Session;
import com.im.entity.User;
import com.im.enums.ResultCode;
import com.im.entity.GroupInfo;
import com.im.mapper.GroupInfoMapper;
import com.im.mapper.GroupMemberMapper;
import com.im.mapper.MessageMapper;
import com.im.mapper.SessionMapper;
import com.im.mapper.UserMapper;
import com.im.service.ChatService;
import com.im.utils.RedisUtil;
import com.im.vo.MessageVO;
import com.im.vo.SessionVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final MessageMapper messageMapper;
    private final SessionMapper sessionMapper;
    private final UserMapper userMapper;
    private final GroupInfoMapper groupInfoMapper;
    private final GroupMemberMapper groupMemberMapper;
    private final RedisUtil redisUtil;

    private static final String SEQ_KEY = "msg:seq:";
    private static final String SESSION_KEY = "session:list:";

    private final AtomicLong seqGenerator = new AtomicLong(System.currentTimeMillis());

    @Override
    @Transactional
    public Message saveMessage(Message message) {
        // 生成消息ID
        if (message.getMsgId() == null) {
            message.setMsgId(IdUtil.fastSimpleUUID());
        }

        // 生成序列号
        if (message.getSeqId() == null) {
            message.setSeqId(seqGenerator.incrementAndGet());
        }

        message.setCreateTime(LocalDateTime.now());
        message.setIsRecalled(0);
        message.setIsRead(0);

        messageMapper.insert(message);

        // 更新会话
        updateSession(message);

        return message;
    }

    @Override
    public Result<PageResult<MessageVO>> getChatHistory(Long userId, Long targetId, Integer chatType, Integer page, Integer size) {
        Page<Message> pageParam = new Page<>(page, size);

        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        if (Integer.valueOf(1).equals(chatType)) {
            // 私聊：查询双方的消息
            wrapper.and(w -> w
                    .and(w1 -> w1.eq(Message::getSenderId, userId).eq(Message::getReceiverId, targetId))
                    .or(w2 -> w2.eq(Message::getSenderId, targetId).eq(Message::getReceiverId, userId))
            );
        } else {
            // 群聊：查询群消息
            wrapper.eq(Message::getReceiverId, targetId);
        }
        wrapper.eq(Message::getIsRecalled, 0);
        wrapper.orderByDesc(Message::getSeqId);

        Page<Message> result = messageMapper.selectPage(pageParam, wrapper);

        List<MessageVO> voList = result.getRecords().stream()
                .map(this::convertToMessageVO)
                .collect(Collectors.toList());

        return Result.success(PageResult.of(voList, result.getTotal(), result.getSize(), result.getCurrent()));
    }

    @Override
    public Result<List<MessageVO>> searchMessages(Long userId, String keyword) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w
                .eq(Message::getSenderId, userId)
                .or()
                .eq(Message::getReceiverId, userId)
        );
        wrapper.like(Message::getContent, keyword);
        wrapper.eq(Message::getIsRecalled, 0);
        wrapper.orderByDesc(Message::getCreateTime);
        wrapper.last("LIMIT 50");

        List<Message> messages = messageMapper.selectList(wrapper);
        List<MessageVO> voList = messages.stream()
                .map(this::convertToMessageVO)
                .collect(Collectors.toList());

        return Result.success(voList);
    }

    @Override
    @Transactional
    public Result<Void> recallMessage(Long userId, String msgId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getMsgId, msgId);
        Message message = messageMapper.selectOne(wrapper);

        if (message == null) {
            return Result.failed(ResultCode.MESSAGE_NOT_FOUND);
        }

        if (!message.getSenderId().equals(userId)) {
            return Result.failed(ResultCode.MESSAGE_RECALL_FAILED);
        }

        // 检查是否超过2分钟
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime createTime = message.getCreateTime();
        if (createTime.plusMinutes(2).isBefore(now)) {
            return Result.failed(ResultCode.MESSAGE_RECALL_TIMEOUT);
        }

        // 标记为已撤回
        message.setIsRecalled(1);
        messageMapper.updateById(message);

        return Result.success();
    }

    @Override
    @Transactional
    public Result<Void> forwardMessage(Long userId, String msgId, List<Long> targetIds) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Message::getMsgId, msgId);
        Message originalMessage = messageMapper.selectOne(wrapper);

        if (originalMessage == null) {
            return Result.failed(ResultCode.MESSAGE_NOT_FOUND);
        }

        // 转发给每个目标
        for (Long targetId : targetIds) {
            Message forwardMsg = new Message();
            forwardMsg.setSenderId(userId);
            forwardMsg.setReceiverId(targetId);
            forwardMsg.setChatType(1);
            forwardMsg.setMsgType(originalMessage.getMsgType());
            forwardMsg.setContent(originalMessage.getContent());
            forwardMsg.setMediaUrl(originalMessage.getMediaUrl());
            saveMessage(forwardMsg);
        }

        return Result.success();
    }

    @Override
    @Transactional
    public Result<Void> markMessageRead(Long userId, Long targetId, Integer chatType) {
        LambdaUpdateWrapper<Message> wrapper = new LambdaUpdateWrapper<>();
        if (Integer.valueOf(1).equals(chatType)) {
            wrapper.eq(Message::getSenderId, targetId)
                    .eq(Message::getReceiverId, userId);
        } else {
            wrapper.eq(Message::getReceiverId, targetId);
        }
        wrapper.eq(Message::getIsRead, 0);
        wrapper.set(Message::getIsRead, 1);

        messageMapper.update(null, wrapper);

        // 清除未读数
        LambdaQueryWrapper<Session> sessionWrapper = new LambdaQueryWrapper<>();
        sessionWrapper.eq(Session::getUserId, userId)
                .eq(Session::getTargetId, targetId);
        Session session = sessionMapper.selectOne(sessionWrapper);
        if (session != null) {
            session.setUnreadCount(0);
            sessionMapper.updateById(session);
        }

        return Result.success();
    }

    @Override
    public Result<List<SessionVO>> getSessionList(Long userId) {
        LambdaQueryWrapper<Session> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Session::getUserId, userId)
                .eq(Session::getIsArchived, 0)
                .orderByDesc(Session::getIsPinned)
                .orderByDesc(Session::getLastMsgTime);

        List<Session> sessions = sessionMapper.selectList(wrapper);
        List<SessionVO> voList = sessions.stream()
                .map(this::convertToSessionVO)
                .collect(Collectors.toList());

        return Result.success(voList);
    }

    @Override
    public Result<Void> pinSession(Long userId, Long sessionId, Integer isPinned) {
        Session session = sessionMapper.selectById(sessionId);
        if (session == null || !session.getUserId().equals(userId)) {
            return Result.failed(ResultCode.CHAT_SESSION_NOT_FOUND);
        }

        session.setIsPinned(isPinned);
        sessionMapper.updateById(session);

        return Result.success();
    }

    @Override
    public Result<Void> muteSession(Long userId, Long sessionId, Integer isMuted) {
        Session session = sessionMapper.selectById(sessionId);
        if (session == null || !session.getUserId().equals(userId)) {
            return Result.failed(ResultCode.CHAT_SESSION_NOT_FOUND);
        }

        session.setIsMuted(isMuted);
        sessionMapper.updateById(session);

        return Result.success();
    }

    @Override
    public Result<Void> archiveSession(Long userId, Long sessionId, Integer isArchived) {
        Session session = sessionMapper.selectById(sessionId);
        if (session == null || !session.getUserId().equals(userId)) {
            return Result.failed(ResultCode.CHAT_SESSION_NOT_FOUND);
        }

        session.setIsArchived(isArchived);
        sessionMapper.updateById(session);

        return Result.success();
    }

    @Override
    @Transactional
    public SessionVO getOrCreateSession(Long userId, Long targetId, Integer chatType) {
        LambdaQueryWrapper<Session> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Session::getUserId, userId)
                .eq(Session::getTargetId, targetId)
                .eq(Session::getChatType, chatType);

        Session session = sessionMapper.selectOne(wrapper);

        if (session == null) {
            session = new Session();
            session.setUserId(userId);
            session.setTargetId(targetId);
            session.setChatType(chatType);
            session.setUnreadCount(0);
            session.setIsPinned(0);
            session.setIsMuted(0);
            session.setIsArchived(0);
            session.setCreateTime(LocalDateTime.now());
            session.setUpdateTime(LocalDateTime.now());
            sessionMapper.insert(session);
        }

        return convertToSessionVO(session);
    }

    @Override
    public MessageVO convertToMessageVO(Message message) {
        MessageVO vo = new MessageVO();
        BeanUtil.copyProperties(message, vo);

        // 获取发送者信息
        User sender = userMapper.selectById(message.getSenderId());
        if (sender != null) {
            vo.setSenderName(sender.getNickname());
            vo.setSenderAvatar(sender.getAvatar());
        }

        return vo;
    }

    private void updateSession(Message message) {
        Long senderId = message.getSenderId();
        Long receiverId = message.getReceiverId();

        if (Integer.valueOf(2).equals(message.getChatType())) {
            // 群聊：更新所有群成员的会话
            List<Long> memberIds = getGroupMemberIdsFromDb(receiverId);
            for (Long memberId : memberIds) {
                int addUnread = memberId.equals(senderId) ? 0 : 1;
                updateSessionForUser(memberId, receiverId, message, addUnread);
            }
        } else {
            // 私聊：更新发送者和接收者的会话
            updateSessionForUser(senderId, receiverId, message, 0);
            updateSessionForUser(receiverId, senderId, message, 1);
        }
    }

    private List<Long> getGroupMemberIdsFromDb(Long groupId) {
        LambdaQueryWrapper<com.im.entity.GroupMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(com.im.entity.GroupMember::getGroupId, groupId);
        return groupMemberMapper.selectList(wrapper).stream()
                .map(com.im.entity.GroupMember::getUserId)
                .collect(Collectors.toList());
    }

    private void updateSessionForUser(Long userId, Long targetId, Message message, int addUnread) {
        LambdaQueryWrapper<Session> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Session::getUserId, userId)
                .eq(Session::getTargetId, targetId)
                .eq(Session::getChatType, message.getChatType());

        Session session = sessionMapper.selectOne(wrapper);

        if (session == null) {
            session = new Session();
            session.setUserId(userId);
            session.setTargetId(targetId);
            session.setChatType(message.getChatType());
            session.setLastMsgId(message.getId());
            session.setLastMsgContent(message.getContent());
            session.setLastMsgTime(message.getCreateTime());
            session.setUnreadCount(addUnread);
            session.setIsPinned(0);
            session.setIsMuted(0);
            session.setIsArchived(0);
            session.setCreateTime(LocalDateTime.now());
            session.setUpdateTime(LocalDateTime.now());
            sessionMapper.insert(session);
        } else {
            session.setLastMsgId(message.getId());
            session.setLastMsgContent(message.getContent());
            session.setLastMsgTime(message.getCreateTime());
            if (addUnread > 0) {
                session.setUnreadCount(session.getUnreadCount() + 1);
            }
            session.setUpdateTime(LocalDateTime.now());
            sessionMapper.updateById(session);
        }

        // 清除会话列表缓存
        redisUtil.delete(SESSION_KEY + userId);
    }

    private SessionVO convertToSessionVO(Session session) {
        SessionVO vo = new SessionVO();
        BeanUtil.copyProperties(session, vo);

        if (Integer.valueOf(2).equals(session.getChatType())) {
            // 群聊：获取群组信息
            GroupInfo group = groupInfoMapper.selectById(session.getTargetId());
            if (group != null) {
                vo.setTargetName(group.getGroupName());
                vo.setTargetAvatar(group.getGroupAvatar());
            }
        } else {
            // 私聊：获取用户信息
            User targetUser = userMapper.selectById(session.getTargetId());
            if (targetUser != null) {
                vo.setTargetName(targetUser.getNickname());
                vo.setTargetAvatar(targetUser.getAvatar());
                vo.setOnlineStatus(targetUser.getStatus());
            }
        }

        return vo;
    }
}
