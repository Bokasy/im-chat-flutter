package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("friend")
public class Friend {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long friendId;

    private String remark;

    private String groupName;

    /**
     * 逻辑删除 0-未删除 1-已删除
     */
    @TableLogic
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
