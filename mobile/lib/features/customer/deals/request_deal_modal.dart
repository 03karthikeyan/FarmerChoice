import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/deal_provider.dart';
import '../../../core/widgets/deal_safety_banner.dart';

class RequestDealModal extends StatefulWidget {
  final VegetableModel vegetable;

  const RequestDealModal({super.key, required this.vegetable});

  @override
  State<RequestDealModal> createState() => _RequestDealModalState();
}

class _RequestDealModalState extends State<RequestDealModal> {
  double _quantity = 1.0;
  String _deliveryMethod = 'PICKUP';
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final maxQty = widget.vegetable.availableQuantity;
    if (widget.vegetable.isOutOfStock || maxQty <= 0) {
      _quantity = 0;
    } else {
      _quantity = maxQty >= 2 ? 2.0 : maxQty;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser?.defaultDeliveryAddress.isNotEmpty == true) {
        if (_addressController.text.isEmpty) {
          setState(() {
            _addressController.text = auth.currentUser!.defaultDeliveryAddress;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _sendDeal() async {
    if (widget.vegetable.isOutOfStock || widget.vegetable.availableQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is currently out of stock.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_deliveryMethod == 'DELIVERY' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address for Direct Delivery.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
      final msg = dealProv.errorMessage.isNotEmpty
          ? dealProv.errorMessage
          : 'Failed to submit deal request. Please check quantity or try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
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

            if (veg.isOutOfStock) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.block, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This produce is currently out of stock. Deal requests cannot be submitted.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFD32F2F), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

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
                        veg.isOutOfStock
                            ? '0 ${veg.priceUnit} in stock'
                            : 'Price: ₹${veg.price.toStringAsFixed(0)} / ${veg.priceUnit} (Max: ${veg.availableQuantity.toStringAsFixed(0)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: veg.isOutOfStock ? const Color(0xFFD32F2F) : AppColors.textMedium,
                          fontWeight: veg.isOutOfStock ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: (!veg.isOutOfStock && _quantity > 1)
                            ? () => setState(() => _quantity -= 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.primaryGreen),
                      ),
                      Text(
                        '${_quantity.toStringAsFixed(0)} ${veg.priceUnit}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      IconButton(
                        onPressed: (!veg.isOutOfStock && _quantity < veg.availableQuantity)
                            ? () => setState(() => _quantity += 1)
                            : null,
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
                  child: InkWell(
                    onTap: () => setState(() => _deliveryMethod = 'PICKUP'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _deliveryMethod == 'PICKUP' ? AppColors.lightGreenBg : Colors.white,
                        border: Border.all(
                          color: _deliveryMethod == 'PICKUP' ? AppColors.primaryGreen : AppColors.borderLight,
                          width: _deliveryMethod == 'PICKUP' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: _deliveryMethod == 'PICKUP' ? AppColors.primaryGreen : AppColors.textMedium,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Farm Pickup',
                              style: TextStyle(
                                color: _deliveryMethod == 'PICKUP' ? AppColors.primaryGreen : AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _deliveryMethod = 'DELIVERY'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _deliveryMethod == 'DELIVERY' ? AppColors.lightGreenBg : Colors.white,
                        border: Border.all(
                          color: _deliveryMethod == 'DELIVERY' ? AppColors.primaryGreen : AppColors.borderLight,
                          width: _deliveryMethod == 'DELIVERY' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 18,
                            color: _deliveryMethod == 'DELIVERY' ? AppColors.primaryGreen : AppColors.textMedium,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Direct Delivery',
                              style: TextStyle(
                                color: _deliveryMethod == 'DELIVERY' ? AppColors.primaryGreen : AppColors.textDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                  labelText: 'Delivery Address *',
                  hintText: 'Enter complete street, landmark, town',
                  prefixIcon: Icon(Icons.home_outlined, color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 14),
            ],

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Message to Farmer (Optional)',
                hintText: 'e.g. Can I pickup tomorrow at 7 AM or deliver by 6 PM?',
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
                onPressed: (_isSubmitting || veg.isOutOfStock) ? null : _sendDeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: veg.isOutOfStock ? const Color(0xFF9E9E9E) : AppColors.primaryGreen,
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        veg.isOutOfStock ? 'Product Out of Stock' : 'Send Deal Request',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

