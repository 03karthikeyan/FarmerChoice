import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final String status; // 'VERIFIED', 'PENDING', 'REJECTED'
  final String? text;
  final bool isSmall;
  final bool? showLabel;

  const VerifiedBadge({
    super.key,
    this.status = 'VERIFIED',
    this.text,
    this.isSmall = false,
    this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toUpperCase().trim();

    Color bgColor;
    Color borderColor;
    Color contentColor;
    IconData icon;
    String defaultLabel;

    switch (normalizedStatus) {
      case 'VERIFIED':
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFFA5D6A7);
        contentColor = const Color(0xFF1B5E20);
        icon = Icons.verified_rounded;
        defaultLabel = 'Verified';
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFFCDD2);
        contentColor = const Color(0xFFD32F2F);
        icon = Icons.cancel_rounded;
        defaultLabel = 'Rejected';
        break;
      case 'PENDING':
      default:
        bgColor = const Color(0xFFFFF8E1);
        borderColor = const Color(0xFFFFE082);
        contentColor = const Color(0xFFB78103);
        icon = Icons.schedule_rounded;
        defaultLabel = 'Pending';
        break;
    }

    final displayText = text ?? defaultLabel;
    final shouldShowLabel = showLabel ?? true;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 7 : 9,
        vertical: isSmall ? 2.5 : 4.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: contentColor,
            size: isSmall ? 13 : 15,
          ),
          if (shouldShowLabel && displayText.isNotEmpty) ...[
            const SizedBox(width: 4.5),
            Text(
              displayText,
              style: TextStyle(
                color: contentColor,
                fontSize: isSmall ? 10.5 : 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
