import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/services/image_upload_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _tamilNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Vegetable';
  String _priceUnit = 'kg';
  String _availabilityStatus = 'AVAILABLE_NOW';
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  final List<String> _categories = ['Vegetable', 'Leafy', 'Root', 'Other'];
  final List<String> _units = ['kg', 'bunch', 'piece'];

  @override
  void dispose() {
    _nameController.dispose();
    _tamilNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickProductImage() async {
    setState(() => _isUploadingImage = true);
    final url = await ImageUploadService().showImageSourceDialog(context);
    if (mounted) {
      setState(() {
        if (url != null) _uploadedImageUrl = url;
        _isUploadingImage = false;
      });
    }
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text);
    final qty = double.tryParse(_quantityController.text);

    if (name.isEmpty || price == null || qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill vegetable name, price, and available quantity.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final farmerProv = Provider.of<FarmerProvider>(context, listen: false);
    final ok = await farmerProv.addProduct(
      name: name,
      tamilName: _tamilNameController.text.trim(),
      category: _category,
      price: price,
      priceUnit: _priceUnit,
      availableQuantity: qty,
      availabilityStatus: _availabilityStatus,
      description: _descriptionController.text.trim(),
      images: _uploadedImageUrl != null ? [_uploadedImageUrl!] : [],
    );

    setState(() => _isSubmitting = false);

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vegetable crop listed successfully on Farmer Choice!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add vegetable listing.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Vegetable Crop', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List New Harvest',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload photo, set direct price and quantity. Verified buyers in your district will see it immediately.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),

            // Product Photo Uploader
            const Text('Vegetable Photo *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B381E))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isUploadingImage ? null : _pickProductImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAF6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                  image: _uploadedImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_uploadedImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isUploadingImage
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF176B2C)))
                    : _uploadedImageUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo_rounded, size: 48, color: Color(0xFF176B2C)),
                              SizedBox(height: 10),
                              Text(
                                'Tap to Take Photo or Choose from Gallery',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF176B2C)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real harvest photos receive 3x more orders',
                                style: TextStyle(fontSize: 11, color: Color(0xFF6B746D)),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.edit, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Change', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField('Vegetable Name (English) *', _nameController, 'e.g. Country Tomato, Fresh Brinjal'),
            const SizedBox(height: 14),

            _buildTextField('Tamil Name (Optional)', _tamilNameController, 'e.g. நாட்டு தக்காளி, கத்தரிக்காய்'),
            const SizedBox(height: 14),

            // Category & Unit Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCDACC)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _category = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price Unit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCCDACC)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _priceUnit,
                            isExpanded: true,
                            items: _units.map((u) => DropdownMenuItem(value: u, child: Text('Per $u'))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _priceUnit = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Price & Quantity Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Price (₹) *', _priceController, 'e.g. 40', keyboard: TextInputType.number),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField('Available Quantity *', _quantityController, 'e.g. 100', keyboard: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Availability Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Availability Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCDACC)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _availabilityStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'AVAILABLE_NOW', child: Text('Available Now (Ready to Deliver)')),
                        DropdownMenuItem(value: 'HARVESTING_SOON', child: Text('Harvesting in 1-2 Days')),
                        DropdownMenuItem(value: 'LIMITED_STOCK', child: Text('Limited Stock')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _availabilityStatus = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildTextField('Crop Details / Description', _descriptionController, 'e.g. Harvested this morning, naturally grown without chemical fertilizers.', maxLines: 3),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'List Crop on Marketplace',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCCDACC))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
