import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'customer_register_screen.dart';
import 'farmer_register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'JOIN FARMER CHOICE',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'How would you like to use Farmer Choice?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your account type to proceed. You can connect with farmers or sell fresh produce with zero platform fee.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Customer Role Card
              _RoleCard(
                icon: Icons.shopping_basket_outlined,
                title: 'CUSTOMER',
                tagline: 'Buy fresh vegetables directly from farmers',
                benefits: const [
                  'Discover vegetables from multiple farmers',
                  'Compare price, ratings & farm distance',
                  'Chat & negotiate deals directly',
                  'Zero middleman commission',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerRegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Farmer Role Card
              _RoleCard(
                icon: Icons.agriculture,
                title: 'FARMER',
                tagline: 'Sell your vegetables directly to customers',
                benefits: const [
                  'List your harvested vegetables for free',
                  'Set your own selling price anytime',
                  'Receive direct inquiries & deals',
                  'Build verified farmer reputation',
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerRegisterScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tagline;
  final List<String> benefits;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.tagline,
    required this.benefits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        tagline,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 10),
            Column(
              children: benefits
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.primaryLight),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
