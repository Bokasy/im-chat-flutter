import 'package:get/get.dart';
import 'package:im_flutter/models/user_model.dart';
import 'package:im_flutter/services/api_service.dart';

class ContactController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final friends = <UserModel>[].obs;
  final groups = <Map<String, dynamic>>[].obs;
  final searchResults = <UserModel>[].obs;
  final friendApplies = <dynamic>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
    loadGroups();
  }

  // 加载好友列表
  Future<void> loadFriends() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/friend/list');
      if (response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'];
        friends.value = data.map((e) => UserModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('加载好友列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 加载群组列表
  Future<void> loadGroups() async {
    try {
      final response = await _apiService.get('/group/list');
      if (response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'];
        groups.value = data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('加载群组列表失败: $e');
    }
  }

  // 搜索用户
  Future<void> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final response = await _apiService.get('/friend/search', params: {
        'keyword': keyword,
      });
      if (response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'];
        searchResults.value = data.map((e) => UserModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('搜索用户失败: $e');
    }
  }

  // 发送好友申请
  Future<bool> applyFriend(int targetId, String? message) async {
    try {
      final response = await _apiService.post('/friend/apply', data: {
        'targetId': targetId,
        'message': message ?? '',
      });
      if (response.data['code'] == 200) {
        Get.snackbar('成功', '好友申请已发送');
        return true;
      } else {
        Get.snackbar('失败', response.data['message'] ?? '请重试');
        return false;
      }
    } catch (e) {
      Get.snackbar('错误', '网络请求失败');
      return false;
    }
  }

  // 加载好友申请列表
  Future<void> loadFriendApplies() async {
    try {
      final response = await _apiService.get('/friend/apply/list');
      if (response.data['code'] == 200) {
        friendApplies.value = response.data['data'];
      }
    } catch (e) {
      print('加载好友申请失败: $e');
    }
  }

  // 接受好友申请
  Future<void> acceptApply(int applyId) async {
    try {
      final response = await _apiService.post('/friend/apply/accept', data: {
        'applyId': applyId,
      });
      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已接受好友申请');
        loadFriendApplies();
        loadFriends();
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败');
    }
  }

  // 拒绝好友申请
  Future<void> rejectApply(int applyId) async {
    try {
      final response = await _apiService.post('/friend/apply/reject', data: {
        'applyId': applyId,
      });
      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已拒绝好友申请');
        loadFriendApplies();
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败');
    }
  }

  // 删除好友
  Future<void> deleteFriend(int friendId) async {
    try {
      final response = await _apiService.delete('/friend/delete', params: {
        'friendId': friendId,
      });
      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已删除好友');
        friends.removeWhere((f) => f.id == friendId);
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败');
    }
  }
}
