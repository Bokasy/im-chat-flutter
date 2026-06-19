import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/avatar_config.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _userCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authController = Get.find<AuthController>();
  bool _obscurePassword = true;
  String _selectedAvatar = AvatarConfig.avatars[0];

  @override
  void dispose() {
    _usernameController.dispose();
    _userCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final userCode = _userCodeController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('提示', '请输入用户名和密码');
      return;
    }

    if (userCode.isEmpty) {
      Get.snackbar('提示', '请输入用户ID');
      return;
    }

    if (userCode.length != 8 || !RegExp(r'^\d{8}$').hasMatch(userCode)) {
      Get.snackbar('提示', '用户ID必须为8位数字');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('提示', '两次密码输入不一致');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('提示', '密码长度不能少于6位');
      return;
    }

    final success = await _authController.register(
      username,
      password,
      nickname.isNotEmpty ? nickname : username,
      userCode,
      _selectedAvatar,
    );
    if (success) {
      Get.offAllNamed('/chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: ThemeConfig.backgroundColor,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 返回按钮
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: ThemeConfig.accentGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeConfig.primaryColor.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '创建账号',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.textPrimaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '注册后开始使用',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeConfig.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 表单卡片
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: ThemeConfig.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: ThemeConfig.borderColor),
                          boxShadow: ThemeConfig.softShadow,
                        ),
                        child: Column(
                          children: [
                            // 选择头像
                            GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      AvatarWidget(
                                        avatar: _selectedAvatar,
                                        size: 80,
                                        borderColor: ThemeConfig.primaryColor,
                                        borderWidth: 3,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: ThemeConfig.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '选择头像',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: ThemeConfig.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 用户名
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                              decoration: const InputDecoration(
                                labelText: '用户名',
                                prefixIcon: Icon(Icons.person_outline),
                                hintText: '请输入用户名（3-20位）',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 用户ID
                            TextField(
                              controller: _userCodeController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                              decoration: const InputDecoration(
                                labelText: '用户ID',
                                prefixIcon: Icon(Icons.badge_outlined),
                                hintText: '请输入8位数字ID（注册后不可修改）',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 昵称
                            TextField(
                              controller: _nicknameController,
                              style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                              decoration: const InputDecoration(
                                labelText: '昵称',
                                prefixIcon: Icon(Icons.badge_outlined),
                                hintText: '请输入昵称（选填）',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 密码
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                              decoration: InputDecoration(
                                labelText: '密码',
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: '请输入密码（至少6位）',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 确认密码
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                              decoration: const InputDecoration(
                                labelText: '确认密码',
                                prefixIcon: Icon(Icons.lock_outline),
                                hintText: '请再次输入密码',
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 注册按钮
                            Obx(() => Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: ThemeConfig.accentGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeConfig.primaryColor.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _authController.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '注 册',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 登录入口
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '已有账号？ ',
                            style: TextStyle(color: ThemeConfig.textSecondaryColor),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Text(
                              '返回登录',
                              style: TextStyle(
                                color: ThemeConfig.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '选择头像',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: AvatarConfig.avatars.length,
                itemBuilder: (context, index) {
                  final avatar = AvatarConfig.avatars[index];
                  final isSelected = avatar == _selectedAvatar;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = avatar);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: ThemeConfig.primaryColor, width: 3)
                            : null,
                      ),
                      child: AvatarWidget(avatar: avatar, size: 60),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
