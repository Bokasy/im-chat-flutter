import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/contact_controller.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final ContactController _contactController = Get.find<ContactController>();
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _nameController = TextEditingController();

  final Set<int> _selectedUserIds = {};
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contactController.loadFriends();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      Get.snackbar('提示', '请输入群名称');
      return;
    }
    if (_selectedUserIds.isEmpty) {
      Get.snackbar('提示', '请选择至少一位成员');
      return;
    }

    setState(() => _isCreating = true);

    try {
      final response = await _apiService.post('/group/create', data: {
        'groupName': groupName,
        'memberIds': _selectedUserIds.toList(),
      });

      if (response.data['code'] == 200) {
        final groupData = response.data['data'];
        Get.back();
        Get.snackbar('成功', '群聊创建成功');

        // 刷新群组列表
        Get.find<ContactController>().loadGroups();

        // 跳转到群聊页面
        Get.toNamed('/chat/detail', arguments: {
          'targetId': groupData['id'],
          'targetName': groupData['groupName'],
          'targetAvatar': groupData['groupAvatar'],
          'chatType': 2,
        });
      } else {
        Get.snackbar('失败', response.data['message'] ?? '创建失败');
      }
    } catch (e) {
      Get.snackbar('错误', '创建群聊失败: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
        title: const Text('创建群聊'),
        backgroundColor: ThemeConfig.surfaceColor,
        foregroundColor: ThemeConfig.textPrimaryColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '创建',
                    style: TextStyle(
                      color: ThemeConfig.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 群名称输入
          Container(
            padding: const EdgeInsets.all(16),
            color: ThemeConfig.surfaceColor,
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '群名称',
                hintText: '请输入群聊名称',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 20,
            ),
          ),

          // 已选成员
          if (_selectedUserIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: ThemeConfig.surfaceColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选成员 (${_selectedUserIds.length})',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeConfig.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: Obx(() {
                      final selectedFriends = _contactController.friends
                          .where((f) => _selectedUserIds.contains(f.id))
                          .toList();

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFriends.length,
                        itemBuilder: (context, index) {
                          final friend = selectedFriends[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    AvatarWidget(
                                      avatar: friend.avatar,
                                      size: 44,
                                    ),
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedUserIds.remove(friend.id);
                                          });
                                        },
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  friend.nickname ?? '',
                                  style: const TextStyle(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // 选择成员标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '好友列表',
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // 好友列表
          Expanded(
            child: Obx(() {
              if (_contactController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_contactController.friends.isEmpty) {
                return Center(
                  child: Text(
                    '暂无好友，请先添加好友',
                    style: TextStyle(color: ThemeConfig.textSecondaryColor),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _contactController.friends.length,
                itemBuilder: (context, index) {
                  final friend = _contactController.friends[index];
                  final isSelected = _selectedUserIds.contains(friend.id);

                  return ListTile(
                    leading: AvatarWidget(
                      avatar: friend.avatar,
                      size: 44,
                    ),
                    title: Text(
                      friend.nickname ?? friend.username ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      friend.signature ?? '',
                      style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: ThemeConfig.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.add(friend.id!);
                          } else {
                            _selectedUserIds.remove(friend.id);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedUserIds.remove(friend.id);
                        } else {
                          _selectedUserIds.add(friend.id!);
                        }
                      });
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      ),
    );
  }
}
