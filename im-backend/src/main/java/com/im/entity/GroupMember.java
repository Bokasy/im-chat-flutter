package com.im.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("group_member")
public class GroupMember {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long groupId;

    private Long userId;

    private String groupNickname;

    /** 角色 0-成员 1-管理员 2-群主 */
    private Integer role;

    @TableLogic
    private Integer deleted;

    private LocalDateTime joinTime;
}
