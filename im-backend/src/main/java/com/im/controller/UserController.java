package com.im.controller;

import com.im.dto.LoginRequest;
import com.im.dto.QRCodeLoginVO;
import com.im.dto.QRCodeStatusVO;
import com.im.dto.RegisterRequest;
import com.im.dto.Result;
import com.im.service.UserService;
import com.im.vo.LoginVO;
import com.im.vo.UserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "用户模块", description = "用户注册、登录、信息管理")
@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "用户注册", description = "新用户注册账号")
    @PostMapping("/register")
    public Result<LoginVO> register(@Valid @RequestBody RegisterRequest request) {
        return userService.register(request);
    }

    @Operation(summary = "用户登录", description = "用户名密码登录")
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginRequest request) {
        return userService.login(request);
    }

    @Operation(summary = "获取用户信息", description = "获取当前登录用户信息")
    @GetMapping("/info")
    public Result<UserVO> getUserInfo(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.getUserInfo(userId);
    }

    @Operation(summary = "获取指定用户信息", description = "根据用户ID获取用户信息")
    @GetMapping("/info/{userId}")
    public Result<UserVO> getUserInfoById(
            @Parameter(description = "用户ID") @PathVariable Long userId) {
        return userService.getUserInfo(userId);
    }

    @Operation(summary = "更新用户信息", description = "更新当前用户昵称、头像、签名等")
    @PutMapping("/update")
    public Result<UserVO> updateUser(HttpServletRequest request, @RequestBody UserVO userVO) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.updateUser(userId, userVO);
    }

    @Operation(summary = "更新在线状态", description = "设置用户在线状态：1-在线 2-离线 3-忙碌 4-勿扰")
    @PutMapping("/status")
    public Result<Void> updateStatus(HttpServletRequest request, @RequestBody Map<String, Object> body) {
        Long userId = (Long) request.getAttribute("userId");
        Integer status = Integer.valueOf(body.get("status").toString());
        return userService.updateStatus(userId, status);
    }

    @Operation(summary = "生成扫码登录二维码", description = "Web端生成登录二维码")
    @GetMapping("/login/qrcode/generate")
    public Result<QRCodeLoginVO> generateQRCode() {
        return userService.generateQRCode();
    }

    @Operation(summary = "确认扫码登录", description = "手机端确认扫码登录")
    @PostMapping("/login/qrcode/scan")
    public Result<Void> confirmQRCodeScan(
            HttpServletRequest request,
            @Parameter(description = "二维码token") @RequestParam String qrToken) {
        Long userId = (Long) request.getAttribute("userId");
        return userService.confirmQRCodeScan(userId, qrToken);
    }

    @Operation(summary = "轮询二维码状态", description = "Web端轮询二维码扫描状态")
    @GetMapping("/login/qrcode/check")
    public Result<QRCodeStatusVO> checkQRCodeStatus(
            @Parameter(description = "二维码token") @RequestParam String qrToken) {
        return userService.checkQRCodeStatus(qrToken);
    }
}
