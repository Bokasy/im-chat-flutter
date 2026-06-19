import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'zhangsan';
    _passwordController.text = '123456';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('提示', '请输入用户名和密码');
      return;
    }

    final success = await _authController.login(username, password);
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: ThemeConfig.accentGradient,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeConfig.primaryColor.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.chat_rounded, size: 40, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'IM Chat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect · Communicate · Collaborate',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: ThemeConfig.textSecondaryColor, letterSpacing: 1),
                          ),
                          const SizedBox(height: 48),

                          // 登录表单
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: ThemeConfig.surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: ThemeConfig.borderColor),
                              boxShadow: ThemeConfig.softShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  '欢迎回来',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.textPrimaryColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('登录以继续', style: TextStyle(fontSize: 14, color: ThemeConfig.textSecondaryColor)),
                                const SizedBox(height: 32),

                                // 用户名
                                TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                                  decoration: const InputDecoration(
                                    labelText: '用户名',
                                    prefixIcon: Icon(Icons.person_outline, size: 20),
                                    hintText: '请输入用户名',
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
                                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                    hintText: '请输入密码',
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // 登录按钮
                                Obx(() => Container(
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
                                    onPressed: _authController.isLoading.value ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: _authController.isLoading.value
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('登 录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2)),
                                  ),
                                )),
                                const SizedBox(height: 20),

                                // 注册入口
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('还没有账号？ ', style: TextStyle(color: ThemeConfig.textSecondaryColor)),
                                    GestureDetector(
                                      onTap: () => Get.toNamed('/register'),
                                      child: const Text('立即注册', style: TextStyle(color: ThemeConfig.accentColor, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 扫码登录
                                Center(
                                  child: GestureDetector(
                                    onTap: () => Get.toNamed('/qrcode-login'),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_scanner, size: 18, color: ThemeConfig.textSecondaryColor),
                                        const SizedBox(width: 6),
                                        Text('扫码登录', style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 测试账号
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ThemeConfig.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ThemeConfig.borderColor),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.info_outline, size: 16, color: ThemeConfig.textSecondaryColor),
                                    const SizedBox(width: 8),
                                    Text('测试账号', style: TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textSecondaryColor, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildDemoAccount('zhangsan', '123456', '10000001'),
                                    _buildDemoAccount('lisi', '123456', '10000002'),
                                    _buildDemoAccount('wangwu', '123456', '10000003'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String username, String password, String userCode) {
    return GestureDetector(
      onTap: () {
        _usernameController.text = username;
        _passwordController.text = password;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ThemeConfig.primarySoftColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeConfig.borderColor),
        ),
        child: Column(
          children: [
            Text(username, style: const TextStyle(color: ThemeConfig.textPrimaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('ID: $userCode', style: TextStyle(color: ThemeConfig.accentColor, fontSize: 10)),
            const SizedBox(height: 2),
            Text(password, style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
