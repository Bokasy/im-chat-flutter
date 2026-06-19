package com.im.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "文件上传响应")
public class FileUploadVO {

    @Schema(description = "文件访问URL")
    private String url;

    @Schema(description = "文件名")
    private String filename;

    @Schema(description = "文件大小（字节）")
    private Long size;

    @Schema(description = "文件类型")
    private String contentType;
}
