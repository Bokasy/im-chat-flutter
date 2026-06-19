import 'package:flutter/material.dart';

class ResponsiveUtil {
  /// 判断是否为桌面/网页端（宽屏）
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  /// 判断是否为移动端（窄屏）
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= 800;
  }

  /// 获取内容区域最大宽度
  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 480;
    if (width > 800) return 420;
    return double.infinity;
  }

  /// 包装页面内容，桌面端居中显示，移动端全宽
  static Widget wrapContent(BuildContext context, Widget child) {
    if (isDesktop(context)) {
      return Center(
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: child,
        ),
      );
    }
    return child;
  }
}
