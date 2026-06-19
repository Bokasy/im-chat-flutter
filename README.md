# 基于 Flutter 的即时通信 APP

一个基于 Flutter + Spring Boot 的跨平台即时通信应用，支持 Android/iOS/Web 三端运行。

## 功能特性

- ✅ 用户注册/登录（JWT 鉴权）
- ✅ 扫码登录（Web 端）
- ✅ 好友搜索/申请/审核/管理
- ✅ 私聊实时消息（WebSocket）
- ✅ 群聊消息广播
- ✅ 消息撤回（2分钟内）
- ✅ 消息转发/回复引用
- ✅ 消息已读状态
- ✅ 输入状态提示
- ✅ 会话管理（置顶/免打扰/归档）
- ✅ 消息搜索（关键词高亮）
- ✅ 图片发送（压缩上传）
- ✅ 离线消息存储
- ✅ 用户资料编辑（头像/标签）

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Flutter + GetX + Dio + WebSocket |
| 后端 | Spring Boot 3.2 + MyBatis-Plus |
| 数据库 | MySQL 8.0 + Redis |
| 认证 | JWT Token |
| API 文档 | Swagger / SpringDoc |

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.8+
- MySQL 8.0+
- Redis 6.0+
- Flutter SDK 3.0+

### 1. 初始化数据库

```sql
-- 执行 im-backend/src/main/resources/db/init.sql
```

### 2. 启动后端

```bash
cd im-backend
# 修改 application.yml 中的数据库密码
mvn spring-boot:run
```

后端启动后访问 Swagger 文档：http://localhost:8080/swagger-ui.html

### 3. 启动前端

```bash
cd im_flutter
flutter pub get

# Web 端
flutter run -d chrome

# Android
flutter run -d <device-id>
```

### 4. 修改配置

编辑 `im_flutter/lib/config/api_config.dart`，将 `serverHost` 改为后端地址：

```dart
// 本地调试
static const String serverHost = 'http://localhost:8080';

// 手机端调试（同一WiFi）
static const String serverHost = 'http://192.168.x.x:8080';
```

## 测试账号

| 用户名 | 密码 | 用户ID |
|--------|------|--------|
| zhangsan | 123456 | 10000001 |
| lisi | 123456 | 10000002 |
| wangwu | 123456 | 10000003 |

## 项目结构

```
flutter_pro/
├── im-backend/                # Spring Boot 后端
│   ├── src/main/java/com/im/
│   │   ├── controller/        # REST API 控制器
│   │   ├── service/           # 业务逻辑层
│   │   ├── entity/            # 数据库实体
│   │   ├── mapper/            # MyBatis Mapper
│   │   ├── websocket/         # WebSocket 处理器
│   │   └── config/            # 配置类
│   └── src/main/resources/
│       ├── db/init.sql        # 数据库初始化脚本
│       └── application.yml    # 应用配置
├── im_flutter/                # Flutter 前端
│   ├── lib/
│   │   ├── screens/           # 页面
│   │   ├── controllers/       # GetX 控制器
│   │   ├── services/          # 网络/存储服务
│   │   ├── models/            # 数据模型
│   │   ├── widgets/           # 公共组件
│   │   └── config/            # 配置文件
│   └── pubspec.yaml           # 依赖配置
├── 答辩演示文档.md              # 答辩演示指南
├── 综合设计报告.md              # 项目设计报告
└── 开发问题记录.md              # 开发过程问题记录
```

## 截图

> 待补充

## License

MIT
