import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';
import 'package:im_flutter/utils/date_util.dart';

class MessageSearchPage extends StatefulWidget {
  const MessageSearchPage({super.key});

  @override
  State<MessageSearchPage> createState() => _MessageSearchPageState();
}

class _MessageSearchPageState extends State<MessageSearchPage> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMessages() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      Get.snackbar('提示', '请输入搜索关键词');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final response = await _apiService.get(
        '/chat/history/search',
        params: {'keyword': keyword},
      );

      if (response.data['code'] == 200) {
        if (mounted) {
          setState(() {
            _searchResults = response.data['data'] ?? [];
          });
        }
      } else {
        Get.snackbar('失败', response.data['message'] ?? '搜索失败');
      }
    } catch (e) {
      Get.snackbar('错误', '搜索失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToChat(Map<String, dynamic> message) {
    final targetId = message['senderId'] ?? message['receiverId'];
    final targetName = message['senderName'] ?? '未知用户';
    final targetAvatar = message['senderAvatar'];

    Get.toNamed('/chat/detail', arguments: {
      'targetId': targetId,
      'targetName': targetName,
      'targetAvatar': targetAvatar,
      'chatType': message['chatType'] ?? 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeConfig.surfaceColor,
          foregroundColor: ThemeConfig.textPrimaryColor,
          elevation: 0,
          title: TextField(
            controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索聊天记录...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: ThemeConfig.textTertiaryColor),
          ),
          onSubmitted: (_) => _searchMessages(),
        ),
        actions: [
          TextButton(
            onPressed: _searchMessages,
            child: const Text(
              '搜索',
              style: TextStyle(
                color: ThemeConfig.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasSearched
              ? _buildSearchResults()
              : _buildSearchTips(),
      ),
    );
  }

  Widget _buildSearchTips() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: ThemeConfig.textSecondaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            '搜索聊天记录',
            style: TextStyle(
              fontSize: 18,
              color: ThemeConfig.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '输入关键词搜索消息内容',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConfig.textTertiaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: ThemeConfig.textSecondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              '未找到相关消息',
              style: TextStyle(
                fontSize: 18,
                color: ThemeConfig.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试使用其他关键词搜索',
              style: TextStyle(
                fontSize: 14,
                color: ThemeConfig.textTertiaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '找到 ${_searchResults.length} 条结果',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final message = _searchResults[index];
              return _buildSearchResultItem(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> message) {
    final keyword = _searchController.text.trim();
    final content = message['content'] ?? '';
    final senderName = message['senderName'] ?? '未知用户';
    final senderAvatar = message['senderAvatar'];
    final createTime = message['createTime'] ?? '';

    // 高亮关键词
    final contentSpans = _highlightText(content, keyword);
    final nameSpans = _highlightText(senderName, keyword);

    return InkWell(
      onTap: () => _navigateToChat(message),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ThemeConfig.borderColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(
              avatar: senderAvatar,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: nameSpans.map((span) {
                              return TextSpan(
                                text: span['text'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: span['isHighlight']
                                      ? ThemeConfig.primaryColor
                                      : ThemeConfig.textPrimaryColor,
                                ),
                              );
                            }).toList(),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateUtil.formatMessageTime(createTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeConfig.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: contentSpans.map((span) {
                        return TextSpan(
                          text: span['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: span['isHighlight']
                                ? ThemeConfig.primaryColor
                                : ThemeConfig.textSecondaryColor,
                            fontWeight: span['isHighlight']
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _highlightText(String text, String keyword) {
    if (keyword.isEmpty) {
      return [{'text': text, 'isHighlight': false}];
    }

    final List<Map<String, dynamic>> spans = [];
    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerKeyword, start);

    while (index != -1) {
      // 添加关键词前的文本
      if (index > start) {
        spans.add({
          'text': text.substring(start, index),
          'isHighlight': false,
        });
      }

      // 添加高亮的关键词
      spans.add({
        'text': text.substring(index, index + keyword.length),
        'isHighlight': true,
      });

      start = index + keyword.length;
      index = lowerText.indexOf(lowerKeyword, start);
    }

    // 添加剩余的文本
    if (start < text.length) {
      spans.add({
        'text': text.substring(start),
        'isHighlight': false,
      });
    }

    return spans;
  }
}
