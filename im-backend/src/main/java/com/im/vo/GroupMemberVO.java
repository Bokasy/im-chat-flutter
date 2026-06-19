package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
@Schema(description = "群成员VO")
public class GroupMemberVO {

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "用户名")
    private String username;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "头像")
    private String avatar;

    @Schema(description = "群内昵称")
    private String groupNickname;

    @Schema(description = "角色：0-成员 1-管理员 2-群主")
    private Integer role;

    @Schema(description = "在线状态")
    private Integer status;
}
