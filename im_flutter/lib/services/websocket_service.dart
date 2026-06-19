import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:im_flutter/config/api_config.dart';
import 'package:im_flutter/services/storage_service.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 10;
  bool _isConnected = false;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    super.onClose();
  }

  // 连接WebSocket
  Future<void> connect() async {
    // 先断开旧连接
    disconnect();

    final token = Get.find<StorageService>().getToken();
    if (token == null) {
      print('WebSocket: token为空，跳过连接');
      return;
    }

    try {
      final wsUrl = '${ApiConfig.wsUrl}?token=$token';
      print('WebSocket: 正在连接 $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // 连接建立即标记为已连接
      _isConnected = true;
      _reconnectAttempts = 0;
      print('WebSocket: 连接已建立');

      _streamSubscription = _channel!.stream.listen(
        (data) {
          if (data is String) {
            try {
              final message = json.decode(data);
              // 心跳消息不打印，避免刷屏
              if (message['type'] != 'HEARTBEAT') {
                print('WebSocket: 收到消息 type=${message['type']}');
              }
              _messageController.add(message);
            } catch (e) {
              print('WebSocket: 消息解析错误 $e');
            }
          }
        },
        onError: (error) {
          print('WebSocket: 连接错误 $error');
          _isConnected = false;
          _startReconnect();
        },
        onDone: () {
          print('WebSocket: 连接关闭');
          _isConnected = false;
          _startReconnect();
        },
      );

      _startHeartbeat();
    } catch (e) {
      print('WebSocket: 连接异常 $e');
      _isConnected = false;
      _startReconnect();
    }
  }

  // 断开连接
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _streamSubscription?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer = null;
    _streamSubscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;
  }

  // 发送消息
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
        // 心跳消息不打印，避免刷屏
        if (message['type'] != 'HEARTBEAT') {
          print('WebSocket: 消息已发送 type=${message['type']}');
        }
      } catch (e) {
        print('WebSocket: 发送失败 $e');
        _isConnected = false;
      }
    } else {
      print('WebSocket: 未连接，无法发送 (connected=$_isConnected, channel=${_channel != null})');
    }
  }

  // 发送聊天消息
  void sendChatMessage({
    required int receiverId,
    required int chatType,
    required String content,
    int msgType = 1,
    String? mediaUrl,
    String? replyMsgId,
    String? atUserIds,
  }) {
    sendMessage({
      'type': 'CHAT',
      'receiverId': receiverId,
      'chatType': chatType,
      'msgType': msgType,
      'content': content,
      'mediaUrl': mediaUrl,
      'replyMsgId': replyMsgId,
      'atUserIds': atUserIds,
    });
  }

  // 发送输入状态
  void sendTypingStatus(int receiverId) {
    sendMessage({
      'type': 'TYPING',
      'receiverId': receiverId,
    });
  }

  // 发送消息确认
  void sendAck(String msgId) {
    sendMessage({
      'type': 'ACK',
      'msgId': msgId,
    });
  }

  // 开始心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'HEARTBEAT'});
      }
    });
  }

  // 开始重连
  void _startReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('WebSocket: 达到最大重连次数，停止重连');
      return;
    }

    _reconnectTimer?.cancel();

    final delay = Duration(seconds: (1 << _reconnectAttempts).clamp(1, 30));
    _reconnectAttempts++;

    print('WebSocket: ${delay.inSeconds}秒后尝试第$_reconnectAttempts次重连');

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  bool get isConnected => _isConnected;
}
