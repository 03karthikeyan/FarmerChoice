import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/image_upload_service.dart';
import '../farmer/farmer_main_screen.dart';

class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukController = TextEditingController();
  final _districtController = TextEditingController(text: 'Thanjavur');
  final _stateController = TextEditingController(text: 'Tamil Nadu');
  final _farmAddressController = TextEditingController();
  final _aboutMeController = TextEditingController(text: 'Experienced farmer growing high quality natural vegetables directly from our farm.');
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _villageController.dispose();
    _talukController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _farmAddressController.dispose();
    _aboutMeController.dispose();
    _passwordController.dispose();
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

  void _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final village = _villageController.text.trim();
    final district = _districtController.text.trim();
    final farmAddress = _farmAddressController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || village.isEmpty || district.isEmpty || farmAddress.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory farm fields (*)')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ok = await authProvider.registerFarmer(
      name: name,
      phone: phone,
      email: _emailController.text.trim(),
      password: password,
      farmName: _farmNameController.text.trim().isNotEmpty ? _farmNameController.text.trim() : '$name\'s Natural Farm',
      village: village,
      taluk: _talukController.text.trim(),
      district: district,
      state: _stateController.text.trim(),
      farmAddress: farmAddress,
      aboutMe: _aboutMeController.text.trim(),
      profileImage: _profileImageUrl ?? '',
    );

    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FarmerMainScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage.isNotEmpty ? authProvider.errorMessage : 'Farmer registration failed'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Farmer Registration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
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
              'Register as a Producer / Farmer',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sell directly to consumers without middleman deductions and keep 100% of deal value.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),

            // Profile Picture Uploader Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickProfileImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF176B2C), width: 2.5),
                        image: _profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _isUploadingImage
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF176B2C), strokeWidth: 2.5))
                          : _profileImageUrl == null
                              ? const Center(
                                  child: Icon(Icons.agriculture_rounded, size: 54, color: Color(0xFF176B2C)),
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
                        padding: const EdgeInsets.all(7),
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
                _profileImageUrl != null ? 'Farmer photo selected' : 'Upload Farmer Photo (Optional)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF176B2C)),
              ),
            ),
            const SizedBox(height: 24),

            _inputField('Farmer Full Name *', _nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _inputField('Mobile Number (WhatsApp) *', _phoneController, Icons.phone_outlined, keyboard: TextInputType.phone),
            const SizedBox(height: 16),
            _inputField('Email (Optional)', _emailController, Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // Password
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF176B2C)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _inputField('Farm Name (e.g. Green Valley Farm)', _farmNameController, Icons.landscape_outlined),
            const SizedBox(height: 16),
            _inputField('Village / Town *', _villageController, Icons.home_work_outlined),
            const SizedBox(height: 16),
            _inputField('Taluk', _talukController, Icons.location_city_outlined),
            const SizedBox(height: 16),
            _inputField('District *', _districtController, Icons.map_outlined),
            const SizedBox(height: 16),
            _inputField('State *', _stateController, Icons.public_outlined),
            const SizedBox(height: 16),
            _inputField('Complete Farm Address *', _farmAddressController, Icons.place_outlined),
            const SizedBox(height: 16),

            // About Me
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _aboutMeController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'About Your Farming / Produce',
                  prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF176B2C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: authProvider.state == AuthState.loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: authProvider.state == AuthState.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register as Farmer',
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
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF176B2C)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
