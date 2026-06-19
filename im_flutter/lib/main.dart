import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/app/routes/app_pages.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/controllers/contact_controller.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  await Get.putAsync(() => StorageService().init());

  // 初始化服务
  Get.put(ApiService());
  Get.put(WebSocketService());

  // 初始化控制器
  Get.put(AuthController());
  Get.put(ChatController());
  Get.put(ContactController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IM Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.noTransition,
      popGesture: false,
    );
  }
}
