package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "登录响应")
public class LoginVO {

    @Schema(description = "访问令牌")
    private String token;

    @Schema(description = "用户信息")
    private UserVO userInfo;
}
