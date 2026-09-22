import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/deal_model.dart';

class CounterOfferSheet extends StatefulWidget {
  final DealModel deal;
  final String role; // 'customer' or 'farmer'
  final Function(double quantity, double price, String note) onSubmit;

  const CounterOfferSheet({
    super.key,
    required this.deal,
    required this.role,
    required this.onSubmit,
  });

  @override
  State<CounterOfferSheet> createState() => _CounterOfferSheetState();
}

class _CounterOfferSheetState extends State<CounterOfferSheet> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _noteController;
  double _calculatedTotal = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final deal = widget.deal;
    _qtyController = TextEditingController(text: deal.agreedQuantity.toStringAsFixed(0));
    _priceController = TextEditingController(text: deal.agreedPrice.toStringAsFixed(0));
    _noteController = TextEditingController();
    _updateTotal();
  }

  void _updateTotal() {
    final q = double.tryParse(_qtyController.text) ?? 0;
    final p = double.tryParse(_priceController.text) ?? 0;
    setState(() {
      _calculatedTotal = q * p;
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final isFarmer = widget.role == 'farmer';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFarmer ? 'Counter Customer Offer' : 'Propose Counter Offer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Deal #${deal.dealNumber} • ${deal.vegetable?.name ?? 'Produce'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Text(
                    'NEGOTIATE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Current Terms Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Agreed Terms',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${deal.agreedQuantity.toStringAsFixed(0)} ${deal.priceUnit} @ ₹${deal.agreedPrice.toStringAsFixed(0)}/${deal.priceUnit}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Current Total',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${deal.dealReferenceValue.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quantity & Price Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateTotal(),
                    decoration: InputDecoration(
                      labelText: 'Offered Quantity (${deal.priceUnit})',
                      hintText: 'e.g. 5',
                      prefixIcon: const Icon(Icons.scale_outlined, size: 18, color: AppColors.primaryGreen),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateTotal(),
                    decoration: InputDecoration(
                      labelText: 'Price / ${deal.priceUnit} (₹)',
                      hintText: 'e.g. 45',
                      prefixIcon: const Icon(Icons.currency_rupee, size: 18, color: AppColors.primaryGreen),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Live Calculated Total Value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Offer Total Value:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                  Text(
                    '₹${_calculatedTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Note Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: isFarmer ? 'Message to Customer' : 'Message to Farmer',
                hintText: isFarmer
                    ? 'e.g. Minimum order price is ₹40, or I can supply 8kg today'
                    : 'e.g. Can you do ₹35 if I pickup early morning?',
                prefixIcon: const Icon(Icons.edit_note, size: 20, color: AppColors.primaryGreen),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        final q = double.tryParse(_qtyController.text) ?? 0;
                        final p = double.tryParse(_priceController.text) ?? 0;

                        if (q <= 0 || p <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid quantity and price.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        await widget.onSubmit(q, p, _noteController.text.trim());
                        if (mounted) {
                          setState(() => _isSubmitting = false);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Counter Offer',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
