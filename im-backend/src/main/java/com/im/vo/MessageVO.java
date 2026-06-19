package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "消息信息")
public class MessageVO {

    @Schema(description = "消息ID")
    private Long id;

    @Schema(description = "消息唯一标识")
    private String msgId;

    @Schema(description = "发送者ID")
    private Long senderId;

    @Schema(description = "发送者昵称")
    private String senderName;

    @Schema(description = "发送者头像")
    private String senderAvatar;

    @Schema(description = "接收者ID")
    private Long receiverId;

    @Schema(description = "聊天类型 1-私聊 2-群聊")
    private Integer chatType;

    @Schema(description = "消息类型 1-文本 2-图片 3-语音 4-文件 5-系统")
    private Integer msgType;

    @Schema(description = "消息内容")
    private String content;

    @Schema(description = "媒体文件URL")
    private String mediaUrl;

    @Schema(description = "缩略图URL")
    private String thumbnailUrl;

    @Schema(description = "引用消息ID")
    private String replyMsgId;

    @Schema(description = "引用消息内容")
    private String replyContent;

    @Schema(description = "@用户ID列表")
    private String atUserIds;

    @Schema(description = "是否撤回")
    private Integer isRecalled;

    @Schema(description = "是否已读")
    private Integer isRead;

    @Schema(description = "消息序列号")
    private Long seqId;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;
}
