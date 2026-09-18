import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/farmer_profile_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/vegetable_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/widgets/vegetable_card.dart';
import '../../../core/widgets/promo_slider_banner.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../vegetables/vegetable_detail_screen.dart';
import '../farmers/farmer_profile_screen.dart';
import '../../notifications/notification_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _districts = [
    'All',
    'Thanjavur',
    'Madurai',
    'Coimbatore',
    'Salem',
    'Tiruchirappalli',
    'Tirunelveli',
    'Erode',
    'Dindigul',
    'Chennai',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vegProvider = Provider.of<VegetableProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final district = auth.currentUser?.district;
      if (district != null && district.isNotEmpty) {
        vegProvider.fetchNearbyFarmers(district: district);
      } else {
        vegProvider.fetchNearbyFarmers();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final vegProvider = Provider.of<VegetableProvider>(context, listen: false);
      if (vegProvider.hasMore && !vegProvider.isLoadingMore) {
        vegProvider.loadMoreVegetables();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context, VegetableProvider vegProvider) {
    String tempCategory = vegProvider.selectedCategory;
    String tempDistrict = vegProvider.selectedDistrict;
    String tempSortBy = vegProvider.sortBy;
    double tempMaxPrice = vegProvider.maxPrice ?? 200;
    bool tempOnlyOrganic = vegProvider.onlyOrganic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.tune_rounded, color: Color(0xFF176B2C), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Filter & Sort Vegetables',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          vegProvider.resetFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Sort By
                  const Text('Sort By', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _choiceChip('Newest First', tempSortBy == 'newest', () => setModalState(() => tempSortBy = 'newest')),
                      _choiceChip('Lowest Price 🏷️', tempSortBy == 'lowest_price', () => setModalState(() => tempSortBy = 'lowest_price')),
                      _choiceChip('Highest Price', tempSortBy == 'highest_price', () => setModalState(() => tempSortBy = 'highest_price')),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // District / Location
                  const Text('District / Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempDistrict,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF176B2C)),
                        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => tempDistrict = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Max Price Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maximum Price / Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      Text('Up to ₹${tempMaxPrice.toInt()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF176B2C))),
                    ],
                  ),
                  Slider(
                    value: tempMaxPrice,
                    min: 20,
                    max: 300,
                    divisions: 28,
                    activeColor: const Color(0xFF176B2C),
                    inactiveColor: const Color(0xFFC8E6C9),
                    onChanged: (val) => setModalState(() => tempMaxPrice = val),
                  ),
                  const SizedBox(height: 10),

                  // 100% Organic Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('100% Organic Certified Only 🌱', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    subtitle: const Text('Only show chemical-free naturally grown harvest', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                    value: tempOnlyOrganic,
                    activeColor: const Color(0xFF176B2C),
                    onChanged: (val) => setModalState(() => tempOnlyOrganic = val),
                  ),
                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        vegProvider.applyAdvancedFilters(
                          category: tempCategory,
                          district: tempDistrict,
                          maxPrice: tempMaxPrice,
                          onlyOrganic: tempOnlyOrganic,
                          sortBy: tempSortBy,
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176B2C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _choiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF176B2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF176B2C) : const Color(0xFFCCDACC)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final vegProvider = Provider.of<VegetableProvider>(context);
    final user = authProvider.currentUser;

    final categories = ['All', 'Leafy', 'Root', 'Vegetable', 'Other'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              vegProvider.fetchVegetables(refresh: true),
              vegProvider.fetchNearbyFarmers(district: user?.district),
              context.read<NotificationProvider>().fetchUnreadCount(),
            ]);
          },
          color: const Color(0xFF176B2C),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset('assets/images/app_icon.png', width: 26, height: 26),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farmer Choice',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: const Color(0xFF1B381E),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Color(0xFF176B2C)),
                                const SizedBox(width: 2),
                                Text(
                                  user?.district.isNotEmpty == true ? '${user?.villageOrTown ?? ''}, ${user?.district}' : 'Tamil Nadu Farms 🌱',
                                  style: const TextStyle(
                                    color: Color(0xFF176B2C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                                    child: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 20),
                                  ),
                                  if (notifProv.unreadCount > 0)
                                    Positioned(
                                      top: -3,
                                      right: -3,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentRed,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
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
                          radius: 17,
                          backgroundColor: const Color(0xFF176B2C),
                          backgroundImage: (user?.profileImage != null && user!.profileImage.isNotEmpty)
                              ? NetworkImage(user.profileImage)
                              : null,
                          child: (user?.profileImage == null || user!.profileImage.isEmpty)
                              ? Text(
                                  user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'C',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Promotional Slider Banner (Deal Safety & Fresh Produce Guarantee)
                const PromoSliderBanner(),
                const SizedBox(height: 16),

                // Search Bar + Filter Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => vegProvider.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search vegetables (Tomato, Onion, Palak)...',
                            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textLight),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF176B2C), size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      vegProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _showFilterModal(context, vegProvider),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (vegProvider.onlyOrganic || vegProvider.selectedDistrict != 'All' || vegProvider.maxPrice != null)
                              ? const Color(0xFF176B2C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCCDACC)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (vegProvider.onlyOrganic || vegProvider.selectedDistrict != 'All' || vegProvider.maxPrice != null)
                              ? Colors.white
                              : const Color(0xFF176B2C),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Category Chips
                SizedBox(
                  height: 36,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF176B2C) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF176B2C) : const Color(0xFFCCDACC),
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
                const SizedBox(height: 20),

                // Dynamic Nearby Verified Farmers Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.agriculture_rounded, color: Color(0xFF176B2C), size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Nearby Verified Farmers',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    Text(
                      user?.district.isNotEmpty == true ? user!.district : 'Tamil Nadu',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF176B2C)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nearby Farmers Horizontal List / Shimmer
                if (vegProvider.isLoadingFarmers)
                  Shimmer(
                    child: SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) => const FarmerCardSkeleton(),
                      ),
                    ),
                  )
                else if (vegProvider.nearbyFarmers.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vegProvider.nearbyFarmers.length,
                      itemBuilder: (context, index) {
                        final farmer = vegProvider.nearbyFarmers[index];
                        return _NearbyFarmerCard(
                          farmer: farmer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FarmerProfileScreen(
                                  farmerId: farmer.userId.isNotEmpty ? farmer.userId : farmer.id,
                                  initialProfile: farmer,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.nature_people_outlined, color: Color(0xFF176B2C), size: 20),
                        SizedBox(width: 8),
                        Text('Farmers from all districts active on platform', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Fresh Products Feed Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fresh Harvest & Products',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      '${vegProvider.filteredVegetables.length} Available',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF176B2C)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Products List / Shimmer Loading
                if (vegProvider.isLoading && vegProvider.allVegetables.isEmpty)
                  Shimmer(
                    child: Column(
                      children: List.generate(4, (_) => const VegetableCardSkeleton()),
                    ),
                  )
                else if (vegProvider.filteredVegetables.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.eco_outlined, size: 52, color: Color(0xFFC8E6C9)),
                        const SizedBox(height: 12),
                        const Text(
                          'No vegetables found matching your filters.',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try clearing search query or resetting filters.',
                          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => vegProvider.resetFilters(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF176B2C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Reset All Filters', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
                              builder: (_) => VegetableDetailScreen(
                                vegetableId: veg.id,
                                initialVegetable: veg,
                              ),
                            ),
                          );
                        },
                        onChat: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VegetableDetailScreen(
                                vegetableId: veg.id,
                                initialVegetable: veg,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                // Infinite Scroll Pagination Loader
                if (vegProvider.isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF176B2C))),
                          SizedBox(width: 8),
                          Text('Loading more fresh produce...', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Nearby Farmer Card Component
class _NearbyFarmerCard extends StatelessWidget {
  final FarmerProfileModel farmer;
  final VoidCallback onTap;

  const _NearbyFarmerCard({required this.farmer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8F5E9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE8F5E9),
                  backgroundImage: (farmer.userProfileImage.isNotEmpty)
                      ? NetworkImage(farmer.userProfileImage)
                      : null,
                  child: farmer.userProfileImage.isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF176B2C), size: 28)
                      : null,
                ),
                if (farmer.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Color(0xFF176B2C), size: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              farmer.userName.isNotEmpty ? farmer.userName : farmer.farmName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '${farmer.village.isNotEmpty ? farmer.village : 'Village'}, ${farmer.district}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 12),
                  const SizedBox(width: 2),
                  Text(
                    farmer.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8D6E63)),
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
