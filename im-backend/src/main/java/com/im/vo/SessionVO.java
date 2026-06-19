package com.im.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "会话信息")
public class SessionVO {

    @Schema(description = "会话ID")
    private Long id;

    @Schema(description = "目标ID（用户ID或群组ID）")
    private Long targetId;

    @Schema(description = "目标名称")
    private String targetName;

    @Schema(description = "目标头像")
    private String targetAvatar;

    @Schema(description = "聊天类型 1-私聊 2-群聊")
    private Integer chatType;

    @Schema(description = "最后消息内容")
    private String lastMsgContent;

    @Schema(description = "最后消息时间")
    private LocalDateTime lastMsgTime;

    @Schema(description = "未读消息数")
    private Integer unreadCount;

    @Schema(description = "是否置顶")
    private Integer isPinned;

    @Schema(description = "是否免打扰")
    private Integer isMuted;

    @Schema(description = "在线状态")
    private Integer onlineStatus;
}
