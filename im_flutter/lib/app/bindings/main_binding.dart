import 'package:get/get.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/controllers/contact_controller.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/services/websocket_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // 服务
    Get.lazyPut(() => StorageService());
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => WebSocketService());

    // 控制器
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ContactController());
  }
}
