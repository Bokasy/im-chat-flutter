package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("friend_apply")
public class FriendApply {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long applicantId;

    private Long targetId;

    private String message;

    /**
     * 状态 0-待处理 1-已接受 2-已拒绝 3-已忽略
     */
    private Integer status;

    private String rejectReason;

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
