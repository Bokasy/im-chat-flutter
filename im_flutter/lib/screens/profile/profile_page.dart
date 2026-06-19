import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/screens/profile/edit_profile_page.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;

      return SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片 (Stack + 装饰)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // 装饰圆形
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: -30,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // 装饰爱心
                  const Positioned(
                    top: 20,
                    right: 60,
                    child: Icon(Icons.favorite, color: Colors.white24, size: 20),
                  ),
                  // 内容
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: AvatarWidget(
                          avatar: user?.avatar,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.nickname ?? user?.username ?? '未登录',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (user?.userCode != null)
                        Text(
                          'ID: ${user!.userCode}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.signature ?? '这个人很懒，什么都没写',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 功能列表
            _buildSection(
              title: '账号设置',
              children: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: '个人信息',
                  onTap: () {
                    Get.to(() => const EditProfilePage());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: '修改密码',
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私设置',
                  onTap: () {
                    _showFeatureDialog(context, '隐私设置');
                  },
                ),
              ],
            ),

            _buildSection(
              title: '通用设置',
              children: [
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: '消息通知',
                  onTap: () {
                    _showFeatureDialog(context, '消息通知');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.chat_outlined,
                  title: '聊天设置',
                  onTap: () {
                    _showFeatureDialog(context, '聊天设置');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.storage_outlined,
                  title: '存储空间',
                  onTap: () {
                    _showFeatureDialog(context, '存储空间');
                  },
                ),
              ],
            ),

            _buildSection(
              title: '其他',
              children: [
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '帮助与反馈',
                  onTap: () {
                    _showFeatureDialog(context, '帮助与反馈');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: '关于我们',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 退出登录按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(context, authController);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      );
    });
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: ThemeConfig.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: ThemeConfig.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ThemeConfig.borderColor),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于我们'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('即时通信 APP'),
            SizedBox(height: 8),
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('基于 Flutter + Spring Boot 开发'),
            SizedBox(height: 8),
            Text('支持 Android / iOS / Web 多端'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '原密码',
                hintText: '请输入原密码',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '新密码',
                hintText: '请输入新密码',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '确认密码',
                hintText: '请再次输入新密码',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar('错误', '两次密码不一致', snackPosition: SnackPosition.BOTTOM);
                return;
              }
              // TODO: 调用API修改密码
              Navigator.pop(context);
              Get.snackbar('成功', '密码修改成功', snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature功能开发中，敬请期待...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
