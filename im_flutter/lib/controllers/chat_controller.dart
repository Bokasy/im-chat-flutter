import 'dart:async';
import 'package:get/get.dart';
import 'package:im_flutter/models/message_model.dart';
import 'package:im_flutter/models/session_model.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/services/websocket_service.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final WebSocketService _wsService = Get.find<WebSocketService>();

  final sessions = <SessionModel>[].obs;
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final currentTargetId = 0.obs;
  final currentChatType = 1.obs;
  final replyMessage = Rxn<MessageModel>();

  StreamSubscription? _wsSubscription;
  Timer? _typingTimer;

  @override
  void onInit() {
    super.onInit();
    _listenWebSocket();
  }

  @override
  void onClose() {
    _wsSubscription?.cancel();
    _typingTimer?.cancel();
    super.onClose();
  }

  // 监听WebSocket消息
  void _listenWebSocket() {
    _wsSubscription = _wsService.messageStream.listen((message) {
      final type = message['type'];
      if (type == 'CHAT') {
        _handleChatMessage(message['data']);
      } else if (type == 'TYPING') {
        _handleTypingMessage(message);
      }
    });
  }

  // 处理聊天消息
  void _handleChatMessage(Map<String, dynamic> data) {
    final message = MessageModel.fromJson(data);
    final myId = _storageService.getUserId();

    // 判断消息是否属于当前打开的会话
    bool isCurrentChat = false;
    if (message.chatType == 2) {
      // 群聊：receiverId 是群组ID
      isCurrentChat = message.receiverId == currentTargetId.value;
    } else {
      // 私聊：对方是 senderId 或 receiverId
      isCurrentChat = (message.senderId == currentTargetId.value ||
          message.receiverId == currentTargetId.value);
    }

    // 如果是当前会话的消息，添加到消息列表
    if (isCurrentChat) {
      messages.insert(0, message);

      // 如果当前正在看这个会话，自动标记已读
      if (message.senderId != myId) {
        markRead(currentTargetId.value, currentChatType.value);
      }
    }

    // 更新会话列表
    _updateSession(message);

    // 发送确认
    if (message.msgId != null) {
      _wsService.sendAck(message.msgId!);
    }
  }

  // 处理输入状态
  void _handleTypingMessage(Map<String, dynamic> message) {
    // 显示对方正在输入...
  }

  // 加载会话列表
  Future<void> loadSessions() async {
    try {
      final response = await _apiService.get('/chat/session/list');
      if (response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'];
        sessions.value = data.map((e) => SessionModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('加载会话列表失败: $e');
    }
  }

  // 加载聊天记录
  Future<void> loadMessages(int targetId, int chatType) async {
    currentTargetId.value = targetId;
    currentChatType.value = chatType;
    isLoading.value = true;

    try {
      final response = await _apiService.get('/chat/history', params: {
        'targetId': targetId,
        'chatType': chatType,
        'page': 1,
        'size': 50,
      });

      if (response.data['code'] == 200) {
        final records = response.data['data']?['records'];
        if (records != null) {
          messages.value = (records as List).map((e) => MessageModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('加载聊天记录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 发送消息
  void sendMessage(String content, {int msgType = 1}) {
    final receiverId = currentTargetId.value;
    final chatType = currentChatType.value;

    _wsService.sendChatMessage(
      receiverId: receiverId,
      chatType: chatType,
      content: content,
      msgType: msgType,
    );

    // 本地添加消息（乐观更新）
    final myId = _storageService.getUserId() ?? 0;
    final message = MessageModel(
      msgId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: myId,
      receiverId: receiverId,
      chatType: chatType,
      msgType: msgType,
      content: content,
      isRead: 0,
      isRecalled: 0,
      createTime: DateTime.now().toIso8601String(),
    );
    messages.insert(0, message);

    // 同步更新会话列表
    _updateSession(message);
  }

  // 更新会话
  void _updateSession(MessageModel message) {
    final myId = _storageService.getUserId();

    // 确定会话的目标ID
    int? targetId;
    if (message.chatType == 2) {
      // 群聊：目标是群组ID（即receiverId）
      targetId = message.receiverId;
    } else {
      // 私聊：目标是对方
      targetId = message.senderId == myId ? message.receiverId : message.senderId;
    }

    if (targetId == null) return;

    final index = sessions.indexWhere((s) =>
        s.targetId == targetId && s.chatType == message.chatType);

    if (index >= 0) {
      // 更新现有会话
      final session = sessions[index];
      sessions[index] = SessionModel(
        id: session.id,
        targetId: session.targetId,
        targetName: session.targetName,
        targetAvatar: session.targetAvatar,
        chatType: session.chatType,
        lastMsgContent: message.content,
        lastMsgTime: message.createTime,
        unreadCount: message.senderId == myId
            ? session.unreadCount
            : (session.unreadCount ?? 0) + 1,
        isPinned: session.isPinned,
        isMuted: session.isMuted,
        onlineStatus: session.onlineStatus,
      );
    } else {
      // 创建新会话（需要获取对方信息）
      sessions.insert(0, SessionModel(
        targetId: targetId,
        chatType: message.chatType,
        lastMsgContent: message.content,
        lastMsgTime: message.createTime,
        unreadCount: message.senderId == myId ? 0 : 1,
      ));
      // 刷新会话列表以获取完整信息
      loadSessions();
    }

    // 按时间排序
    sessions.sort((a, b) =>
        (b.lastMsgTime ?? '').compareTo(a.lastMsgTime ?? ''));
  }

  // 标记已读
  Future<void> markRead(int targetId, int chatType) async {
    try {
      await _apiService.post('/chat/message/read', data: {
        'targetId': targetId,
        'chatType': chatType,
      });

      // 更新本地未读数
      final index = sessions.indexWhere((s) =>
          s.targetId == targetId && s.chatType == chatType);
      if (index >= 0) {
        final session = sessions[index];
        sessions[index] = SessionModel(
          id: session.id,
          targetId: session.targetId,
          targetName: session.targetName,
          targetAvatar: session.targetAvatar,
          chatType: session.chatType,
          lastMsgContent: session.lastMsgContent,
          lastMsgTime: session.lastMsgTime,
          unreadCount: 0,
          isPinned: session.isPinned,
          isMuted: session.isMuted,
          onlineStatus: session.onlineStatus,
        );
      }
    } catch (e) {
      print('标记已读失败: $e');
    }
  }

  // 删除会话
  Future<void> deleteSession(int sessionId) async {
    try {
      await _apiService.post('/chat/session/archive', data: {
        'sessionId': sessionId,
        'isArchived': 1,
      });
      sessions.removeWhere((s) => s.id == sessionId);
    } catch (e) {
      print('删除会话失败: $e');
    }
  }

  // 置顶会话
  Future<void> pinSession(int sessionId, bool isPinned) async {
    try {
      await _apiService.post('/chat/session/pin', data: {
        'sessionId': sessionId,
        'isPinned': isPinned ? 1 : 0,
      });
      loadSessions();
    } catch (e) {
      print('置顶会话失败: $e');
    }
  }

  // 免打扰
  Future<void> muteSession(int sessionId, bool isMuted) async {
    try {
      await _apiService.post('/chat/session/mute', data: {
        'sessionId': sessionId,
        'isMuted': isMuted ? 1 : 0,
      });
      loadSessions();
    } catch (e) {
      print('免打扰设置失败: $e');
    }
  }

  // 发送输入状态（防抖：停止输入500ms后才发送）
  void sendTypingStatus() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 500), () {
      if (currentTargetId.value > 0) {
        _wsService.sendTypingStatus(currentTargetId.value);
      }
    });
  }

  // 发送图片消息
  Future<void> sendImageMessage(String imagePath) async {
    try {
      isLoading.value = true;

      final response = await _apiService.uploadFile('/file/upload/image', imagePath);

      if (response.data['code'] == 200) {
        final imageUrl = response.data['data']['url'];

        _wsService.sendChatMessage(
          receiverId: currentTargetId.value,
          chatType: currentChatType.value,
          content: '[图片]',
          msgType: 2,
          mediaUrl: imageUrl,
        );

        final myId = _storageService.getUserId() ?? 0;
        final message = MessageModel(
          msgId: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: myId,
          receiverId: currentTargetId.value,
          chatType: currentChatType.value,
          msgType: 2,
          content: '[图片]',
          mediaUrl: imageUrl,
          isRead: 0,
          isRecalled: 0,
          createTime: DateTime.now().toIso8601String(),
        );
        messages.insert(0, message);
        _updateSession(message);
      } else {
        Get.snackbar('错误', '图片上传失败');
      }
    } catch (e) {
      Get.snackbar('错误', '发送图片失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 设置回复消息
  void setReplyMessage(MessageModel message) {
    replyMessage.value = message;
  }

  // 清除回复消息
  void clearReplyMessage() {
    replyMessage.value = null;
  }

  // 撤回消息
  Future<void> recallMessage(String msgId) async {
    try {
      final response = await _apiService.post('/chat/message/recall', data: {'msgId': msgId});

      if (response.data['code'] == 200) {
        final index = messages.indexWhere((m) => m.msgId == msgId);
        if (index >= 0) {
          final oldMessage = messages[index];
          messages[index] = MessageModel(
            id: oldMessage.id,
            msgId: oldMessage.msgId,
            senderId: oldMessage.senderId,
            senderName: oldMessage.senderName,
            senderAvatar: oldMessage.senderAvatar,
            receiverId: oldMessage.receiverId,
            chatType: oldMessage.chatType,
            msgType: oldMessage.msgType,
            content: oldMessage.content,
            mediaUrl: oldMessage.mediaUrl,
            thumbnailUrl: oldMessage.thumbnailUrl,
            replyMsgId: oldMessage.replyMsgId,
            replyContent: oldMessage.replyContent,
            atUserIds: oldMessage.atUserIds,
            isRecalled: 1,
            isRead: oldMessage.isRead,
            seqId: oldMessage.seqId,
            createTime: oldMessage.createTime,
          );
        }
        Get.snackbar('成功', '消息已撤回');
      } else {
        Get.snackbar('失败', response.data['message'] ?? '撤回失败');
      }
    } catch (e) {
      Get.snackbar('错误', '撤回失败: $e');
    }
  }

  // 转发消息
  Future<void> forwardMessage(String msgId, List<int> targetIds) async {
    try {
      final response = await _apiService.post(
        '/chat/message/forward',
        data: {'msgId': msgId, 'targetIds': targetIds},
      );

      if (response.data['code'] == 200) {
        Get.snackbar('成功', '消息已转发');
      } else {
        Get.snackbar('失败', response.data['message'] ?? '转发失败');
      }
    } catch (e) {
      Get.snackbar('错误', '转发失败: $e');
    }
  }

  // 发送带回复的消息
  void sendMessageWithReply(String content, {int msgType = 1}) {
    final receiverId = currentTargetId.value;
    final chatType = currentChatType.value;
    final replyMsgId = replyMessage.value?.msgId;

    _wsService.sendChatMessage(
      receiverId: receiverId,
      chatType: chatType,
      content: content,
      msgType: msgType,
      replyMsgId: replyMsgId,
    );

    final myId = _storageService.getUserId() ?? 0;
    final message = MessageModel(
      msgId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: myId,
      receiverId: receiverId,
      chatType: chatType,
      msgType: msgType,
      content: content,
      replyMsgId: replyMsgId,
      replyContent: replyMessage.value?.content,
      isRead: 0,
      isRecalled: 0,
      createTime: DateTime.now().toIso8601String(),
    );
    messages.insert(0, message);
    _updateSession(message);

    clearReplyMessage();
  }

  // 退出聊天页面时重置当前会话
  void resetCurrentChat() {
    currentTargetId.value = 0;
    currentChatType.value = 1;
    messages.clear();
  }
}
