package com.im.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "扫码登录响应")
public class QRCodeLoginVO {

    @Schema(description = "二维码token")
    private String qrToken;

    @Schema(description = "二维码图片URL（Base64）")
    private String qrCodeUrl;

    @Schema(description = "过期时间（秒）")
    private Integer expiresIn;
}
