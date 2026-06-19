import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/widgets/avatar_widget.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';

class NewFriendPage extends StatefulWidget {
  const NewFriendPage({super.key});

  @override
  State<NewFriendPage> createState() => _NewFriendPageState();
}

class _NewFriendPageState extends State<NewFriendPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = Get.find<ApiService>();
  late TabController _tabController;

  List<dynamic> _pendingList = [];
  List<dynamic> _processedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplyList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApplyList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载待处理申请
      final pendingResponse = await _apiService.get(
        '/friend/apply/list',
        params: {'status': 0},
      );

      // 加载已处理申请
      final processedResponse = await _apiService.get(
        '/friend/apply/list',
        params: {'status': 1},
      );

      if (pendingResponse.data['code'] == 200) {
        _pendingList = pendingResponse.data['data'] ?? [];
      }

      if (processedResponse.data['code'] == 200) {
        _processedList = processedResponse.data['data'] ?? [];
      }
    } catch (e) {
      print('加载好友申请列表失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptApply(int applyId) async {
    try {
      final response = await _apiService.post(
        '/friend/apply/accept',
        data: {'applyId': applyId},
      );

      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已接受好友申请');
        _loadApplyList();
      } else {
        Get.snackbar('失败', response.data['message'] ?? '操作失败');
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }

  Future<void> _rejectApply(int applyId) async {
    try {
      final response = await _apiService.post(
        '/friend/apply/reject',
        data: {'applyId': applyId},
      );

      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已拒绝好友申请');
        _loadApplyList();
      } else {
        Get.snackbar('失败', response.data['message'] ?? '操作失败');
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }

  Future<void> _ignoreApply(int applyId) async {
    try {
      final response = await _apiService.post(
        '/friend/apply/ignore',
        data: {'applyId': applyId},
      );

      if (response.data['code'] == 200) {
        Get.snackbar('成功', '已忽略好友申请');
        _loadApplyList();
      } else {
        Get.snackbar('失败', response.data['message'] ?? '操作失败');
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('新好友申请'),
          backgroundColor: ThemeConfig.surfaceColor,
          foregroundColor: ThemeConfig.textPrimaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ThemeConfig.primaryColor,
          tabs: const [
            Tab(text: '待处理'),
            Tab(text: '已处理'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingList(),
                _buildProcessedList(),
              ],
            ),
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: ThemeConfig.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无待处理的好友申请',
              style: TextStyle(
                color: ThemeConfig.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplyList,
      child: ListView.builder(
        itemCount: _pendingList.length,
        itemBuilder: (context, index) {
          final apply = _pendingList[index];
          return _buildPendingItem(apply);
        },
      ),
    );
  }

  Widget _buildProcessedList() {
    if (_processedList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: ThemeConfig.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无已处理的好友申请',
              style: TextStyle(
                color: ThemeConfig.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplyList,
      child: ListView.builder(
        itemCount: _processedList.length,
        itemBuilder: (context, index) {
          final apply = _processedList[index];
          return _buildProcessedItem(apply);
        },
      ),
    );
  }

  Widget _buildPendingItem(Map<String, dynamic> apply) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: apply['applicantAvatar'],
            size: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apply['applicantName'] ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apply['message'] ?? '请求添加你为好友',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  apply['createTime'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _acceptApply(apply['id']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('接受', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _rejectApply(apply['id']),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      '拒绝',
                      style: TextStyle(
                        color: ThemeConfig.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _ignoreApply(apply['id']),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      '忽略',
                      style: TextStyle(
                        color: ThemeConfig.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedItem(Map<String, dynamic> apply) {
    final status = apply['status'] ?? 0;
    String statusText;
    Color statusColor;

    switch (status) {
      case 1:
        statusText = '已接受';
        statusColor = Colors.green;
        break;
      case 2:
        statusText = '已拒绝';
        statusColor = Colors.red;
        break;
      case 3:
        statusText = '已忽略';
        statusColor = Colors.grey;
        break;
      default:
        statusText = '未知';
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: apply['applicantAvatar'],
            size: 50,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apply['applicantName'] ?? '未知用户',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  apply['message'] ?? '请求添加你为好友',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  apply['createTime'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeConfig.textTertiaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
