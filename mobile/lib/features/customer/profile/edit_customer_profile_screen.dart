import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/image_upload_service.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  const EditCustomerProfileScreen({super.key});

  @override
  State<EditCustomerProfileScreen> createState() => _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _villageController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;

  String? _profileImageUrl;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _villageController = TextEditingController();
    _districtController = TextEditingController(text: 'Thanjavur');
    _stateController = TextEditingController(text: 'Tamil Nadu');
    _profileImageUrl = user?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _pickProfileImage() async {
    setState(() => _isUploadingImage = true);
    final url = await ImageUploadService().showImageSourceDialog(context);
    if (mounted) {
      setState(() {
        if (url != null) _profileImageUrl = url;
        _isUploadingImage = false;
      });
    }
  }

  void _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.updateCustomerProfile(
      name: name,
      phone: phone,
      email: _emailController.text.trim(),
      villageOrTown: _villageController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      profileImage: _profileImageUrl,
    );

    setState(() => _isSaving = false);

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage.isNotEmpty ? auth.errorMessage : 'Failed to update profile.'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Customer Profile', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
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
            // Avatar Selector
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickProfileImage,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF176B2C), width: 3),
                        image: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _isUploadingImage
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF176B2C), strokeWidth: 2.5))
                          : _profileImageUrl == null || _profileImageUrl!.isEmpty
                              ? const Center(
                                  child: Icon(Icons.person_rounded, size: 56, color: Color(0xFF176B2C)),
                                )
                              : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF176B2C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _profileImageUrl != null ? 'Tap avatar to change photo' : 'Upload Profile Photo',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF176B2C)),
              ),
            ),
            const SizedBox(height: 24),

            _inputField('Full Name *', _nameController, Icons.person_outline),
            const SizedBox(height: 14),
            _inputField('Phone Number *', _phoneController, Icons.phone_outlined, keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _inputField('Email Address', _emailController, Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _inputField('Village / Town', _villageController, Icons.home_work_outlined),
            const SizedBox(height: 14),
            _inputField('District', _districtController, Icons.map_outlined),
            const SizedBox(height: 14),
            _inputField('State', _stateController, Icons.public_outlined),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Profile Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon, {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF176B2C)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCCDACC))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
