import 'package:flutter/material.dart';

class ThemeConfig {
  // ========== 主色调 - 深邃高级感 ==========
  static const Color primaryColor = Color(0xFF6366F1);        // 靛蓝主色
  static const Color primaryLightColor = Color(0xFF818CF8);   // 浅靛蓝
  static const Color primaryDarkColor = Color(0xFF4F46E5);    // 深靛蓝
  static const Color primarySoftColor = Color(0xFF1E1B4B);    // 暗紫底色

  // 辅助色
  static const Color accentColor = Color(0xFF06B6D4);         // 青色强调
  static const Color secondaryColor = Color(0xFFA78BFA);      // 紫色辅助
  static const Color goldColor = Color(0xFFF59E0B);           // 金色点缀
  static const Color backgroundColor = Color(0xFF0F172A);     // 深色背景
  static const Color surfaceColor = Color(0xFF1E293B);        // 卡片背景
  static const Color cardColor = Color(0xFF1E293B);

  // 文字颜色
  static const Color textPrimaryColor = Color(0xFFF1F5F9);    // 主文字-亮白
  static const Color textSecondaryColor = Color(0xFF94A3B8);  // 次文字-银灰
  static const Color textTertiaryColor = Color(0xFF64748B);   // 辅助文字

  // 边框和分割线
  static const Color borderColor = Color(0xFF334155);
  static const Color dividerColor = Color(0xFF1E293B);

  // 消息气泡颜色
  static const Color messageSentColor = Color(0xFF4F46E5);    // 发送-靛蓝
  static const Color messageReceivedColor = Color(0xFF1E293B); // 接收-深灰

  // 在线状态颜色
  static const Color onlineColor = Color(0xFF22C55E);
  static const Color offlineColor = Color(0xFF64748B);
  static const Color busyColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // ========== 渐变 ==========
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== 阴影 ==========
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: const Color(0xFF6366F1).withOpacity(0.3),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  // ========== 暗色主题 ==========
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrimaryColor),
    ),

    // Card
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLightColor,
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textTertiaryColor),
      labelStyle: const TextStyle(color: textSecondaryColor),
      prefixIconColor: textSecondaryColor,
      suffixIconColor: textSecondaryColor,
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textColor: textPrimaryColor,
      iconColor: textSecondaryColor,
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiaryColor,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: textSecondaryColor,
        fontSize: 15,
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF334155),
      contentTextStyle: const TextStyle(color: textPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: primaryColor,
      labelStyle: const TextStyle(color: textPrimaryColor, fontSize: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(color: borderColor),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    // BottomSheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // TabBar
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: textTertiaryColor,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );

  // 亮色主题（备用）
  static ThemeData lightTheme = darkTheme;
}
