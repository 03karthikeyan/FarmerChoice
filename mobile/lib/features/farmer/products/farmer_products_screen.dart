import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/vegetable_model.dart';
import '../../../core/providers/farmer_provider.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  final List<String> _tabs = ['All', 'Available', 'Limited Stock', 'Out of Stock'];
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerProvider>(context, listen: false).fetchMyProducts();
    });
  }

  void _confirmDelete(BuildContext context, VegetableModel veg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed),
            SizedBox(width: 8),
            Text('Delete Crop', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${veg.name}" from your marketplace listings? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await Provider.of<FarmerProvider>(context, listen: false).deleteProduct(veg.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? '${veg.name} deleted successfully.' : 'Failed to delete product.'),
                    backgroundColor: ok ? AppColors.primaryGreen : AppColors.dangerRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showQuickPriceDialog(BuildContext context, VegetableModel veg) {
    final priceController = TextEditingController(text: veg.price.toStringAsFixed(0));
    final qtyController = TextEditingController(text: veg.availableQuantity.toStringAsFixed(0));
    String avail = veg.availabilityStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Quick Price/Stock: ${veg.name}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price per ${veg.priceUnit} (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF176B2C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Available Quantity (${veg.priceUnit})',
                  prefixIcon: const Icon(Icons.production_quantity_limits, color: Color(0xFF176B2C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: avail,
                items: const [
                  DropdownMenuItem(value: 'AVAILABLE_NOW', child: Text('Available Now')),
                  DropdownMenuItem(value: 'LIMITED_STOCK', child: Text('Limited Stock')),
                  DropdownMenuItem(value: 'OUT_OF_STOCK', child: Text('Out of Stock')),
                ],
                onChanged: (val) => setState(() => avail = val ?? avail),
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final p = double.tryParse(priceController.text);
                final q = double.tryParse(qtyController.text);
                Navigator.pop(ctx);
                await Provider.of<FarmerProvider>(context, listen: false).quickUpdate(
                  vegetableId: veg.id,
                  price: p,
                  availableQuantity: q,
                  availabilityStatus: avail,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF176B2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmerProv = Provider.of<FarmerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Farm Crops & Produce',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF176B2C), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = tab == _selectedTab;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = tab);
                    farmerProv.fetchMyProducts(status: tab);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF176B2C) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF176B2C),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Product List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => farmerProv.fetchMyProducts(status: _selectedTab),
              color: const Color(0xFF176B2C),
              child: farmerProv.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF176B2C)))
                  : farmerProv.myProducts.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.eco_outlined, size: 50, color: AppColors.textLight),
                                  const SizedBox(height: 12),
                                  const Text('No crops found in this tab.', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF176B2C),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('+ List Your First Crop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: farmerProv.myProducts.length,
                          itemBuilder: (context, index) {
                            final veg = farmerProv.myProducts[index];
                            final image = veg.images.isNotEmpty
                                ? veg.images[0]
                                : 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: image,
                                      width: 76,
                                      height: 76,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(
                                        width: 76,
                                        height: 76,
                                        color: const Color(0xFFE8F5E9),
                                        child: const Icon(Icons.eco, color: Color(0xFF176B2C)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          veg.name,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                                        ),
                                        if (veg.tamilName.isNotEmpty)
                                          Text(
                                            veg.tamilName,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${veg.price.toStringAsFixed(0)} / ${veg.priceUnit} • ${veg.availableQuantity.toStringAsFixed(0)} ${veg.priceUnit} available',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF176B2C)),
                                        ),
                                        const SizedBox(height: 3),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: veg.availabilityStatus == 'AVAILABLE_NOW'
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            veg.availabilityStatus.replaceAll('_', ' '),
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: veg.availabilityStatus == 'AVAILABLE_NOW'
                                                  ? const Color(0xFF176B2C)
                                                  : const Color(0xFFE65100),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Full Edit button
                                          IconButton(
                                            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF176B2C), size: 24),
                                            tooltip: 'Edit Crop Details',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => EditProductScreen(vegetable: veg),
                                                ),
                                              );
                                            },
                                          ),
                                          // Delete button
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dangerRed, size: 22),
                                            tooltip: 'Delete Crop',
                                            onPressed: () => _confirmDelete(context, veg),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () => _showQuickPriceDialog(context, veg),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Quick Price', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF176B2C))),
                                      ),
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
