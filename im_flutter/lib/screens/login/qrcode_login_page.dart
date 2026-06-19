import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_flutter/config/theme_config.dart';
import 'package:im_flutter/services/api_service.dart';
import 'package:im_flutter/services/storage_service.dart';
import 'package:im_flutter/services/websocket_service.dart';
import 'package:im_flutter/widgets/responsive_wrapper.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeLoginPage extends StatefulWidget {
  const QRCodeLoginPage({super.key});

  @override
  State<QRCodeLoginPage> createState() => _QRCodeLoginPageState();
}

class _QRCodeLoginPageState extends State<QRCodeLoginPage> {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  String? _qrToken;
  String? _qrContent;
  int _status = 0;
  String _statusText = '正在生成二维码...';
  Timer? _pollTimer;
  Timer? _countdownTimer;
  int _expireSeconds = 300;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQRCode();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.get('/user/login/qrcode/generate');

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        setState(() {
          _qrToken = data['qrToken'];
          _qrContent = 'im_app://login?token=${data['qrToken']}';
          _expireSeconds = data['expiresIn'] ?? 300;
          _status = 0;
          _statusText = '请使用手机扫描二维码登录';
          _isLoading = false;
        });
        _startPolling();
      } else {
        setState(() {
          _statusText = '生成二维码失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = '网络错误，请重试';
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkQRCodeStatus();
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_expireSeconds > 0 && mounted) {
        setState(() => _expireSeconds--);
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _status = 3;
            _statusText = '二维码已过期';
          });
          _pollTimer?.cancel();
        }
      }
    });
  }

  Future<void> _checkQRCodeStatus() async {
    if (_qrToken == null) return;

    try {
      final response = await _apiService.get(
        '/user/login/qrcode/check',
        params: {'qrToken': _qrToken},
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        final status = data['status'] as int;

        setState(() {
          _status = status;
          _statusText = data['message'] ?? '';
        });

        if (status == 2) {
          _pollTimer?.cancel();
          _countdownTimer?.cancel();
          final token = data['token'];
          final userInfo = data['userInfo'];

          if (token != null) {
            await _storageService.saveToken(token);
            if (userInfo != null) {
              await _storageService.saveUserId(userInfo['id']);
              await _storageService.setUsername(userInfo['username'] ?? '');
              await _storageService.setNickname(userInfo['nickname'] ?? '');
              await _storageService.setAvatar(userInfo['avatar'] ?? '');
            }
            Get.find<WebSocketService>().connect();
            Get.offAllNamed('/chat');
            Get.snackbar('成功', '扫码登录成功');
          }
        } else if (status == 3) {
          _pollTimer?.cancel();
          _countdownTimer?.cancel();
        }
      }
    } catch (e) {
      // 静默处理
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 图标
                          Container(
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
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '扫码登录',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '使用手机APP扫描下方二维码',
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 二维码卡片
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: ThemeConfig.surfaceColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: ThemeConfig.borderColor),
                              boxShadow: ThemeConfig.softShadow,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: _isLoading
                                      ? const Center(child: CircularProgressIndicator())
                                      : _qrContent != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: QrImageView(
                                                data: _qrContent!,
                                                version: QrVersions.auto,
                                                size: 200,
                                                backgroundColor: Colors.white,
                                                eyeStyle: const QrEyeStyle(
                                                  eyeShape: QrEyeShape.square,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                dataModuleStyle: const QrDataModuleStyle(
                                                  dataModuleShape: QrDataModuleShape.square,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            )
                                          : const Center(child: Text('二维码生成失败')),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _statusText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _status == 2
                                        ? ThemeConfig.onlineColor
                                        : _status == 3
                                            ? ThemeConfig.errorColor
                                            : ThemeConfig.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_status == 0 || _status == 1)
                                  Text(
                                    '有效期: ${_formatTime(_expireSeconds)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeConfig.textSecondaryColor,
                                    ),
                                  ),
                                if (_status == 3) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: ThemeConfig.accentGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _generateQRCode,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('刷新二维码'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 操作提示
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ThemeConfig.surfaceColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ThemeConfig.borderColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '操作步骤',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: ThemeConfig.textSecondaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStep(1, '打开手机APP'),
                                _buildStep(2, '进入"我的"页面'),
                                _buildStep(3, '点击"扫一扫"'),
                                _buildStep(4, '扫描上方二维码'),
                                _buildStep(5, '在手机上确认登录'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 返回密码登录
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text(
                              '返回密码登录',
                              style: TextStyle(
                                color: ThemeConfig.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: ThemeConfig.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: ThemeConfig.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
