import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/models/message_model.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/utils/date_util.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.showTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageActions(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && showAvatar) ...[
              AvatarWidget(
                avatar: message.senderAvatar,
                size: 36,
              ),
              const SizedBox(width: 8),
            ],

            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (showTime)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        DateUtil.formatMessageTime(message.createTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConfig.textSecondaryColor,
                        ),
                      ),
                    ),

                  // 消息内容
                  if (message.isRecalled == 1)
                    _buildRecalledMessage()
                  else if (message.msgType == 1)
                    _buildTextMessage()
                  else if (message.msgType == 2)
                    _buildImageMessage()
                  else
                    _buildTextMessage(),
                ],
              ),
            ),

            if (isMe && showAvatar) ...[
              const SizedBox(width: 8),
              AvatarWidget(
                avatar: message.senderAvatar,
                size: 36,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessageActions(BuildContext context) {
    final ChatController chatController = Get.find<ChatController>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeConfig.textSecondaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // 消息预览
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        message.msgType == 2 ? Icons.image : Icons.message,
                        color: ThemeConfig.textSecondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message.msgType == 2 ? '[图片]' : (message.content ?? ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ThemeConfig.textPrimaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 操作按钮
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildActionButton(
                      icon: Icons.reply,
                      label: '回复',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _replyMessage(chatController);
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.forward,
                      label: '转发',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _forwardMessage(context, chatController);
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.copy,
                      label: '复制',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _copyMessage();
                      },
                    ),
                    if (isMe) ...[
                      _buildActionButton(
                        icon: Icons.replay,
                        label: '撤回',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _recallMessage(chatController);
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _replyMessage(ChatController chatController) {
    chatController.setReplyMessage(message);
  }

  void _forwardMessage(BuildContext context, ChatController chatController) {
    // 显示转发对话框
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('转发消息'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择转发方式'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      chatController.forwardMessage(message.msgId ?? '', []);
                    },
                    icon: const Icon(Icons.forward, size: 18),
                    label: const Text('逐条转发'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // 合并转发逻辑
                    },
                    icon: const Icon(Icons.merge, size: 18),
                    label: const Text('合并转发'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyMessage() {
    if (message.content != null) {
      Clipboard.setData(ClipboardData(text: message.content!));
      Get.snackbar('成功', '消息已复制到剪贴板');
    }
  }

  void _recallMessage(ChatController chatController) {
    // 检查是否超过2分钟
    if (message.createTime != null) {
      final createTime = DateTime.parse(message.createTime!);
      final now = DateTime.now();
      final difference = now.difference(createTime);

      if (difference.inMinutes > 2) {
        Get.snackbar('提示', '消息已超过2分钟，无法撤回');
        return;
      }
    }

    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('撤回消息'),
          content: const Text('确定要撤回这条消息吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                chatController.recallMessage(message.msgId ?? '');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('撤回'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? ThemeConfig.messageSentColor : ThemeConfig.messageReceivedColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.05),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 引用消息
          if (message.replyMsgId != null) _buildReplyMessage(),

          // 消息文本
          Text(
            message.content ?? '',
            style: TextStyle(
              color: isMe ? Colors.white : ThemeConfig.textPrimaryColor,
              fontSize: 15,
            ),
          ),

          // 已读状态
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateUtil.formatMessageTime(message.createTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead == 1 ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead == 1 ? Colors.blue[100] : Colors.white70,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: message.mediaUrl != null
            ? Image.network(
                message.mediaUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 150,
                  height: 150,
                  color: ThemeConfig.borderColor,
                  child: const Icon(Icons.broken_image),
                ),
              )
            : Container(
                width: 150,
                height: 150,
                color: ThemeConfig.borderColor,
                child: const Icon(Icons.image),
              ),
      ),
    );
  }

  Widget _buildRecalledMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        isMe ? '你撤回了一条消息' : '对方撤回了一条消息',
        style: TextStyle(
          color: ThemeConfig.textSecondaryColor,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildReplyMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.2) : ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : ThemeConfig.primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Text(
        message.replyContent ?? '引用消息',
        style: TextStyle(
          fontSize: 12,
          color: isMe ? Colors.white70 : ThemeConfig.textSecondaryColor,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
