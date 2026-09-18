import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/farmer_profile_model.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/verified_badge.dart';
import '../../../core/widgets/vegetable_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../chat/chat_screen.dart';
import '../vegetables/vegetable_detail_screen.dart';
import '../reviews/add_review_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  final String farmerId;
  final FarmerProfileModel? initialProfile;

  const FarmerProfileScreen({
    super.key,
    required this.farmerId,
    this.initialProfile,
  });

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  FarmerProfileModel? _profile;
  Map<String, dynamic>? _farmerUser;
  List<VegetableModel> _vegetables = [];
  List<ReviewModel> _reviews = [];
  DealModel? _eligibleDeal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      _profile = widget.initialProfile;
      _farmerUser = {
        'name': widget.initialProfile!.userName,
        'profileImage': widget.initialProfile!.userProfileImage,
      };
      _isLoading = false;
    }
    _fetchFarmerDetails();
  }

  Future<void> _fetchFarmerDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isCustomer = authProvider.isCustomer;

    try {
      final res = await ApiClient().dio.get('/farmers/${widget.farmerId}');
      if (res.data['success'] == true) {
        final data = res.data['data'];
        
        // Check if customer has an eligible completed deal
        DealModel? dealObj;
        if (isCustomer) {
          try {
            final eligRes = await ApiClient().dio.get('/reviews/eligible-deal/${widget.farmerId}');
            if (eligRes.data['success'] == true &&
                eligRes.data['canReview'] == true &&
                eligRes.data['deal'] != null) {
              dealObj = DealModel.fromJson(eligRes.data['deal']);
            }
          } catch (_) {}
        }

        if (mounted) {
          setState(() {
            _profile = FarmerProfileModel.fromJson(data['profile']);
            _farmerUser = data['profile']['userId'];
            _eligibleDeal = dealObj;
            if (data['vegetables'] != null) {
              final List list = data['vegetables'];
              _vegetables = list.map((j) => VegetableModel.fromJson(j)).toList();
            }
            if (data['reviews'] != null) {
              final List list = data['reviews'];
              _reviews = list.map((j) => ReviewModel.fromJson(j)).toList();
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching farmer profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChat(BuildContext context, String farmerName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final chatProv = Provider.of<ChatProvider>(context, listen: false);
      final convId = await chatProv.openConversation(
        farmerId: widget.farmerId,
        customerId: authProvider.currentUser!.id,
      );
      if (convId != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: convId,
              recipientName: farmerName,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAF7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Shimmer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2EBE2)),
                  ),
                  child: Row(
                    children: [
                      const ShimmerLoading.circular(size: 68),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ShimmerLoading(width: 140, height: 18, borderRadius: 6),
                            SizedBox(height: 8),
                            ShimmerLoading(width: 100, height: 12, borderRadius: 4),
                            SizedBox(height: 8),
                            ShimmerLoading(width: 80, height: 16, borderRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const ShimmerLoading(width: double.infinity, height: 120, borderRadius: 20),
                const SizedBox(height: 16),
                const ShimmerLoading(width: double.infinity, height: 180, borderRadius: 20),
              ],
            ),
          ),
        ),
      );
    }

    final farmerName = _farmerUser?['name'] ?? 'Verified Farmer';
    final profileImg = _farmerUser?['profileImage'] as String?;
    final farmName = _profile?.farmName.isNotEmpty == true ? _profile!.farmName : 'Registered Organic Farm';
    final locationText = [
      if (_profile?.village.isNotEmpty == true) _profile!.village,
      if (_profile?.district.isNotEmpty == true) _profile!.district,
      if (_profile?.state.isNotEmpty == true) _profile!.state,
    ].join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(farmerName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [

          // 2. Main Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Main Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2EBE2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8F5E9),
                                border: Border.all(color: const Color(0xFF176B2C), width: 2.5),
                                image: (profileImg != null && profileImg.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(profileImg),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (profileImg == null || profileImg.isEmpty)
                                  ? const Icon(Icons.agriculture_rounded, size: 38, color: Color(0xFF176B2C))
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            // Farmer Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          farmerName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1B381E),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      VerifiedBadge(
                                        status: _profile?.verificationStatus ?? 'PENDING',
                                        isSmall: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    farmName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF176B2C),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF7A8B7B)),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          locationText.isNotEmpty ? locationText : 'Tamil Nadu, India',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B746D)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFEDF2ED)),
                        const SizedBox(height: 14),

                        // Stats Highlights Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFF59E0B),
                              value: '${_profile?.rating ?? 5.0} ★',
                              label: '${_profile?.totalReviews ?? _reviews.length} Reviews',
                            ),
                            Container(width: 1, height: 32, color: const Color(0xFFE2EBE2)),
                            _StatItem(
                              icon: Icons.handshake_rounded,
                              iconColor: const Color(0xFF176B2C),
                              value: '${_profile?.completedDealsCount ?? 0}',
                              label: 'Direct Deals',
                            ),
                            Container(width: 1, height: 32, color: const Color(0xFFE2EBE2)),
                            _StatItem(
                              icon: Icons.eco_rounded,
                              iconColor: const Color(0xFF2E7D32),
                              value: '${_vegetables.length}',
                              label: 'Crops Listed',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // About Farm Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2EBE2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF176B2C), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'About the Farm & Harvest',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B381E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _profile?.aboutMe.isNotEmpty == true
                              ? _profile!.aboutMe
                              : 'Experienced local farmer providing fresh naturally grown vegetables harvested directly for families.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF4A5D4E),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Trust Badges
                        Row(
                          children: const [
                            Expanded(child: _TrustPill(icon: Icons.eco_rounded, label: 'Farm Fresh')),
                            SizedBox(width: 8),
                            Expanded(child: _TrustPill(icon: Icons.science_outlined, label: 'No Chemical')),
                            SizedBox(width: 8),
                            Expanded(child: _TrustPill(icon: Icons.verified_rounded, label: '0% Middleman')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Listed Products Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Crops (${_vegetables.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B381E),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Direct Farm Price',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF176B2C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_vegetables.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EBE2)),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF9EABA0)),
                          SizedBox(height: 8),
                          Text(
                            'No crops currently listed.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A695C)),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._vegetables.map(
                      (v) => VegetableCard(
                        vegetable: v,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VegetableDetailScreen(vegetableId: v.id),
                            ),
                          );
                        },
                        onChat: () => _openChat(context, farmerName),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Verified Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Reviews (${_reviews.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B381E),
                        ),
                      ),
                      if (_reviews.isNotEmpty)
                        Row(
                          children: const [
                            Icon(Icons.verified_rounded, size: 14, color: Color(0xFF176B2C)),
                            SizedBox(width: 4),
                            Text(
                              '100% Verified Deals',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF176B2C)),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_eligibleDeal != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF176B2C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Completed Deal Ready for Review',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF145523),
                                  ),
                                ),
                                Text(
                                  'Deal #${_eligibleDeal!.dealNumber} • ${_eligibleDeal!.vegetable?.name ?? 'Produce'}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF4A5D4E)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddReviewScreen(deal: _eligibleDeal!),
                                ),
                              );
                              _fetchFarmerDetails();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF176B2C),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Write Review',
                              style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EBE2)),
                      ),
                      child: const Center(
                        child: Text(
                          'No reviews yet. Complete a direct deal to leave a review.',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF6B746D)),
                        ),
                      ),
                    )
                  else
                    ..._reviews.map(
                      (r) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EBE2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.customer?.name ?? 'Verified Buyer',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1B381E)),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    Text(
                                      r.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B381E)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${r.comment}"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF4A5D4E)),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Icon(Icons.check_circle_outline_rounded, size: 12, color: Color(0xFF176B2C)),
                                SizedBox(width: 4),
                                Text(
                                  'Verified Direct Farm Deal',
                                  style: TextStyle(fontSize: 10.5, color: Color(0xFF176B2C), fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 80), // Extra scroll room above bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Sticky Bottom Chat Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2EBE2))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openChat(context, farmerName),
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
              label: Text(
                'Chat with $farmerName',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B381E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7A8B7B),
          ),
        ),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCECDC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF176B2C)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF176B2C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
