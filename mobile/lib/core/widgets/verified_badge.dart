import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final String text;
  final bool isSmall;

  const VerifiedBadge({
    super.key,
    this.text = 'Verified Farmer',
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: AppColors.primaryGreen,
            size: isSmall ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
