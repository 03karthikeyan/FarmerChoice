import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
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

  void _showCounterDialog(BuildContext context, DealModel deal) {
    final qtyController = TextEditingController(text: deal.agreedQuantity.toStringAsFixed(0));
    final priceController = TextEditingController(text: deal.agreedPrice.toStringAsFixed(0));
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Counter Offer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity (kg/units)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Proposed Price / Unit (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note to Farmer'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final q = double.tryParse(qtyController.text) ?? deal.agreedQuantity;
              final p = double.tryParse(priceController.text) ?? deal.agreedPrice;
              Navigator.pop(context);
              await Provider.of<DealProvider>(context, listen: false).submitCounterOffer(
                dealId: deal.id,
                quantity: q,
                price: p,
                note: noteController.text.trim(),
                role: 'customer',
              );
            },
            child: const Text('Submit Counter'),
          ),
        ],
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
                              onCounter: () => _showCounterDialog(context, deal),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Ref. Value', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                  Text(
                    '₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ],
          ),

          if (deal.customerNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Note: "${deal.customerNote}"',
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMedium),
            ),
          ],

          const SizedBox(height: 14),

          // Actions
          if (deal.status == 'NEGOTIATING') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCounter,
                    child: const Text('Counter Offer', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept Deal', style: TextStyle(fontSize: 12)),
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
