package com.im.service;

import com.im.dto.FileUploadVO;
import com.im.dto.Result;
import org.springframework.web.multipart.MultipartFile;

public interface FileService {

    /**
     * 上传图片
     */
    Result<FileUploadVO> uploadImage(MultipartFile file);

    /**
     * 上传文件
     */
    Result<FileUploadVO> uploadFile(MultipartFile file);
}
