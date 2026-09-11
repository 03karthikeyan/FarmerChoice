import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/vegetable_model.dart';

class VegetableCard extends StatelessWidget {
  final VegetableModel vegetable;
  final VoidCallback onTap;
  final VoidCallback onChat;

  const VegetableCard({
    super.key,
    required this.vegetable,
    required this.onTap,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final image = vegetable.images.isNotEmpty
        ? vegetable.images[0]
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(
                      width: 90,
                      height: 90,
                      color: AppColors.lightGreenBg,
                      child: const Center(
                        child: Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
                      ),
                    ),
                    errorWidget: (c, u, e) => Container(
                      width: 90,
                      height: 90,
                      color: AppColors.lightGreenBg,
                      child: const Icon(Icons.eco, color: AppColors.primaryGreen),
                    ),
                  ),
                  if (vegetable.isOrganic)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Organic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vegetable.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${vegetable.price.toStringAsFixed(0)} / ${vegetable.priceUnit}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  if (vegetable.tamilName.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      vegetable.tamilName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),

                  // Farmer line
                  Row(
                    children: [
                      const Icon(Icons.person, size: 13, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${vegetable.farmer?.name ?? 'Farmer'} • ${vegetable.farmerProfile?.district ?? 'Thanjavur'}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${vegetable.availableQuantity.toStringAsFixed(0)} ${vegetable.priceUnit} Available',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: onChat,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
