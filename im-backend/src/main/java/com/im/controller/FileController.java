package com.im.controller;

import com.im.dto.FileUploadVO;
import com.im.dto.Result;
import com.im.service.FileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "文件模块", description = "文件上传接口")
@RestController
@RequestMapping("/api/v1/file")
@RequiredArgsConstructor
public class FileController {

    private final FileService fileService;

    @Operation(summary = "上传图片", description = "上传图片文件（支持jpg/png/gif/webp，最大10MB）")
    @PostMapping("/upload/image")
    public Result<FileUploadVO> uploadImage(
            @Parameter(description = "图片文件") @RequestParam("file") MultipartFile file) {
        return fileService.uploadImage(file);
    }

    @Operation(summary = "上传文件", description = "上传普通文件（最大50MB）")
    @PostMapping("/upload/file")
    public Result<FileUploadVO> uploadFile(
            @Parameter(description = "文件") @RequestParam("file") MultipartFile file) {
        return fileService.uploadFile(file);
    }
}
