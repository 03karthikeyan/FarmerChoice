import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../customer/customer_main_screen.dart';
import '../farmer/farmer_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  String _statusText = 'Checking authorization...';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _entranceController.forward();
    _handleAuthAndNavigation();
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION & NAVIGATION LOGIC (RELIABLE & ROCK-SOLID)
  // ---------------------------------------------------------------------------

  Future<void> _handleAuthAndNavigation() async {
    final startTime = DateTime.now();

    // 1. Snappy display time for brand impression (Fast & Production-grade)
    const minSplashDuration = Duration(milliseconds: 1000);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // If auth session check hasn't run or is currently loading, await completion
      if (authProvider.state == AuthState.initial ||
          authProvider.state == AuthState.loading) {
        if (mounted) {
          setState(() => _statusText = 'Verifying account session...');
        }
        await authProvider.checkAuthSession().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint('Splash: Auth check timed out, proceeding with current state');
          },
        );
      }

      if (mounted) {
        setState(() => _statusText = 'Syncing farm fresh inventory...');
      }

      // Ensure minimum splash duration elapsed
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minSplashDuration) {
        await Future.delayed(minSplashDuration - elapsed);
      }

      if (!mounted || _hasNavigated) return;

      _navigateToTargetScreen(authProvider);
    } catch (e) {
      debugPrint('Splash Screen navigation error: $e');
      if (mounted && !_hasNavigated) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _navigateToTargetScreen(authProvider);
      }
    }
  }

  void _navigateToTargetScreen(AuthProvider authProvider) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final Widget targetScreen;

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      if (authProvider.isFarmer) {
        targetScreen = const FarmerMainScreen();
      } else {
        targetScreen = const CustomerMainScreen();
      }
    } else {
      targetScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const bgBase = Color(0xFFF8FAF8);

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          // 1. Soft Central Mint Glow (As shown in reference design)
          Positioned.fill(
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD7EFE0).withValues(alpha: 0.7),
                      const Color(0xFFE8F5E9).withValues(alpha: 0.35),
                      bgBase.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content Layout
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Center Branding & Direct Connect Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBrandHeader(),
                          const SizedBox(height: 28),
                          _buildFarmerCustomerConnectCard(),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom Reference Section (Syncing, Shield, Version)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildBottomStatusSection(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Elevated Circular App Logo
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E5E3A).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/farmer_choice_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.eco_rounded,
                size: 48,
                color: AppColors.primaryGreen,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Brand Name
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textDark,
            ),
            children: [
              TextSpan(text: 'FARMER'),
              TextSpan(
                text: ' CHOICE',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Tagline Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
          decoration: BoxDecoration(
            color: AppColors.lightGreenBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.mintGreen,
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: AppColors.primaryGreen,
                size: 13,
              ),
              SizedBox(width: 5),
              Text(
                'Direct Farm-to-Customer Connect',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerCustomerConnectCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0ECE2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E5E3A).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Node: Farmer
            _buildRoleAvatar(
              icon: Icons.agriculture_rounded,
              title: 'Farmer',
              subtitle: 'Grows Fresh',
              color: AppColors.primaryGreen,
              bgCircle: const Color(0xFFE8F5E9),
            ),

            // Center: Animated Connect Bridge
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulseVal = _pulseController.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zero Middlemen Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFD54F),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            '0% Middlemen',
                            style: TextStyle(
                              color: Color(0xFFE65100),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Handshake Hub
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: const Color(0xFFD1E7D6),
                            ),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Color.lerp(
                                    AppColors.primaryGreen,
                                    AppColors.sunlightYellow,
                                    pulseVal,
                                  )!,
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.15 + 0.15 * pulseVal),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.handshake_rounded,
                                size: 15,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Direct Deals',
                          style: TextStyle(
                            color: AppColors.textMedium,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Right Node: Customer
            _buildRoleAvatar(
              icon: Icons.shopping_bag_rounded,
              title: 'Customer',
              subtitle: 'Direct Buy',
              color: const Color(0xFF1565C0),
              bgCircle: const Color(0xFFE3F2FD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleAvatar({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgCircle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgCircle,
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStatusSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini Green Spinner (As shown in screenshot)
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Syncing Text (As shown in screenshot)
        Text(
          _statusText,
          style: const TextStyle(
            color: AppColors.textMedium,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 24),

        // Shield Protection Badge (As shown in screenshot)
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 15,
              color: AppColors.primaryGreen,
            ),
            SizedBox(width: 6),
            Text(
              'Protected by Farmer Choice Direct-Trace',
              style: TextStyle(
                color: Color(0xFF556B5C),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Version & Build Tag (As shown in screenshot)
        const Text(
          'VERSION 1.0.0',
          style: TextStyle(
            color: Color(0xFF8E9F92),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
