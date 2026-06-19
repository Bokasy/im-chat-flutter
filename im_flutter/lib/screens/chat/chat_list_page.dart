import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/controllers/auth_controller.dart';
import 'package:im_flutter/controllers/chat_controller.dart';
import 'package:im_flutter/screens/chat/chat_detail_page.dart';
import 'package:im_flutter/screens/chat/message_search_page.dart';
import 'package:im_flutter/screens/contact/contact_list_page.dart';
import 'package:im_flutter/screens/profile/profile_page.dart';
import 'package:im_flutter/utils/date_util.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatController _chatController = Get.find<ChatController>();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _ChatListView(),
    const ContactListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: ThemeConfig.backgroundColor,
        appBar: AppBar(
          title: Text(
            _currentIndex == 0
                ? '消息'
                : _currentIndex == 1
                  ? '通讯录'
                  : '我的',
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 22),
              onPressed: () {
                Get.to(() => const MessageSearchPage());
              },
            ),
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.edit_square, size: 22),
              onPressed: _showNewChatMenu,
            ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ThemeConfig.borderColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Obx(() {
                final hasUnread = _chatController.sessions
                    .any((s) => (s.unreadCount ?? 0) > 0);
                return Badge(
                  isLabelVisible: hasUnread,
                  label: Text(
                    '${_chatController.sessions.fold(0, (sum, s) => sum + (s.unreadCount ?? 0))}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                );
              }),
              activeIcon: const Icon(Icons.chat_bubble_rounded),
              label: '聊天',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: '通讯录',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: '我的',
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showNewChatMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                _buildMenuOption(
                  icon: Icons.chat_bubble_outline,
                  label: '发起私聊',
                  color: ThemeConfig.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/contact');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.group_add_outlined,
                  label: '创建群聊',
                  color: ThemeConfig.secondaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/contact/group-create');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.person_add_outlined,
                  label: '添加好友',
                  color: ThemeConfig.accentColor,
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/contact');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Obx(() {
      if (controller.sessions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeConfig.primaryColor.withOpacity(0.1),
                      ThemeConfig.primaryLightColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 48,
                  color: ThemeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '还没有消息',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '去通讯录找好友聊天吧',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeConfig.textSecondaryColor,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadSessions(),
        color: ThemeConfig.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.sessions.length,
          itemBuilder: (context, index) {
            final session = controller.sessions[index];
            return _buildSessionItem(context, session, controller);
          },
        ),
      );
    });
  }

  Widget _buildSessionItem(
      BuildContext context, dynamic session, ChatController controller) {
    return Dismissible(
      key: Key(session.id?.toString() ?? session.targetId.toString()),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeConfig.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.push_pin_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeConfig.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (session.id != null) {
            controller.pinSession(session.id!, true);
          }
          return false;
        } else {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('删除会话'),
              content: const Text('确定要删除这个会话吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (session.id != null) {
                      controller.deleteSession(session.id!);
                    }
                    Navigator.pop(context, true);
                  },
                  style: TextButton.styleFrom(foregroundColor: ThemeConfig.errorColor),
                  child: const Text('删除'),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              Hero(
                tag: 'avatar_${session.targetId}',
                child: AvatarWidget(
                  avatar: session.targetAvatar,
                  size: 52,
                ),
              ),
              if (session.chatType == 2)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: ThemeConfig.secondaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.group, size: 10, color: Colors.white),
                  ),
                )
              else if (session.onlineStatus == 1)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ThemeConfig.onlineColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  session.targetName ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateUtil.formatMessageTime(session.lastMsgTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeConfig.textTertiaryColor,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    session.lastMsgContent ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ((session.unreadCount ?? 0) > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${session.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onTap: () {
            Get.to(() => const ChatDetailPage(), arguments: {
              'targetId': session.targetId,
              'targetName': session.targetName,
              'targetAvatar': session.targetAvatar,
              'chatType': session.chatType ?? 1,
            });
          },
        ),
        ),
      ),
    );
  }
}
