import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/chat_provider.dart';
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

  void _showFarmerCounterDialog(BuildContext context, DealModel deal) {
    final qtyController = TextEditingController(text: deal.agreedQuantity.toStringAsFixed(0));
    final priceController = TextEditingController(text: deal.agreedPrice.toStringAsFixed(0));
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Counter Customer Offer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Offered Quantity (kg/units)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Final Price per Unit (₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note for Customer'),
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
                role: 'farmer',
              );
            },
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealProvider = Provider.of<DealProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  const SizedBox(height: 10),
                                  Text(
                                    'Item: ${deal.vegetable?.name ?? 'Vegetables'} • ${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}/${deal.priceUnit}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Deal Reference Value: ₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                                  ),
                                  if (deal.customerNote.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text('Customer Note: "${deal.customerNote}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                  ],
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
                                              if (convId != null && mounted) {
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
                                            onPressed: () => _showFarmerCounterDialog(context, deal),
                                            child: const Text('Counter', style: TextStyle(fontSize: 11)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => dealProvider.acceptDeal(deal.id, role: 'farmer'),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                            child: const Text('Accept', style: TextStyle(fontSize: 11, color: Colors.white)),
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
