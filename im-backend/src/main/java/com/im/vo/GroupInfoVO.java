package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "群组信息VO")
public class GroupInfoVO {

    @Schema(description = "群组ID")
    private Long id;

    @Schema(description = "群名称")
    private String groupName;

    @Schema(description = "群头像")
    private String groupAvatar;

    @Schema(description = "群公告")
    private String notice;

    @Schema(description = "群主ID")
    private Long ownerId;

    @Schema(description = "群主昵称")
    private String ownerName;

    @Schema(description = "成员数量")
    private Integer memberCount;

    @Schema(description = "成员列表")
    private List<GroupMemberVO> members;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
