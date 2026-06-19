class ApiConfig {
  // ============================================
  // 部署云服务器时改成服务器地址，例如: 'http://47.100.100.1:8080'
  // 本地调试用 localhost
  // ============================================
  static const String serverHost = 'http://10.192.149.46:8080';

  // 后端API地址
  static const String baseUrl = serverHost;
  static const String apiPrefix = '/api/v1';

  // WebSocket地址（自动根据 http/https 转换为 ws/wss）
  static String get wsUrl {
    final wsBase = serverHost
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsBase/ws/chat';
  }

  // 超时时间
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // 分页大小
  static const int pageSize = 20;
}
