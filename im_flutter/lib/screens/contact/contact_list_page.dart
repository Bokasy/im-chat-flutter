import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/contact_controller.dart';
import 'package:im_flutter/screens/chat/chat_detail_page.dart';
import 'package:im_flutter/screens/contact/new_friend_page.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final ContactController _controller = Get.find<ContactController>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadFriends();
      _controller.loadGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: ThemeConfig.textPrimaryColor),
            decoration: InputDecoration(
              hintText: '输入用户ID或昵称搜索',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                        });
                        _controller.searchResults.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: ThemeConfig.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
              if (value.isNotEmpty) {
                _controller.searchUsers(value);
              }
            },
          ),
        ),

        // 功能入口
        if (!_isSearching)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildFunctionItem(
                  icon: Icons.person_add,
                  title: '新好友',
                  color: Colors.orange,
                  onTap: () {
                    Get.to(() => const NewFriendPage());
                  },
                ),
                _buildFunctionItem(
                  icon: Icons.group_add,
                  title: '新建群聊',
                  color: Colors.blue,
                  onTap: () {
                    Get.toNamed('/contact/group-create');
                  },
                ),
              ],
            ),
          ),

        // 群组列表
        if (!_isSearching) _buildGroupList(),

        // 好友列表或搜索结果
        Expanded(
          child: _isSearching
              ? _buildSearchResults()
              : _buildFriendList(),
        ),
      ],
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity( 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildGroupList() {
    return Obx(() {
      if (_controller.groups.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '我的群聊',
              style: TextStyle(
                fontSize: 13,
                color: ThemeConfig.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...(_controller.groups.map((group) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeConfig.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.group, color: ThemeConfig.secondaryColor),
            ),
            title: Text(group['groupName'] ?? ''),
            subtitle: Text(
              '${group['memberCount'] ?? 0}人',
              style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 12),
            ),
            onTap: () {
              Get.toNamed('/chat/detail', arguments: {
                'targetId': group['id'],
                'targetName': group['groupName'],
                'targetAvatar': group['groupAvatar'],
                'chatType': 2,
              });
            },
          ))),
          const Divider(height: 1),
        ],
      );
    });
  }

  Widget _buildFriendList() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 60, color: ThemeConfig.textSecondaryColor),
              const SizedBox(height: 16),
              Text('暂无好友', style: TextStyle(color: ThemeConfig.textSecondaryColor)),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: _controller.friends.length,
        itemBuilder: (context, index) {
          final friend = _controller.friends[index];
          return ListTile(
            leading: AvatarWidget(
              avatar: friend.avatar,
              size: 40,
            ),
            title: Text(friend.nickname ?? friend.username ?? ''),
            subtitle: Text(
              friend.signature ?? '',
              style: TextStyle(color: ThemeConfig.textSecondaryColor, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: friend.status == 1
                    ? ThemeConfig.onlineColor
                    : ThemeConfig.offlineColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              Get.toNamed('/contact/user-card', arguments: {
                'userId': friend.id,
                'isFriend': true,
              });
            },
          );
        },
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (_controller.searchResults.isEmpty) {
        return Center(
          child: Text('未找到用户', style: TextStyle(color: ThemeConfig.textSecondaryColor)),
        );
      }

      return ListView.builder(
        itemCount: _controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = _controller.searchResults[index];
          return ListTile(
            leading: AvatarWidget(avatar: user.avatar, size: 40),
            title: Text(user.nickname ?? user.username ?? ''),
            subtitle: Text(user.signature ?? ''),
            trailing: TextButton(
              onPressed: () {
                _showApplyDialog(user.id!, user.nickname ?? user.username ?? '');
              },
              child: const Text('添加'),
            ),
          );
        },
      );
    });
  }

  void _showApplyDialog(int targetId, String targetName) {
    final TextEditingController msgController = TextEditingController();
    msgController.text = '你好，我想加你为好友';

    Get.dialog(
      AlertDialog(
        title: Text('添加 $targetName'),
        content: TextField(
          controller: msgController,
          decoration: const InputDecoration(
            labelText: '验证消息',
            hintText: '请输入验证消息',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.applyFriend(targetId, msgController.text);
              Get.back();
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _showFriendApplyDialog() {
    _controller.loadFriendApplies();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Material(
          color: ThemeConfig.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '新好友申请',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (_controller.friendApplies.isEmpty) {
                    return Center(
                      child: Text('暂无新申请', style: TextStyle(color: ThemeConfig.textSecondaryColor)),
                    );
                  }

                  return ListView.builder(
                    itemCount: _controller.friendApplies.length,
                    itemBuilder: (context, index) {
                      final apply = _controller.friendApplies[index];
                      return ListTile(
                        leading: AvatarWidget(
                          avatar: apply['applicantAvatar'],
                          size: 40,
                        ),
                        title: Text(apply['applicantName'] ?? ''),
                        subtitle: Text(apply['message'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (apply['status'] == 0) ...[
                              TextButton(
                                onPressed: () => _controller.acceptApply(apply['id']),
                                child: const Text('接受'),
                              ),
                              TextButton(
                                onPressed: () => _controller.rejectApply(apply['id']),
                                child: const Text('拒绝', style: TextStyle(color: Colors.grey)),
                              ),
                            ] else
                              Text(
                                apply['status'] == 1 ? '已接受' : '已拒绝',
                                style: TextStyle(color: ThemeConfig.textSecondaryColor),
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
      ),
    );
  }
}
