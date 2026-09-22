import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/counter_offer_sheet.dart';
import '../reviews/add_review_screen.dart';
import '../chat/chat_screen.dart';

class MyDealsScreen extends StatefulWidget {
  const MyDealsScreen({super.key});

  @override
  State<MyDealsScreen> createState() => _MyDealsScreenState();
}

class _MyDealsScreenState extends State<MyDealsScreen> {
  final List<String> _tabs = [
    'All',
    'Requested',
    'Negotiating',
    'Accepted',
    'Ready',
    'Completed',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DealProvider>(context, listen: false).fetchMyDeals(role: 'customer');
    });
  }

  void _showCounterSheet(BuildContext context, DealModel deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CounterOfferSheet(
        deal: deal,
        role: 'customer',
        onSubmit: (q, p, note) async {
          await Provider.of<DealProvider>(context, listen: false).submitCounterOffer(
            dealId: deal.id,
            quantity: q,
            price: p,
            note: note,
            role: 'customer',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealProvider = Provider.of<DealProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Deals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: () => dealProvider.fetchMyDeals(role: 'customer'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            height: 50,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = dealProvider.selectedTab == tab;
                return GestureDetector(
                  onTap: () => dealProvider.setSelectedTab(tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen : AppColors.lightGreenBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Deals List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => dealProvider.fetchMyDeals(role: 'customer'),
              color: AppColors.primaryGreen,
              child: dealProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : dealProvider.filteredDeals.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.handshake_outlined, size: 48, color: AppColors.textLight),
                                  SizedBox(height: 12),
                                  Text(
                                    'No active deals in this tab.',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Find fresh vegetables and send a deal request to start.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dealProvider.filteredDeals.length,
                          itemBuilder: (context, index) {
                            final deal = dealProvider.filteredDeals[index];
                            return _DealCard(
                              deal: deal,
                              onCounter: () => _showCounterSheet(context, deal),
                              onAccept: () => dealProvider.acceptDeal(deal.id, role: 'customer'),
                              onConfirmReceived: () => dealProvider.confirmCompletion(deal.id, role: 'customer'),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback onCounter;
  final VoidCallback onAccept;
  final VoidCallback onConfirmReceived;

  const _DealCard({
    required this.deal,
    required this.onCounter,
    required this.onAccept,
    required this.onConfirmReceived,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLastByFarmer = deal.lastCounterBy.isNotEmpty && deal.lastCounterBy == deal.farmerId;

    Color statusBg = AppColors.lightGreenBg;
    Color statusColor = AppColors.primaryGreen;

    if (deal.status == 'COMPLETED') {
      statusBg = const Color(0xFFE8F5E9);
      statusColor = const Color(0xFF2E7D32);
    } else if (deal.status == 'ACCEPTED' || deal.status == 'READY') {
      statusBg = const Color(0xFFE3F2FD);
      statusColor = const Color(0xFF1565C0);
    } else if (deal.status == 'CANCELLED') {
      statusBg = const Color(0xFFFFEBEE);
      statusColor = const Color(0xFFC62828);
    } else if (deal.status == 'NEGOTIATING') {
      statusBg = const Color(0xFFFFF8E1);
      statusColor = const Color(0xFFF57F17);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (deal.status == 'NEGOTIATING' && isLastByFarmer)
              ? const Color(0xFFFFB300)
              : AppColors.borderLight,
          width: (deal.status == 'NEGOTIATING' && isLastByFarmer) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deal #${deal.dealNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  deal.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          // Negotiation Turn Callout Banner
          if (deal.status == 'NEGOTIATING') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLastByFarmer ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLastByFarmer ? const Color(0xFFFFE082) : const Color(0xFFC8E6C9),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isLastByFarmer ? Icons.notifications_active : Icons.hourglass_top,
                    size: 16,
                    color: isLastByFarmer ? const Color(0xFFE65100) : AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLastByFarmer
                          ? 'Farmer proposed a Counter Offer — Review & respond below.'
                          : 'Your counter offer was sent. Waiting for farmer response.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isLastByFarmer ? const Color(0xFFE65100) : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else if (deal.status == 'REQUESTED') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCEDC8)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.send_outlined, size: 14, color: AppColors.primaryGreen),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Request sent to farmer. Awaiting confirmation or counter offer.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Details Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: (deal.vegetable?.images.isNotEmpty == true)
                      ? deal.vegetable!.images[0]
                      : 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200',
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.vegetable?.name ?? 'Fresh Vegetables',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Farmer: ${deal.farmer?.name ?? 'Verified Farmer'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}/${deal.priceUnit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Value', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                  Text(
                    '₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ],
          ),

          // Negotiation Comparison Box (If terms differ or during negotiation)
          if (deal.status == 'NEGOTIATING' || deal.isAgreedDifferentFromRequested) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFF59D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.swap_horiz, size: 16, color: Color(0xFFF57F17)),
                      SizedBox(width: 6),
                      Text(
                        'Negotiation Terms Comparison',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFF57F17)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Initial Request', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                              const SizedBox(height: 2),
                              Text(
                                '${deal.requestedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.requestedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              Text(
                                'Total: ₹${(deal.requestedQuantity * deal.requestedPrice).toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFD54F)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLastByFarmer ? "Farmer's Counter Offer" : "Latest Active Offer",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                              ),
                              Text(
                                'Total: ₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Farmer Message Note (if any)
          if (deal.farmerNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble, size: 15, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Message from Farmer:',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deal.farmerNote,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Customer Note (if any)
          if (deal.customerNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, size: 14, color: AppColors.textMedium),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Your Note: "${deal.customerNote}"',
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMedium),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Delivery Method & Address info
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      deal.deliveryMethod == 'DELIVERY' ? Icons.local_shipping_outlined : Icons.storefront_outlined,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deal.deliveryMethod == 'DELIVERY' ? 'Direct Delivery' : 'Farm Pickup / Visit',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                  ],
                ),
                if (deal.deliveryMethod == 'DELIVERY' && deal.deliveryAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMedium),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deal.deliveryAddress,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions
          if (deal.status == 'NEGOTIATING' || deal.status == 'REQUESTED') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCounter,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Counter Offer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
                    label: const Text('Accept Deal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ] else if (deal.status == 'ACCEPTED' || deal.status == 'READY') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (deal.farmer != null && authProvider.currentUser != null) {
                        final chatProv = Provider.of<ChatProvider>(context, listen: false);
                        final convId = await chatProv.openConversation(
                          farmerId: deal.farmer!.id,
                          customerId: authProvider.currentUser!.id,
                          dealId: deal.id,
                        );
                        if (convId != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: convId,
                                recipientName: deal.farmer!.name,
                                dealNumber: deal.dealNumber,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                    label: const Text('Chat Farmer', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: deal.customerConfirmed ? null : onConfirmReceived,
                    icon: const Icon(Icons.check, size: 14, color: Colors.white),
                    label: Text(
                      deal.customerConfirmed ? 'Received ✓' : 'Vegetables Received',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ] else if (deal.status == 'COMPLETED') ...[
            if (!deal.hasReview)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReviewScreen(deal: deal),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star, size: 16, color: Colors.white),
                  label: const Text('Write Verified Review', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'Verified Review Submitted ★★★★★',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

