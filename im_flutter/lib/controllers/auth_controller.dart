import 'package:get/get.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/models/user_model.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/services/websocket_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // 检查是否已登录
    if (_storageService.isLoggedIn) {
      getUserInfo();
    }
  }

  // 登录
  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/user/login', data: {
        'username': username,
        'password': password,
      });

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        if (data == null || data['token'] == null || data['userInfo'] == null) {
          Get.snackbar('登录失败', '服务器返回数据异常');
          return false;
        }
        await _storageService.setToken(data['token']);
        await _storageService.setUserId(data['userInfo']['id']);
        await _storageService.setUsername(data['userInfo']['username'] ?? '');
        await _storageService.setUserCode(data['userInfo']['userCode'] ?? '');
        await _storageService.setNickname(data['userInfo']['nickname'] ?? '');
        await _storageService.setAvatar(data['userInfo']['avatar'] ?? '');

        currentUser.value = UserModel.fromJson(data['userInfo']);

        // 连接WebSocket
        Get.find<WebSocketService>().connect();

        // 重新加载会话列表
        Get.find<ChatController>().loadSessions();

        return true;
      } else {
        Get.snackbar('登录失败', response.data['message'] ?? '请重试',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('错误', '网络请求失败: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 注册
  Future<bool> register(String username, String password, String nickname, [String? userCode, String? avatar]) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/user/register', data: {
        'username': username,
        'password': password,
        'nickname': nickname,
        'userCode': userCode,
        'avatar': avatar,
      });

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        if (data == null || data['token'] == null || data['userInfo'] == null) {
          Get.snackbar('注册失败', '服务器返回数据异常');
          return false;
        }
        await _storageService.setToken(data['token']);
        await _storageService.setUserId(data['userInfo']['id']);
        await _storageService.setUsername(data['userInfo']['username'] ?? '');
        await _storageService.setUserCode(data['userInfo']['userCode'] ?? '');
        await _storageService.setNickname(data['userInfo']['nickname'] ?? '');
        await _storageService.setAvatar(data['userInfo']['avatar'] ?? '');

        currentUser.value = UserModel.fromJson(data['userInfo']);

        // 连接WebSocket
        Get.find<WebSocketService>().connect();

        // 重新加载会话列表
        Get.find<ChatController>().loadSessions();

        return true;
      } else {
        Get.snackbar('注册失败', response.data['message'] ?? '请重试',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('错误', '网络请求失败: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 获取用户信息
  Future<void> getUserInfo() async {
    try {
      final response = await _apiService.get('/user/info');
      if (response.data['code'] == 200) {
        currentUser.value = UserModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }

  // 退出登录
  void logout() {
    Get.find<WebSocketService>().disconnect();
    _storageService.clearAll();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
}
