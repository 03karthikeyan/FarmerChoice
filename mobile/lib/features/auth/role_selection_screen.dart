import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'customer_register_screen.dart';
import 'farmer_register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final bottomInset = mediaQuery.padding.bottom;
    final isCompact = size.height < 720;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Your Role', style: TextStyle(color: AppColors.textDark),textAlign: TextAlign.center),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 6,
            bottom: bottomInset > 0 ? bottomInset + 16 : 28,
          ),
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
              SizedBox(height: isCompact ? 8 : 12),
              Text(
                'How would you like to use Farmer Choice?',
                style: TextStyle(
                  fontSize: isCompact ? 21 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select your account type to proceed. You can connect with farmers or sell fresh produce with zero platform fee.',
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  color: AppColors.textMedium,
                  height: 1.35,
                ),
              ),
              SizedBox(height: isCompact ? 18 : 26),

              // Customer Role Card
              _RoleCard(
                icon: Icons.shopping_basket_outlined,
                title: 'CUSTOMER',
                tagline: 'Buy fresh vegetables directly from farmers',
                isCompact: isCompact,
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
              SizedBox(height: isCompact ? 14 : 18),

              // Farmer Role Card
              _RoleCard(
                icon: Icons.agriculture,
                title: 'FARMER',
                tagline: 'Sell your vegetables directly to customers',
                isCompact: isCompact,
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
  final bool isCompact;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.tagline,
    required this.benefits,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
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
                  padding: EdgeInsets.all(isCompact ? 10 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryGreen,
                    size: isCompact ? 24 : 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isCompact ? 16 : 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tagline,
                        style: TextStyle(
                          fontSize: isCompact ? 11.5 : 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 10),
            Column(
              children: benefits
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: TextStyle(
                                fontSize: isCompact ? 11 : 11.5,
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
