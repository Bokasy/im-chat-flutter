package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "用户信息")
public class UserVO {

    @Schema(description = "用户ID")
    private Long id;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "用户唯一ID号")
    private String userCode;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "头像URL")
    private String avatar;

    @Schema(description = "个性签名")
    private String signature;

    @Schema(description = "在线状态 1-在线 2-离线 3-忙碌 4-勿扰")
    private Integer status;

    @Schema(description = "最后登录时间")
    private LocalDateTime lastLoginTime;
}
