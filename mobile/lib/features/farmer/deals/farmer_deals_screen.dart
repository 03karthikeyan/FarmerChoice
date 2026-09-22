import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/widgets/counter_offer_sheet.dart';
import '../../customer/chat/chat_screen.dart';

class FarmerDealsScreen extends StatefulWidget {
  const FarmerDealsScreen({super.key});

  @override
  State<FarmerDealsScreen> createState() => _FarmerDealsScreenState();
}

class _FarmerDealsScreenState extends State<FarmerDealsScreen> {
  final List<String> _tabs = ['All', 'Requested', 'Negotiating', 'Accepted', 'Ready', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DealProvider>(context, listen: false).fetchMyDeals(role: 'farmer');
    });
  }

  void _showFarmerCounterSheet(BuildContext context, DealModel deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CounterOfferSheet(
        deal: deal,
        role: 'farmer',
        onSubmit: (q, p, note) async {
          await Provider.of<DealProvider>(context, listen: false).submitCounterOffer(
            dealId: deal.id,
            quantity: q,
            price: p,
            note: note,
            role: 'farmer',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealProvider = Provider.of<DealProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final farmerUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Deal Inquiries',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: () => dealProvider.fetchMyDeals(role: 'farmer'),
          ),
        ],
      ),
      body: Column(
        children: [
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => dealProvider.fetchMyDeals(role: 'farmer'),
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
                                    'No customer requests in this tab.',
                                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
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
                            final isLastByCustomer = deal.lastCounterBy.isNotEmpty && deal.lastCounterBy == deal.customerId;
                            final isLastByFarmer = deal.lastCounterBy.isNotEmpty && deal.lastCounterBy == farmerUserId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (deal.status == 'REQUESTED' || (deal.status == 'NEGOTIATING' && isLastByCustomer))
                                      ? const Color(0xFFFFB300)
                                      : AppColors.borderLight,
                                  width: (deal.status == 'REQUESTED' || (deal.status == 'NEGOTIATING' && isLastByCustomer)) ? 1.5 : 1,
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
                                  // Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Customer: ${deal.customer?.name ?? 'Customer'}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGreenBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          deal.status,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Turn status banner
                                  if (deal.status == 'REQUESTED') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFFFE082)),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.notifications_active, size: 14, color: Color(0xFFE65100)),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'New Deal Request — Accept or propose a Counter Offer.',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ] else if (deal.status == 'NEGOTIATING') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isLastByCustomer ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: isLastByCustomer ? const Color(0xFFFFE082) : const Color(0xFFC8E6C9)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLastByCustomer ? Icons.notifications_active : Icons.hourglass_top,
                                            size: 14,
                                            color: isLastByCustomer ? const Color(0xFFE65100) : AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              isLastByCustomer
                                                  ? 'Customer revised counter offer — Review & respond.'
                                                  : 'Your counter offer sent — Waiting for customer response.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isLastByCustomer ? const Color(0xFFE65100) : AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // Item Info
                                  Text(
                                    'Item: ${deal.vegetable?.name ?? 'Vegetables'} • ${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}/${deal.priceUnit}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Deal Value: ₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                                  ),

                                  // Comparison Card
                                  if (deal.status == 'NEGOTIATING' || deal.isAgreedDifferentFromRequested) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFDE7),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFFF59D)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Customer Request', style: TextStyle(fontSize: 10, color: AppColors.textMedium)),
                                                Text(
                                                  '${deal.requestedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.requestedPrice.toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                                ),
                                                Text(
                                                  '₹${(deal.requestedQuantity * deal.requestedPrice).toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(width: 1, height: 32, color: const Color(0xFFFFD54F)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isLastByFarmer ? 'Your Counter Offer' : 'Customer Counter',
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFE65100)),
                                                ),
                                                Text(
                                                  '${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                                                ),
                                                Text(
                                                  '₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
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
                                        color: const Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFFFE082)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFFF57F17)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Customer: "${deal.customerNote}"',
                                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFE65100)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Farmer Note (if any)
                                  if (deal.farmerNote.isNotEmpty) ...[
                                    const SizedBox(height: 6),
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
                                              'Your Note: "${deal.farmerNote}"',
                                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMedium),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Delivery Method & Address info
                                  const SizedBox(height: 8),
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
                                              deal.deliveryMethod == 'DELIVERY' ? 'Direct Delivery Requested' : 'Farm Pickup / Visit',
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
                                                  'Deliver to: ${deal.deliveryAddress}',
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

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            if (deal.customer != null && authProvider.currentUser != null) {
                                              final chatProv = Provider.of<ChatProvider>(context, listen: false);
                                              final convId = await chatProv.openConversation(
                                                farmerId: authProvider.currentUser!.id,
                                                customerId: deal.customer!.id,
                                                dealId: deal.id,
                                              );
                                              if (convId != null && context.mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ChatScreen(
                                                      conversationId: convId,
                                                      recipientName: deal.customer!.name,
                                                      dealNumber: deal.dealNumber,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text('Chat Customer', style: TextStyle(fontSize: 11)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      if (deal.status == 'REQUESTED' || deal.status == 'NEGOTIATING') ...[
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _showFarmerCounterSheet(context, deal),
                                            child: const Text('Counter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => dealProvider.acceptDeal(deal.id, role: 'farmer'),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                            child: const Text('Accept', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                                          ),
                                        ),
                                      ] else if (deal.status == 'ACCEPTED') ...[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => dealProvider.markReady(deal.id),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                            child: const Text('Mark Packed & Ready', style: TextStyle(fontSize: 11, color: Colors.white)),
                                          ),
                                        ),
                                      ] else if (deal.status == 'READY') ...[
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: deal.farmerConfirmed
                                                ? null
                                                : () => dealProvider.confirmCompletion(deal.id, role: 'farmer'),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                            child: Text(
                                              deal.farmerConfirmed ? 'Confirmed ✓' : 'Confirm Deal Completed',
                                              style: const TextStyle(fontSize: 10.5, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
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

