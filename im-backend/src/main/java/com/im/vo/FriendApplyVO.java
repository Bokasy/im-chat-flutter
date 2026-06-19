package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "好友申请信息")
public class FriendApplyVO {

    @Schema(description = "申请ID")
    private Long id;

    @Schema(description = "申请人ID")
    private Long applicantId;

    @Schema(description = "申请人昵称")
    private String applicantName;

    @Schema(description = "申请人头像")
    private String applicantAvatar;

    @Schema(description = "申请消息")
    private String message;

    @Schema(description = "状态 0-待处理 1-已接受 2-已拒绝 3-已忽略")
    private Integer status;

    @Schema(description = "申请时间")
    private LocalDateTime createTime;
}
