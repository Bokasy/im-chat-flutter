import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/avatar_config.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  late TextEditingController _nicknameController;
  late TextEditingController _signatureController;
  late TextEditingController _customTagController;
  late String _selectedAvatar;
  List<String> _selectedTags = [];

  // 预设标签
  static const List<String> _presetTags = [
    '🎵 音乐', '🎬 电影', '📚 阅读', '🎮 游戏', '⚽ 运动',
    '🏃 健身', '✈️ 旅行', '📸 摄影', '🎨 设计', '💻 编程',
    '🍳 美食', '🐱 宠物', '🎸 吉他', '🎤 唱歌', '🧘 瑜伽',
    '🎣 钓鱼', '🏕️ 露营', '☕ 咖啡',
  ];

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _signatureController = TextEditingController(text: user?.signature ?? '');
    _customTagController = TextEditingController();
    _selectedAvatar = user?.avatar ?? AvatarConfig.avatars[0];
    // TODO: 从用户数据加载已选标签
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _signatureController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑个人信息'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('保存', style: TextStyle(color: ThemeConfig.primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像
            Center(
              child: GestureDetector(
                onTap: _showAvatarPicker,
                child: Stack(
                  children: [
                    AvatarWidget(
                      avatar: _selectedAvatar,
                      size: 100,
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
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击更换头像',
              style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // 昵称
            _buildTextField(
              controller: _nicknameController,
              label: '昵称',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // 个性签名
            _buildTextField(
              controller: _signatureController,
              label: '个性签名',
              icon: Icons.edit_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // 兴趣标签
            _buildTagSection(),
            const SizedBox(height: 24),

            // 用户名（不可编辑）
            Obx(() {
              final user = _authController.currentUser.value;
              return _buildInfoItem(
                label: '用户名',
                value: user?.username ?? '',
                icon: Icons.alternate_email,
              );
            }),
            const SizedBox(height: 16),

            // 用户ID（不可编辑）
            Obx(() {
              final user = _authController.currentUser.value;
              return _buildInfoItem(
                label: '用户ID',
                value: '${user?.id ?? ''}',
                icon: Icons.badge_outlined,
              );
            }),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: ThemeConfig.textPrimaryColor),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ThemeConfig.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: ThemeConfig.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: ThemeConfig.textSecondaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: ThemeConfig.textSecondaryColor),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 兴趣标签编辑区域
  Widget _buildTagSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag, size: 20, color: ThemeConfig.primaryColor),
              const SizedBox(width: 8),
              const Text(
                '兴趣标签',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedTags.length}/8',
                style: TextStyle(
                  fontSize: 13,
                  color: ThemeConfig.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 已选标签
          if (_selectedTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 13)),
                  backgroundColor: ThemeConfig.primarySoftColor,
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() => _selectedTags.remove(tag));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 添加自定义标签
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customTagController,
                  style: const TextStyle(color: ThemeConfig.textPrimaryColor),
                  decoration: InputDecoration(
                    hintText: '输入自定义标签',
                    hintStyle: TextStyle(color: ThemeConfig.textTertiaryColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeConfig.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ThemeConfig.borderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final tag = _customTagController.text.trim();
                  if (tag.isNotEmpty && !_selectedTags.contains(tag) && _selectedTags.length < 8) {
                    setState(() {
                      _selectedTags.add(tag);
                      _customTagController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle, color: ThemeConfig.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 预设标签选择
          Text(
            '推荐标签',
            style: TextStyle(
              fontSize: 13,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else if (_selectedTags.length < 8) {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeConfig.primaryColor.withOpacity(0.15)
                        : ThemeConfig.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : ThemeConfig.borderColor,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : ThemeConfig.textSecondaryColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 显示头像选择器
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
                  color: ThemeConfig.textSecondaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '选择头像',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                      setState(() {
                        _selectedAvatar = avatar;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: ThemeConfig.primaryColor,
                                width: 3,
                              )
                            : null,
                      ),
                      child: AvatarWidget(
                        avatar: avatar,
                        size: 60,
                      ),
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

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    final signature = _signatureController.text.trim();

    if (nickname.isEmpty) {
      Get.snackbar('提示', '昵称不能为空', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final apiService = Get.find<ApiService>();
      final storageService = Get.find<StorageService>();

      final response = await apiService.put('/user/update', data: {
        'nickname': nickname,
        'signature': signature,
        'avatar': _selectedAvatar,
      });

      if (response.data['code'] == 200) {
        await storageService.setNickname(nickname);
        await storageService.setAvatar(_selectedAvatar);
        _authController.getUserInfo();

        Get.snackbar('成功', '个人信息已保存', snackPosition: SnackPosition.BOTTOM);
        Get.back();
      } else {
        Get.snackbar('失败', response.data['message'] ?? '保存失败',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '保存失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
