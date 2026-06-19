package com.im.service;

import com.im.dto.PageResult;
import com.im.dto.Result;
import com.im.entity.Message;
import com.im.vo.MessageVO;
import com.im.vo.SessionVO;

import java.util.List;

public interface ChatService {

    /**
     * 保存消息
     */
    Message saveMessage(Message message);

    /**
     * 获取聊天记录
     */
    Result<PageResult<MessageVO>> getChatHistory(Long userId, Long targetId, Integer chatType, Integer page, Integer size);

    /**
     * 搜索聊天记录
     */
    Result<List<MessageVO>> searchMessages(Long userId, String keyword);

    /**
     * 撤回消息
     */
    Result<Void> recallMessage(Long userId, String msgId);

    /**
     * 转发消息
     */
    Result<Void> forwardMessage(Long userId, String msgId, List<Long> targetIds);

    /**
     * 标记消息已读
     */
    Result<Void> markMessageRead(Long userId, Long targetId, Integer chatType);

    /**
     * 获取会话列表
     */
    Result<List<SessionVO>> getSessionList(Long userId);

    /**
     * 置顶会话
     */
    Result<Void> pinSession(Long userId, Long sessionId, Integer isPinned);

    /**
     * 设置免打扰
     */
    Result<Void> muteSession(Long userId, Long sessionId, Integer isMuted);

    /**
     * 归档会话
     */
    Result<Void> archiveSession(Long userId, Long sessionId, Integer isArchived);

    /**
     * 获取或创建会话
     */
    SessionVO getOrCreateSession(Long userId, Long targetId, Integer chatType);

    /**
     * 转换为MessageVO
     */
    MessageVO convertToMessageVO(Message message);
}
