package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("session")
public class Session {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long targetId;

    /**
     * 聊天类型 1-私聊 2-群聊
     */
    private Integer chatType;

    private Long lastMsgId;

    private String lastMsgContent;

    private LocalDateTime lastMsgTime;

    private Integer unreadCount;

    /**
     * 是否置顶 0-否 1-是
     */
    private Integer isPinned;

    /**
     * 是否免打扰 0-否 1-是
     */
    private Integer isMuted;

    /**
     * 是否归档 0-否 1-是
     */
    private Integer isArchived;

    /**
     * 逻辑删除 0-未删除 1-已删除
     */
    @TableLogic
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
