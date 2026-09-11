import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/vegetable_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/widgets/vegetable_card.dart';
import '../../../core/widgets/deal_safety_banner.dart';
import '../vegetables/vegetable_detail_screen.dart';
import '../chat/chat_screen.dart';
import '../../notifications/notification_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vegProvider = Provider.of<VegetableProvider>(context);

    final categories = ['All', 'Leafy', 'Root', 'Vegetable', 'Other'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              vegProvider.fetchVegetables(),
              context.read<NotificationProvider>().fetchUnreadCount(),
            ]);
          },
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreenBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset('assets/icons/app_icon.png', width: 26, height: 26),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farmer Choice',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Direct from Farmers 🌱',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<NotificationProvider>(
                          builder: (context, notifProv, _) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderLight),
                                    ),
                                    child: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 20),
                                  ),
                                  if (notifProv.unreadCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentRed,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          '${notifProv.unreadCount}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            authProvider.currentUser?.name.isNotEmpty == true
                                ? authProvider.currentUser!.name.substring(0, 1).toUpperCase()
                                : 'C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Hero Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Fresh Vegetables Directly from Farmers',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Zero Middlemen • Fair Price • 100% Free',
                              style: TextStyle(
                                color: Color(0xFFC8E6C9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.agriculture, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => vegProvider.setSearchQuery(val),
                    decoration: const InputDecoration(
                      hintText: 'Search fresh vegetables (Tomato, Palak, Onion)...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
                      prefixIcon: Icon(Icons.search, color: AppColors.primaryGreen),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Zero Payment Notice
                const DealSafetyBanner(),
                const SizedBox(height: 20),

                // Categories
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = vegProvider.selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => vegProvider.setCategory(cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Featured Vegetables Carousel (if any)
                if (vegProvider.featuredVegetables.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Featured Products',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Verified Farms',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 165,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vegProvider.featuredVegetables.length,
                      itemBuilder: (context, index) {
                        final veg = vegProvider.featuredVegetables[index];
                        return _FeaturedCard(
                          vegetable: veg,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VegetableDetailScreen(vegetableId: veg.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Fresh Vegetables Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fresh Vegetables',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${vegProvider.filteredVegetables.length} Available',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vegetables List
                if (vegProvider.isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                else if (vegProvider.filteredVegetables.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.eco_outlined, size: 40, color: AppColors.textLight),
                        SizedBox(height: 10),
                        Text(
                          'No vegetables available matching your filter.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vegProvider.filteredVegetables.length,
                    itemBuilder: (context, index) {
                      final veg = vegProvider.filteredVegetables[index];
                      return VegetableCard(
                        vegetable: veg,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VegetableDetailScreen(vegetableId: veg.id),
                            ),
                          );
                        },
                        onChat: () async {
                          if (veg.farmer != null && authProvider.currentUser != null) {
                            final chatProv = Provider.of<ChatProvider>(context, listen: false);
                            final convId = await chatProv.openConversation(
                              farmerId: veg.farmer!.id,
                              customerId: authProvider.currentUser!.id,
                              vegetableId: veg.id,
                            );
                            if (convId != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    conversationId: convId,
                                    recipientName: veg.farmer!.name,
                                    vegetableName: veg.name,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final dynamic vegetable;
  final VoidCallback onTap;

  const _FeaturedCard({required this.vegetable, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = vegetable.images.isNotEmpty
        ? vegetable.images[0]
        : 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 85,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(color: AppColors.lightGreenBg),
                errorWidget: (c, u, e) => Container(color: AppColors.lightGreenBg, child: const Icon(Icons.eco)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vegetable.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${vegetable.price.toStringAsFixed(0)} / ${vegetable.priceUnit}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
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
