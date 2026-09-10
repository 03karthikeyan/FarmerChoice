import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/verified_badge.dart';
import '../products/add_product_screen.dart';
import '../products/farmer_products_screen.dart';
import '../deals/farmer_deals_screen.dart';
import '../../customer/chat/chat_list_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerProvider>(context, listen: false).fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final farmerProv = Provider.of<FarmerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final stats = farmerProv.stats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => farmerProv.fetchDashboardStats(),
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFE8F5E9),
                          backgroundImage: (user?.profileImage != null && user!.profileImage.isNotEmpty)
                              ? NetworkImage(user.profileImage)
                              : null,
                          child: (user?.profileImage == null || user!.profileImage.isEmpty)
                              ? const Icon(Icons.person, color: AppColors.primaryGreen, size: 26)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.name ?? 'Farmer Name',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                ),
                                const SizedBox(width: 6),
                                const VerifiedBadge(isSmall: true),
                              ],
                            ),
                            Row(
                              children: const [
                                Icon(Icons.circle, color: Colors.green, size: 8),
                                SizedBox(width: 4),
                                Text('Online • Free Direct Marketplace', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Farmer Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Direct Farmer Control',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Set your own vegetable prices. All customer inquiries and deal negotiations are 100% free with zero commission.',
                              style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 11.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sunlightYellow,
                          foregroundColor: const Color(0xFF422006),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('+ Add Crop', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Summary Stats Grid
                const Text(
                  'Farm Overview',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _StatCard(
                      title: 'My Vegetables',
                      value: '${stats['totalProducts'] ?? 0}',
                      subtitle: '${stats['availableProducts'] ?? 0} in stock',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.primaryGreen,
                    ),
                    _StatCard(
                      title: 'Customer Deals',
                      value: '${stats['activeDeals'] ?? 0}',
                      subtitle: '${stats['newRequests'] ?? 0} new requests',
                      icon: Icons.handshake_outlined,
                      color: Colors.blue.shade700,
                    ),
                    _StatCard(
                      title: 'Completed Deals',
                      value: '${stats['completedDealsCount'] ?? stats['completedDeals'] ?? 0}',
                      subtitle: 'Directly fulfilled',
                      icon: Icons.check_circle_outline,
                      color: Colors.teal.shade700,
                    ),
                    _StatCard(
                      title: 'Farmer Rating',
                      value: '${stats['rating'] ?? 5.0} ★',
                      subtitle: '${stats['totalReviews'] ?? 0} verified reviews',
                      icon: Icons.star_outline,
                      color: Colors.amber.shade800,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action Shortcuts
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.add_business_outlined,
                        title: 'Add Vegetable',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.price_change_outlined,
                        title: 'Manage Prices',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProductsScreen()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.chat_bubble_outline,
                        title: 'Customer Chat',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionTile(
                        icon: Icons.handshake_outlined,
                        title: 'Negotiate Deals',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerDealsScreen()));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMedium)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
