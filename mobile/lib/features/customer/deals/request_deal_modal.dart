import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/widgets/deal_safety_banner.dart';

class RequestDealModal extends StatefulWidget {
  final VegetableModel vegetable;

  const RequestDealModal({super.key, required this.vegetable});

  @override
  State<RequestDealModal> createState() => _RequestDealModalState();
}

class _RequestDealModalState extends State<RequestDealModal> {
  double _quantity = 2.0;
  String _deliveryMethod = 'PICKUP';
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _sendDeal() async {
    setState(() => _isSubmitting = true);

    final dealProv = Provider.of<DealProvider>(context, listen: false);
    final ok = await dealProv.createDealRequest(
      vegetableId: widget.vegetable.id,
      quantity: _quantity,
      referencePrice: widget.vegetable.price,
      deliveryMethod: _deliveryMethod,
      deliveryAddress: _addressController.text.trim(),
      customerNote: _noteController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Direct deal request sent! Farmer will review and confirm.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit deal request.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final veg = widget.vegetable;
    final refValue = (_quantity * veg.price).toStringAsFixed(0);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
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
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Direct Deal Request',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    Text(
                      'Item: ${veg.name} (Farmer: ${veg.farmer?.name ?? 'Farmer'})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FREE DIRECT DEAL',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Quantity Counter Row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requested Quantity',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      Text(
                        'Price: ₹${veg.price.toStringAsFixed(0)} / ${veg.priceUnit}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? () => setState(() => _quantity -= 1) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen),
                      ),
                      Text(
                        '${_quantity.toStringAsFixed(0)} ${veg.priceUnit}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity += 1),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Deal Reference Value Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Deal Reference Value:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                  Text(
                    '₹$refValue',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Method Selector
            const Text(
              'Preferred Method',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Farm Pickup / Visit'),
                    selected: _deliveryMethod == 'PICKUP',
                    onSelected: (val) => setState(() => _deliveryMethod = 'PICKUP'),
                    selectedColor: AppColors.lightGreenBg,
                    labelStyle: TextStyle(
                      color: _deliveryMethod == 'PICKUP' ? AppColors.primaryGreen : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Direct Delivery'),
                    selected: _deliveryMethod == 'DELIVERY',
                    onSelected: (val) => setState(() => _deliveryMethod = 'DELIVERY'),
                    selectedColor: AppColors.lightGreenBg,
                    labelStyle: TextStyle(
                      color: _deliveryMethod == 'DELIVERY' ? AppColors.primaryGreen : AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (_deliveryMethod == 'DELIVERY') ...[
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Street, landmark, town',
                  prefixIcon: Icon(Icons.home_outlined, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 14),
            ],

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Message to Farmer (Optional)',
                hintText: 'e.g. Can I pickup tomorrow at 7 AM?',
                prefixIcon: Icon(Icons.edit_note, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),

            // Zero Payment Safety Notice
            const DealSafetyBanner(),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _sendDeal,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Deal Request',
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
