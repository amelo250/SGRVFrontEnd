import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';

class AppLogo extends StatelessWidget {
  final bool compact;
  final Color? color;
  final String? imageUrl;
  final String title;

  const AppLogo({
    super.key,
    this.compact = false,
    this.color,
    this.imageUrl,
    this.title = 'SGRV',
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 50,
          height: compact ? 38 : 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              colors: [AppColors.secondary, Color(0xFF2F9DFF)],
            ),
          ),
          child: imageUrl?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: FutureBuilder<String?>(
                    future: TokenStorage.getToken(),
                    builder: (_, token) => Image.network(
                      imageUrl!.startsWith('http')
                          ? imageUrl!
                          : '${ApiConfig.baseUrl}$imageUrl',
                      fit: BoxFit.cover,
                      headers: token.data == null
                          ? null
                          : {'Authorization': 'Bearer ${token.data}'},
                      errorBuilder: (_, _, _) => Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: compact ? 23 : 30,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: compact ? 23 : 30,
                ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: foreground,
                fontSize: compact ? 19 : 31,
                fontWeight: FontWeight.w800,
                letterSpacing: .4,
              ),
            ),
            Text(
              'RENT CAR',
              style: TextStyle(
                color: compact ? AppColors.primary : const Color(0xFF58B8FF),
                fontSize: compact ? 9 : 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
