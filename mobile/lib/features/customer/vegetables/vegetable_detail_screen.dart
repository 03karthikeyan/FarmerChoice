import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../core/widgets/deal_safety_banner.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../deals/request_deal_modal.dart';
import '../farmers/farmer_profile_screen.dart';
import '../chat/chat_screen.dart';

class VegetableDetailScreen extends StatefulWidget {
  final String vegetableId;
  final VegetableModel? initialVegetable;

  const VegetableDetailScreen({
    super.key,
    required this.vegetableId,
    this.initialVegetable,
  });

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  VegetableModel? _vegetable;
  List<VegetableModel> _otherFarmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialVegetable != null) {
      _vegetable = widget.initialVegetable;
      _isLoading = false;
    }
    _fetchDetails();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _vegetable == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Shimmer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: double.infinity, height: 260, borderRadius: 20),
                const SizedBox(height: 20),
                const ShimmerLoading(width: 200, height: 24, borderRadius: 8),
                const SizedBox(height: 10),
                const ShimmerLoading(width: 120, height: 16, borderRadius: 6),
                const SizedBox(height: 20),
                const ShimmerLoading(width: double.infinity, height: 80, borderRadius: 16),
                const SizedBox(height: 20),
                const ShimmerLoading(width: double.infinity, height: 120, borderRadius: 16),
              ],
            ),
          ),
        ),
      );
    }

    if (_vegetable == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Vegetable details not available')),
      );
    }

    final veg = _vegetable!;
    final image = veg.images.isNotEmpty
        ? veg.images[0]
        : 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Image Header Sliver
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: veg.isOutOfStock
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: AppColors.lightGreenBg),
                      errorWidget: (c, u, e) => Container(color: AppColors.lightGreenBg, child: const Icon(Icons.eco)),
                    ),
                  ),
                  if (veg.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.block, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'CURRENTLY OUT OF STOCK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Body Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              veg.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: veg.isOutOfStock ? AppColors.textMedium : AppColors.textDark,
                              ),
                            ),
                            if (veg.tamilName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                veg.tamilName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: veg.isOutOfStock ? AppColors.textLight : AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: veg.isOutOfStock ? const Color(0xFFEEEEEE) : AppColors.lightGreenBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹${veg.price.toStringAsFixed(0)} / ${veg.priceUnit}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: veg.isOutOfStock ? AppColors.textLight : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock & Trust Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: veg.isOutOfStock
                              ? const Color(0xFFFFEBEE)
                              : veg.isLimitedStock
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: veg.isOutOfStock
                              ? Border.all(color: const Color(0xFFFFCDD2), width: 0.8)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              veg.isOutOfStock ? Icons.block : Icons.inventory_2_outlined,
                              size: 13,
                              color: veg.isOutOfStock
                                  ? const Color(0xFFD32F2F)
                                  : veg.isLimitedStock
                                      ? const Color(0xFFE65100)
                                      : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              veg.isOutOfStock
                                  ? 'Out of Stock'
                                  : veg.isLimitedStock
                                      ? 'Limited: Only ${veg.availableQuantity.toStringAsFixed(0)} ${veg.priceUnit} left'
                                      : '${veg.availableQuantity.toStringAsFixed(0)} ${veg.priceUnit} Available',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: veg.isOutOfStock
                                    ? const Color(0xFFD32F2F)
                                    : veg.isLimitedStock
                                        ? const Color(0xFFE65100)
                                        : AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (veg.isOrganic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Organic',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (veg.isOutOfStock) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Currently Out of Stock',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFD32F2F)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'This crop is currently sold out or out of stock. You can tap Chat below to contact the farmer about upcoming harvest dates.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFB71C1C), height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (veg.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      veg.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Zero Payment Disclaimer
                  const DealSafetyBanner(),
                  const SizedBox(height: 20),

                  // Farmer Profile Card
                  if (veg.farmer != null) ...[
                    const Text(
                      'About the Farmer',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FarmerProfileScreen(farmerId: veg.farmer!.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
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
                                      Text(
                                        veg.farmer!.name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                      ),
                                      VerifiedBadge(
                                        status: veg.farmerProfile?.verificationStatus ??
                                            (veg.farmer?.isVerified == true ? 'VERIFIED' : 'PENDING'),
                                        isSmall: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${veg.farmerProfile?.village ?? 'Farm Village'}, ${veg.farmerProfile?.district ?? ''}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 13, color: AppColors.sunlightYellow),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${veg.farmerProfile?.rating ?? 4.8} (${veg.farmerProfile?.totalReviews ?? 124} reviews)',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '• ${veg.farmerProfile?.completedDealsCount ?? 89} Deals',
                                        style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Compare Farmers (Same Vegetable from other farmers)
                  if (_otherFarmers.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Text(
                            'Compare with Other Farmers',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Choose Your Farmer',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Multiple farmers sell this vegetable. Compare prices and choose freely:',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMedium),
                    ),
                    const SizedBox(height: 12),
                    ..._otherFarmers.map(
                      (other) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    other.farmer?.name ?? 'Farmer',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${other.farmerProfile?.village.isNotEmpty == true ? other.farmerProfile!.village : 'Village'} • ★ ${other.farmerProfile?.rating ?? 4.8}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${other.price.toStringAsFixed(0)}/${other.priceUnit}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Select', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Sticky Action Bar (Chat & Request Deal - NO Pay Now!)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Request Deal Button
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: veg.isOutOfStock
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
                    veg.isOutOfStock ? Icons.block : Icons.handshake_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    veg.isOutOfStock ? 'Out of Stock' : 'Request Deal',
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: veg.isOutOfStock ? const Color(0xFF9E9E9E) : AppColors.primaryGreen,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
