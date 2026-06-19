import 'package:flutter/material.dart';
import 'package:im_flutter/config/theme_config.dart';

/// 网页端自适应包装器
/// 在宽屏上居中显示为手机模拟器样式
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) {
      return Container(
        color: const Color(0xFF080C14),
        child: Center(
          child: Container(
            width: 420,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: ThemeConfig.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}
