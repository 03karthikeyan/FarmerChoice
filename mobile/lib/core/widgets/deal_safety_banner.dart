import 'package:flutter/material.dart';

class DealSafetyBanner extends StatelessWidget {
  const DealSafetyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.handshake_outlined,
            color: Color(0xFFE65100),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trust & Verify — Direct Farmer Connection',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBF360C),
                    letterSpacing: 0.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Farmer Choice connects you directly with farmers. We do not process or guarantee payments. We recommend direct farm visits or paying in person after confirming quality and delivery.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5D4037),
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
