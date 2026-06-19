import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/widgets/message_bubble.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatController _chatController = Get.find<ChatController>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  late int _targetId;
  late String _targetName;
  late String? _targetAvatar;
  late int _chatType;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _targetId = args['targetId'] ?? 0;
    _targetName = args['targetName'] ?? '未知用户';
    _targetAvatar = args['targetAvatar'];
    _chatType = args['chatType'] ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 加载聊天记录
      _chatController.loadMessages(_targetId, _chatType);
      // 标记已读
      _chatController.markRead(_targetId, _chatType);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _chatController.resetCurrentChat();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      if (_chatController.replyMessage.value != null) {
        _chatController.sendMessageWithReply(text);
      } else {
        _chatController.sendMessage(text);
      }
      _textController.clear();

      // 滚动到底部
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // 上传图片并发送
        await _chatController.sendImageMessage(image.path);

        // 滚动到底部
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      Get.snackbar('错误', '选择图片失败: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // 上传图片并发送
        await _chatController.sendImageMessage(image.path);

        // 滚动到底部
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      Get.snackbar('错误', '拍照失败: $e');
    }
  }

  Widget _buildReplyPreview() {
    final replyMsg = _chatController.replyMessage.value!;
    final isReplyMe = replyMsg.senderId == Get.find<StorageService>().getUserId();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        border: Border(
          top: BorderSide(color: ThemeConfig.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '回复 ${isReplyMe ? '自己' : replyMsg.senderName ?? '对方'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyMsg.msgType == 2 ? '[图片]' : (replyMsg.content ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              _chatController.clearReplyMessage();
            },
          ),
        ],
      ),
    );
  }

  void _showImagePickerBottomSheet() {
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
                const Text(
                  '选择图片来源',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: '相册',
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendImage();
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: '拍照',
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 30,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeConfig.surfaceColor,
          foregroundColor: ThemeConfig.textPrimaryColor,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _targetName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Obx(() {
              if (_chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = _chatController.messages;
              final myId = Get.find<StorageService>().getUserId();

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: ThemeConfig.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无消息',
                        style: TextStyle(
                          color: ThemeConfig.textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '发送第一条消息吧',
                        style: TextStyle(
                          color: ThemeConfig.textTertiaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.senderId == myId;

                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                    showAvatar: true,
                  );
                },
              );
            }),
          ),

          // 回复消息预览
          Obx(() {
            if (_chatController.replyMessage.value != null) {
              return _buildReplyPreview();
            }
            return const SizedBox.shrink();
          }),

          // 输入区域
          _buildInputArea(),
        ],
      ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        border: Border(
          top: BorderSide(color: ThemeConfig.borderColor),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 工具栏按钮
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: ThemeConfig.textSecondaryColor,
              onPressed: _showImagePickerBottomSheet,
            ),

            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeConfig.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (text) {
                    // 发送输入状态
                    _chatController.sendTypingStatus();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 发送按钮
            Container(
              decoration: const BoxDecoration(
                color: ThemeConfig.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部指示条
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // 搜索聊天记录
                _buildOptionItem(
                  icon: Icons.search,
                  label: '搜索聊天记录',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/chat/search');
                  },
                ),

                // 置顶聊天
                _buildOptionItem(
                  icon: Icons.push_pin_outlined,
                  label: '置顶聊天',
                  onTap: () {
                    Navigator.pop(context);
                    // 通过会话ID置顶
                    final session = _chatController.sessions.firstWhereOrNull(
                      (s) => s.targetId == _targetId,
                    );
                    if (session?.id != null) {
                      _chatController.pinSession(session!.id!, true);
                      Get.snackbar('成功', '已置顶');
                    }
                  },
                ),

                // 免打扰
                _buildOptionItem(
                  icon: Icons.notifications_off_outlined,
                  label: '消息免打扰',
                  onTap: () {
                    Navigator.pop(context);
                    final session = _chatController.sessions.firstWhereOrNull(
                      (s) => s.targetId == _targetId,
                    );
                    if (session?.id != null) {
                      _chatController.muteSession(session!.id!, true);
                      Get.snackbar('成功', '已开启免打扰');
                    }
                  },
                ),

                // 清空聊天记录
                _buildOptionItem(
                  icon: Icons.delete_outline,
                  label: '清空聊天记录',
                  color: ThemeConfig.errorColor,
                  onTap: () {
                    Navigator.pop(context);
                    _showClearChatDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? ThemeConfig.textSecondaryColor),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? ThemeConfig.textPrimaryColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空与该用户的所有聊天记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatController.messages.clear();
              Get.snackbar('成功', '聊天记录已清空');
            },
            style: TextButton.styleFrom(foregroundColor: ThemeConfig.errorColor),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}
