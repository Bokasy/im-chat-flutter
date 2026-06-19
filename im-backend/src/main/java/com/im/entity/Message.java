package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("message")
public class Message {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 消息唯一ID（用于幂等）
     */
    private String msgId;

    private Long senderId;

    private Long receiverId;

    /**
     * 聊天类型 1-私聊 2-群聊
     */
    private Integer chatType;

    /**
     * 消息类型 1-文本 2-图片 3-语音 4-文件 5-系统
     */
    private Integer msgType;

    private String content;

    private String mediaUrl;

    private String thumbnailUrl;

    /**
     * 引用消息ID
     */
    private String replyMsgId;

    /**
     * @用户ID列表，逗号分隔
     */
    private String atUserIds;

    /**
     * 是否撤回 0-否 1-是
     */
    private Integer isRecalled;

    /**
     * 是否已读 0-否 1-是
     */
    private Integer isRead;

    /**
     * 阅后即焚过期时间
     */
    private LocalDateTime expireTime;

    /**
     * 消息序列号（用于排序）
     */
    private Long seqId;

    /**
     * 逻辑删除 0-未删除 1-已删除
     */
    @TableLogic
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
