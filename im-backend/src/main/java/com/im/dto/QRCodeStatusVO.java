package com.im.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "二维码状态响应")
public class QRCodeStatusVO {

    @Schema(description = "状态：0-待扫描 1-已扫描待确认 2-已确认 3-已过期")
    private Integer status;

    @Schema(description = "状态描述")
    private String message;

    @Schema(description = "登录成功后的Token（仅状态为2时有值）")
    private String token;

    @Schema(description = "用户信息（仅状态为2时有值）")
    private Object userInfo;
}
