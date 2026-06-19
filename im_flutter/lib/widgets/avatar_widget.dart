import 'package:flutter/material.dart';
import 'package:im_flutter/config/theme_config.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatar;
  final double size;
  final Color? borderColor;
  final double? borderWidth;
  final bool showOnline;
  final bool isOnline;

  const AvatarWidget({
    super.key,
    this.avatar,
    this.size = 40,
    this.borderColor,
    this.borderWidth,
    this.showOnline = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 2)
            : null,
      ),
      child: ClipOval(
        child: avatar != null && avatar!.isNotEmpty
            ? Image.network(
                avatar!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ThemeConfig.primaryLightColor.withOpacity(0.3),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: ThemeConfig.primaryColor,
      ),
    );
  }
}
