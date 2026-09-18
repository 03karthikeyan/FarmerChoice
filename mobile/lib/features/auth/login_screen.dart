import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../customer/customer_main_screen.dart';
import '../farmer/farmer_main_screen.dart';
import 'role_selection_screen.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/benefit_item.dart';
import 'widgets/decorative_leaf.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(identifier, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Direct role-based navigation on success
        if (authProvider.isFarmer) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const FarmerMainScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
            (route) => false,
          );
        }
      } else {
        // Show clear error message on failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.errorMessage.isNotEmpty
                        ? authProvider.errorMessage
                        : 'Invalid mobile number/email or password',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 720;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // 1. TOP HERO BANNER (Farmer + Vegetables + Logo)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.35,
              child: Image.asset(
                'assets/images/login_hero_top.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFEAF5E8),
                    child: Center(
                      child: Image.asset(
                        'assets/images/farmer_choice_logo.png',
                        width: 180,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. CURVED WHITE CONTAINER (Smooth curve overlapping hero, down to bottom)
            Positioned(
              top: size.height * 0.33,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 16,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Leaf Accents on Left & Right
                    const Positioned(
                      top: 10,
                      left: 0,
                      child: DecorativeLeaf(isLeft: true),
                    ),
                    const Positioned(
                      top: 10,
                      right: 0,
                      child: DecorativeLeaf(isLeft: false),
                    ),

                    // Full-Width Bottom Agricultural Scenery Illustration (Spans edge-to-edge)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/scenery_footer.png',
                        width: size.width,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),

                    // Form and interactive elements
                    SafeArea(
                      top: false,
                      bottom: true,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 22,
                          right: 22,
                          top: 14,
                          bottom: 40,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // A. Header (Welcome Back + Subtitle)
                              Column(
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      fontSize: isCompact ? 22 : 24,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF145523),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Login to continue to ',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF6B746D),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Farmer Choice',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF176B2C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // B. Form Input Fields
                              Column(
                                children: [
                                  AuthTextField(
                                    controller: _identifierController,
                                    hintText: 'Mobile Number / Email',
                                    prefixIcon: Icons.call_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter mobile number or email';
                                      }
                                      final trimmed = value.trim();
                                      final isPhone = RegExp(r'^[0-9]{10}$').hasMatch(trimmed);
                                      final isEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmed);
                                      if (!isPhone && !isEmail) {
                                        return 'Enter a valid 10-digit mobile number or email';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: isCompact ? 8 : 10),
                                  AuthTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleLogin(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF6B746D),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.trim().length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),

                              // C. Login Button with Progress Indicator
                              SizedBox(
                                width: double.infinity,
                                height: isCompact ? 46 : 50,
                                child: ElevatedButton(
                                  onPressed: (_isLoading ||
                                          authProvider.state == AuthState.loading)
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF176B2C),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF176B2C).withOpacity(0.7),
                                    elevation: 1.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: (_isLoading ||
                                          authProvider.state == AuthState.loading)
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.4,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              // D. Forgot Password
                              GestureDetector(
                                onTap: () => _showForgotPasswordDialog(context),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF176B2C),
                                  ),
                                ),
                              ),

                              // E. OR Divider
                              Row(
                                children: const [
                                  Expanded(
                                    child: Divider(
                                      color: Color(0xFFE2EBE2),
                                      thickness: 1.1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF8E9B8D),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Color(0xFFE2EBE2),
                                      thickness: 1.1,
                                    ),
                                  ),
                                ],
                              ),

                              // F. Create Account Button
                              SizedBox(
                                width: double.infinity,
                                height: isCompact ? 42 : 46,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RoleSelectionScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF176B2C),
                                      width: 1.4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: Color(0xFF176B2C),
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'New User? Create Account',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF176B2C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // G. 4-Column Feature Indicators
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FCF9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEAF5E8)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Expanded(
                                      child: BenefitItem(
                                        icon: Icons.person_pin_rounded,
                                        title: 'Support\nFarmers',
                                      ),
                                    ),
                                    _VerticalSeparator(),
                                    Expanded(
                                      child: BenefitItem(
                                        icon: Icons.eco_rounded,
                                        title: 'Fresh &\nNatural',
                                      ),
                                    ),
                                    _VerticalSeparator(),
                                    Expanded(
                                      child: BenefitItem(
                                        icon: Icons.verified_user_rounded,
                                        title: 'Fair Price\nNo Middlemen',
                                      ),
                                    ),
                                    _VerticalSeparator(),
                                    Expanded(
                                      child: BenefitItem(
                                        icon: Icons.local_shipping_rounded,
                                        title: 'Direct to\nYour Home',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_reset_rounded, color: Color(0xFF176B2C)),
            SizedBox(width: 8),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF145523),
              ),
            ),
          ],
        ),
        content: const Text(
          'Please enter your registered mobile number to receive a reset code or contact your district coordinator.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4A5D4E), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6B746D), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset instructions sent to your registered phone.'),
                  backgroundColor: Color(0xFF176B2C),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176B2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Send Reset Link',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalSeparator extends StatelessWidget {
  const _VerticalSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFDDE8DC),
    );
  }
}
