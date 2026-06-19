package com.im.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "注册请求")
public class RegisterRequest {

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度3-20位")
    @Schema(description = "用户名", required = true)
    private String username;

    @NotBlank(message = "用户ID不能为空")
    @Pattern(regexp = "^\\d{8}$", message = "用户ID必须为8位数字")
    @Schema(description = "用户唯一ID（8位数字）", required = true)
    private String userCode;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度6-20位")
    @Schema(description = "密码", required = true)
    private String password;

    @Schema(description = "昵称")
    private String nickname;

    @Schema(description = "头像URL")
    private String avatar;
}
