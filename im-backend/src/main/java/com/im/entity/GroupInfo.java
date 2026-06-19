package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("group_info")
public class GroupInfo {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String groupName;

    private String groupAvatar;

    private String notice;

    private Long ownerId;

    private Integer maxMembers;

    @TableLogic
    private Integer deleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
