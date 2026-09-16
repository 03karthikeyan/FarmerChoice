import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../core/widgets/deal_safety_banner.dart';
import '../deals/request_deal_modal.dart';
import '../farmers/farmer_profile_screen.dart';
import '../chat/chat_screen.dart';

class VegetableDetailScreen extends StatefulWidget {
  final String vegetableId;

  const VegetableDetailScreen({super.key, required this.vegetableId});

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  VegetableModel? _vegetable;
  List<VegetableModel> _otherFarmers = [];
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await ApiClient().dio.get('/vegetables/${widget.vegetableId}');
      if (res.data['success'] == true) {
        final data = res.data['data'];
        if (mounted) {
          setState(() {
            _vegetable = VegetableModel.fromJson(data['vegetable']);
            if (data['otherFarmers'] != null) {
              final List list = data['otherFarmers'];
              _otherFarmers = list.map((j) => VegetableModel.fromJson(j)).toList();
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching vegetable details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'AVAILABLE_NOW':
        return const Color(0xFFE8F5E9);
      case 'LIMITED_STOCK':
        return const Color(0xFFFFF3E0);
      case 'OUT_OF_STOCK':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'AVAILABLE_NOW':
        return const Color(0xFF2E7D32);
      case 'LIMITED_STOCK':
        return const Color(0xFFE65100);
      case 'OUT_OF_STOCK':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'AVAILABLE_NOW':
        return 'Available Now';
      case 'LIMITED_STOCK':
        return 'Limited Stock';
      case 'OUT_OF_STOCK':
        return 'Out of Stock';
      default:
        return 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    if (_vegetable == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Vegetable details not available')),
      );
    }

    final veg = _vegetable!;
    final images = veg.images.isNotEmpty
        ? veg.images
        : ['https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600'];

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOutOfStock = veg.availabilityStatus == 'OUT_OF_STOCK' || veg.availableQuantity <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Image Header Sliver with Carousel
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: AppColors.lightGreenBg),
                        errorWidget: (c, u, e) => Container(
                          color: AppColors.lightGreenBg,
                          child: const Icon(Icons.eco, size: 48, color: AppColors.primaryGreen),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == i ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == i ? AppColors.primaryGreen : Colors.white70,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Organic Tags
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                veg.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (veg.isOrganic)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.verified, size: 12, color: Color(0xFFE65100)),
                                    SizedBox(width: 4),
                                    Text(
                                      '100% Organic',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(veg.availabilityStatus),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(veg.availabilityStatus),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _getStatusTextColor(veg.availabilityStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title & Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    veg.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  if (veg.tamilName.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      veg.tamilName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${veg.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                Text(
                                  'per ${veg.priceUnit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.borderLight),
                        const SizedBox(height: 16),

                        // Specs Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecPill(
                                icon: Icons.inventory_2_outlined,
                                label: 'Available Stock',
                                value: '${veg.availableQuantity.toStringAsFixed(0)} ${veg.priceUnit}',
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSpecPill(
                                icon: Icons.shopping_basket_outlined,
                                label: 'Min Order Qty',
                                value: '${veg.minOrderQuantity.toStringAsFixed(0)} ${veg.priceUnit}',
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        if (veg.harvestDate != null) ...[
                          const SizedBox(height: 10),
                          _buildSpecPill(
                            icon: Icons.calendar_today_outlined,
                            label: 'Harvest Date',
                            value: DateFormat('dd MMM yyyy').format(veg.harvestDate!),
                            color: const Color(0xFFE65100),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Direct Farm Rate & Savings Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.handshake_rounded, color: AppColors.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direct From Farmer • 100% Value',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Zero middleman commission. Full payment goes directly to the farmer upon delivery.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2E7D32),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Card
                  if (veg.description.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About this Produce',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            veg.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Farmer Profile Card
                  if (veg.farmer != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Farmer & Origin',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FarmerProfileScreen(farmerId: veg.farmer!.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(
                                    veg.farmer!.profileImage.isNotEmpty
                                        ? veg.farmer!.profileImage
                                        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              veg.farmer!.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textDark,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          VerifiedBadge(
                                            status: veg.farmerProfile?.verificationStatus ??
                                                (veg.farmer?.isVerified == true ? 'VERIFIED' : 'PENDING'),
                                            isSmall: true,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${veg.farmerProfile?.farmName.isNotEmpty == true ? "${veg.farmerProfile!.farmName} • " : ""}${veg.farmerProfile?.village ?? "Farm"}, ${veg.farmerProfile?.district ?? "Tamil Nadu"}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 15, color: AppColors.sunlightYellow),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${veg.farmerProfile?.rating ?? 4.8} (${veg.farmerProfile?.totalReviews ?? 0} reviews)',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• ${veg.farmerProfile?.completedDealsCount ?? 0} Deals',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.primaryGreen,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Compare With Other Farmers
                  if (_otherFarmers.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Compare Other Farmers',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Direct Choice',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Compare prices & ratings for the same produce from different local farms:',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textMedium),
                          ),
                          const SizedBox(height: 12),
                          ..._otherFarmers.map(
                            (other) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAF9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          other.farmer?.name ?? 'Farmer',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          '${other.farmerProfile?.village ?? ""} • ★ ${other.farmerProfile?.rating ?? 4.8}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${other.price.toStringAsFixed(0)} / ${other.priceUnit}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => VegetableDetailScreen(vegetableId: other.id),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: Size.zero,
                                          side: const BorderSide(color: AppColors.primaryGreen),
                                        ),
                                        child: const Text('View', style: TextStyle(fontSize: 11, color: AppColors.primaryGreen)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Deal Safety & Payment Disclaimer
                  const DealSafetyBanner(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Sticky Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Chat with Farmer Button
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (veg.farmer != null && authProvider.currentUser != null) {
                      final chatProv = Provider.of<ChatProvider>(context, listen: false);
                      final convId = await chatProv.openConversation(
                        farmerId: veg.farmer!.id,
                        customerId: authProvider.currentUser!.id,
                        vegetableId: veg.id,
                      );
                      if (convId != null && mounted) {
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
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Request Direct Deal Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: isOutOfStock
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                            ),
                            builder: (_) => RequestDealModal(vegetable: veg),
                          );
                        },
                  icon: Icon(
                    isOutOfStock ? Icons.block_rounded : Icons.handshake_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    isOutOfStock ? 'Out of Stock' : 'Request Deal',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: isOutOfStock ? Colors.grey : AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
