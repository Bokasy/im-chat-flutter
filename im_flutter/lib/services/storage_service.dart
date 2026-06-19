import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token
  String? getToken() => _prefs.getString('token');
  Future<bool> setToken(String token) => _prefs.setString('token', token);
  Future<bool> removeToken() => _prefs.remove('token');
  Future<bool> saveToken(String token) => setToken(token);

  // 用户ID
  int? getUserId() => _prefs.getInt('userId');
  Future<bool> setUserId(int userId) => _prefs.setInt('userId', userId);
  Future<bool> removeUserId() => _prefs.remove('userId');
  Future<bool> saveUserId(int userId) => setUserId(userId);

  // 用户名
  String? getUsername() => _prefs.getString('username');
  Future<bool> setUsername(String username) => _prefs.setString('username', username);

  // 昵称
  String? getNickname() => _prefs.getString('nickname');
  Future<bool> setNickname(String nickname) => _prefs.setString('nickname', nickname);

  // 头像
  String? getAvatar() => _prefs.getString('avatar');
  Future<bool> setAvatar(String avatar) => _prefs.setString('avatar', avatar);

  // 用户编号
  String? getUserCode() => _prefs.getString('userCode');
  Future<bool> setUserCode(String userCode) => _prefs.setString('userCode', userCode);

  // 用户信息
  Future<bool> saveUserInfo(Map<String, dynamic> userInfo) async {
    if (userInfo['id'] != null) await setUserId(userInfo['id']);
    if (userInfo['username'] != null) await setUsername(userInfo['username']);
    if (userInfo['userCode'] != null) await setUserCode(userInfo['userCode']);
    if (userInfo['nickname'] != null) await setNickname(userInfo['nickname']);
    if (userInfo['avatar'] != null) await setAvatar(userInfo['avatar']);
    return true;
  }

  // 是否已登录
  bool get isLoggedIn => getToken() != null;

  // 清除所有数据
  Future<bool> clearAll() => _prefs.clear();
}
