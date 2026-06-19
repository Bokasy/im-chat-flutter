import 'package:intl/intl.dart';

class DateUtil {
  /// 格式化消息时间
  /// 今天显示时分，昨天显示"昨天"，更早显示日期
  static String formatMessageTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';

    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(time.year, time.month, time.day);

      if (messageDate == today) {
        // 今天，显示时分
        return DateFormat('HH:mm').format(time);
      } else if (messageDate == yesterday) {
        // 昨天
        return '昨天';
      } else if (now.difference(time).inDays < 7) {
        // 本周，显示星期几
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[time.weekday - 1];
      } else if (time.year == now.year) {
        // 今年，显示月日
        return DateFormat('MM/dd').format(time);
      } else {
        // 更早，显示年月日
        return DateFormat('yyyy/MM/dd').format(time);
      }
    } catch (e) {
      return '';
    }
  }

  /// 格式化聊天详情页的时间
  static String formatChatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';

    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(time.year, time.month, time.day);

      final timeFormat = DateFormat('HH:mm').format(time);

      if (messageDate == today) {
        return timeFormat;
      } else if (messageDate == yesterday) {
        return '昨天 $timeFormat';
      } else if (time.year == now.year) {
        return DateFormat('MM/dd HH:mm').format(time);
      } else {
        return DateFormat('yyyy/MM/dd HH:mm').format(time);
      }
    } catch (e) {
      return '';
    }
  }

  /// 是否需要显示时间（每隔5分钟显示一次）
  static bool shouldShowTime(String? currentTime, String? previousTime) {
    if (previousTime == null) return true;
    if (currentTime == null) return false;

    try {
      final current = DateTime.parse(currentTime);
      final previous = DateTime.parse(previousTime);
      return current.difference(previous).inMinutes >= 5;
    } catch (e) {
      return true;
    }
  }
}
