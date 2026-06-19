package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String userCode;

    private String password;

    private String nickname;

    private String avatar;

    private String signature;

    /**
     * 状态 1-在线 2-离线 3-忙碌 4-勿扰
     */
    private Integer status;

    private LocalDateTime lastLoginTime;

    private String lastLoginIp;

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
