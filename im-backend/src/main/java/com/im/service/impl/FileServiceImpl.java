package com.im.service.impl;

import com.im.dto.FileUploadVO;
import com.im.dto.Result;
import com.im.enums.ResultCode;
import com.im.service.FileService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
public class FileServiceImpl implements FileService {

    @Value("${file.upload.path:./uploads}")
    private String uploadPath;

    @Value("${file.upload.url-prefix:http://localhost:8080/uploads}")
    private String urlPrefix;

    private static final List<String> ALLOWED_IMAGE_TYPES = Arrays.asList(
            "image/jpeg", "image/png", "image/gif", "image/webp"
    );

    private static final long MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
    private static final long MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB

    @Override
    public Result<FileUploadVO> uploadImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.failed(ResultCode.FILE_UPLOAD_FAILED);
        }

        // 检查文件类型
        if (!ALLOWED_IMAGE_TYPES.contains(file.getContentType())) {
            return Result.failed(ResultCode.FILE_TYPE_ERROR);
        }

        // 检查文件大小
        if (file.getSize() > MAX_IMAGE_SIZE) {
            return Result.failed(ResultCode.FILE_SIZE_EXCEED);
        }

        return uploadFile(file, "images");
    }

    @Override
    public Result<FileUploadVO> uploadFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return Result.failed(ResultCode.FILE_UPLOAD_FAILED);
        }

        // 检查文件大小
        if (file.getSize() > MAX_FILE_SIZE) {
            return Result.failed(ResultCode.FILE_SIZE_EXCEED);
        }

        return uploadFile(file, "files");
    }

    private Result<FileUploadVO> uploadFile(MultipartFile file, String subDir) {
        try {
            // 生成日期目录
            String dateDir = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            String dirPath = uploadPath + "/" + subDir + "/" + dateDir;

            // 创建目录
            File dir = new File(dirPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID().toString() + extension;

            // 保存文件
            String filePath = dirPath + "/" + filename;
            file.transferTo(new File(filePath));

            // 生成访问URL
            String url = urlPrefix + "/" + subDir + "/" + dateDir + "/" + filename;

            FileUploadVO vo = new FileUploadVO(
                    url,
                    originalFilename,
                    file.getSize(),
                    file.getContentType()
            );

            return Result.success(vo);
        } catch (IOException e) {
            log.error("文件上传失败", e);
            return Result.failed(ResultCode.FILE_UPLOAD_FAILED);
        }
    }
}
