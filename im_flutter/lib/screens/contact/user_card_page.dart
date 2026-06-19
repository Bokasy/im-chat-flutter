import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

/// 用户资料卡片页 - Stack + Positioned 实现装饰效果
class UserCardPage extends StatefulWidget {
  const UserCardPage({super.key});

  @override
  State<UserCardPage> createState() => _UserCardPageState();
}

class _UserCardPageState extends State<UserCardPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();

  late int _userId;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  bool _isFriend = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // 兴趣标签
  final List<_TagItem> _tags = [
    _TagItem('🎵', '音乐', const Color(0xFFFDF2F8)),
    _TagItem('✈️', '旅行', const Color(0xFFFFF7ED)),
    _TagItem('💻', '编程', const Color(0xFFF0F9FF)),
    _TagItem('📸', '摄影', const Color(0xFFF5F3FF)),
    _TagItem('🎨', '设计', const Color(0xFFECFDF5)),
    _TagItem('🏃', '健身', const Color(0xFFFFFBEB)),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _userId = args['userId'] ?? 0;
    _isFriend = args['isFriend'] ?? false;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await _apiService.get('/user/info/$_userId');
      if (response.data['code'] == 200) {
        if (mounted) {
          setState(() {
            _userInfo = response.data['data'];
            _isLoading = false;
          });
          _animController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: ThemeConfig.backgroundColor,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userInfo == null
                ? const Center(child: Text('用户不存在'))
                : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ========== 顶部头像区域 (Stack + Positioned) ==========
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),

        // ========== 用户信息 ==========
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildInfoSection(),
            ),
          ),
        ),

        // ========== 兴趣标签 (Wrap + Chip) ==========
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildTagsSection(),
            ),
          ),
        ),

        // ========== 操作按钮 ==========
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildActionButtons(),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  /// ========== Stack + Positioned: 头像装饰区域 ==========
  Widget _buildHeroSection() {
    final avatar = _userInfo!['avatar'] ?? '';
    final nickname = _userInfo!['nickname'] ?? '';
    final status = _userInfo!['status'] ?? 2;

    return Container(
      height: 360,
      child: Stack(
        children: [
          // 背景渐变
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 装饰圆形 - 左上
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 装饰圆形 - 右上
          Positioned(
            top: 30,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // 装饰圆形 - 右下
          Positioned(
            bottom: 60,
            right: 40,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 装饰爱心 - 左上
          const Positioned(
            top: 60,
            left: 30,
            child: Icon(
              Icons.favorite,
              color: Colors.white24,
              size: 24,
            ),
          ),

          // 装饰爱心 - 右中
          const Positioned(
            top: 100,
            right: 50,
            child: Icon(
              Icons.favorite_border,
              color: Colors.white24,
              size: 20,
            ),
          ),

          // 装饰星星
          const Positioned(
            top: 70,
            right: 100,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white24,
              size: 18,
            ),
          ),

          // 返回按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          // 更多按钮
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // ========== 核心头像 + 装饰 ==========
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Hero(
                tag: 'avatar_$_userId',
                child: Stack(
                  children: [
                    // 外圈光晕
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // 头像边框
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AvatarWidget(avatar: avatar, size: 122),
                      ),
                    ),
                    // 在线状态指示器
                    if (status == 1)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: ThemeConfig.onlineColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeConfig.onlineColor.withOpacity(0.5),
                                blurRadius: 8,
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

          // 昵称
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 签名
                if (_userInfo!['signature'] != null &&
                    _userInfo!['signature'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _userInfo!['signature'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // 底部圆角遮罩
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 30,
              decoration: const BoxDecoration(
                color: ThemeConfig.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ========== 信息卡片 ==========
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThemeConfig.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('状态', _getStatusText(_userInfo!['status'] ?? 2),
                _getStatusColor(_userInfo!['status'] ?? 2)),
            _buildDivider(),
            _buildStatItem('用户名', _userInfo!['username'] ?? '', null),
            _buildDivider(),
            _buildStatItem(
                'ID', _userInfo!['userCode'] ?? '', ThemeConfig.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? ThemeConfig.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: ThemeConfig.borderColor,
    );
  }

  /// ========== Wrap + Chip: 兴趣标签 ==========
  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '兴趣标签',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: tag.bgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: tag.bgColor.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tag.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      tag.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// ========== 操作按钮 ==========
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        children: [
          // 发消息按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.toNamed('/chat/detail', arguments: {
                  'targetId': _userInfo!['id'],
                  'targetName':
                      _userInfo!['nickname'] ?? _userInfo!['username'],
                  'targetAvatar': _userInfo!['avatar'],
                  'chatType': 1,
                });
              },
              icon: const Icon(Icons.chat_rounded, size: 20),
              label: const Text('发消息'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 添加好友 / 已是好友
          if (!_isFriend)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _showAddFriendDialog(),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: const Text('添加好友'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.primaryColor,
                  side: const BorderSide(
                      color: ThemeConfig.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: ThemeConfig.primarySoftColor,
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: ThemeConfig.onlineColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '已是好友',
                      style: TextStyle(
                        color: ThemeConfig.textSecondaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    final msgController = TextEditingController();
    msgController.text = '你好，我想加你为好友 🌸';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头像
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: ThemeConfig.primaryLightColor, width: 3),
                ),
                child: ClipOval(
                  child: AvatarWidget(
                    avatar: _userInfo!['avatar'],
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '添加 ${_userInfo!['nickname'] ?? ''} 为好友',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: msgController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: '输入验证消息...',
                  filled: true,
                  fillColor: ThemeConfig.primarySoftColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          await _apiService.post('/friend/apply', data: {
                            'targetId': _userId,
                            'message': msgController.text,
                          });
                          _showMatchSuccessDialog();
                        } catch (e) {
                          Get.snackbar('提示', '发送申请失败');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('发送'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ========== 匹配成功弹窗 (AlertDialog) ==========
  void _showMatchSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 动画爱心
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF6366F1).withOpacity(0.3 * value),
                            blurRadius: 20 * value,
                            spreadRadius: 5 * value,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                '申请已发送！',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '等待 ${_userInfo!['nickname'] ?? '对方'} 通过申请',
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('返回'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/chat/detail', arguments: {
                          'targetId': _userInfo!['id'],
                          'targetName': _userInfo!['nickname'] ??
                              _userInfo!['username'],
                          'targetAvatar': _userInfo!['avatar'],
                          'chatType': 1,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('发消息'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return '在线';
      case 2:
        return '离线';
      case 3:
        return '忙碌';
      case 4:
        return '勿扰';
      default:
        return '离线';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return ThemeConfig.onlineColor;
      case 2:
        return ThemeConfig.offlineColor;
      case 3:
        return ThemeConfig.busyColor;
      default:
        return ThemeConfig.offlineColor;
    }
  }
}

class _TagItem {
  final String emoji;
  final String label;
  final Color bgColor;

  _TagItem(this.emoji, this.label, this.bgColor);
}
