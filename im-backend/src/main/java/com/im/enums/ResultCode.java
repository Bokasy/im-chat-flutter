package com.im.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ResultCode {

    SUCCESS(200, "操作成功"),
    FAILED(500, "操作失败"),

    // 用户相关 1xxx
    USER_NOT_FOUND(1001, "用户不存在"),
    USERNAME_EXISTS(1002, "用户名已存在"),
    USERCODE_EXISTS(1003, "用户ID已被占用"),
    USERCODE_INVALID(1004, "用户ID格式不正确（需8位数字）"),
    PASSWORD_ERROR(1005, "密码错误"),
    USER_DISABLED(1006, "用户已被禁用"),
    TOKEN_INVALID(1007, "Token无效或已过期"),
    TOKEN_EXPIRED(1008, "Token已过期"),
    LOGIN_EXPIRED(1009, "登录已过期，请重新登录"),

    // 好友相关 2xxx
    FRIEND_ALREADY_EXISTS(2001, "已是好友关系"),
    FRIEND_APPLY_EXISTS(2002, "好友申请已发送"),
    FRIEND_APPLY_NOT_FOUND(2003, "好友申请不存在"),
    FRIEND_NOT_FOUND(2004, "好友不存在"),
    CANNOT_ADD_SELF(2005, "不能添加自己为好友"),

    // 消息相关 3xxx
    MESSAGE_NOT_FOUND(3001, "消息不存在"),
    MESSAGE_RECALL_TIMEOUT(3002, "消息已超过2分钟，无法撤回"),
    MESSAGE_RECALL_FAILED(3003, "只能撤回自己发送的消息"),
    CHAT_SESSION_NOT_FOUND(3004, "会话不存在"),

    // 群聊相关 4xxx
    GROUP_NOT_FOUND(4001, "群组不存在"),
    GROUP_MEMBER_EXISTS(4002, "已是群成员"),
    GROUP_MEMBER_LIMIT(4003, "群成员已达上限"),
    NOT_GROUP_ADMIN(4004, "非群管理员，无权操作"),

    // 文件相关 5xxx
    FILE_UPLOAD_FAILED(5001, "文件上传失败"),
    FILE_TYPE_ERROR(5002, "文件类型不支持"),
    FILE_SIZE_EXCEED(5003, "文件大小超出限制"),

    // 扫码相关 6xxx
    QR_CODE_EXPIRED(6001, "二维码已过期"),
    QR_CODE_NOT_FOUND(6002, "二维码不存在"),

    // 系统相关 9xxx
    SYSTEM_ERROR(9999, "系统异常"),
    PARAM_ERROR(9998, "参数错误"),
    RATE_LIMIT(9997, "请求过于频繁，请稍后再试");

    private final int code;
    private final String message;
}
