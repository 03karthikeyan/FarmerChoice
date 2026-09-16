import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();
    _startNavigationTimer();
  }

  // ---------------------------------------------------------------------------
  // AUTHENTICATION & NAVIGATION LOGIC (PRESERVED)
  // ---------------------------------------------------------------------------

  Future<void> _startNavigationTimer() async {
    // Keep splash visible long enough for branding
    await Future.delayed(
      const Duration(milliseconds: 2400),
    );

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // Wait until AuthProvider completes session check from disk
    int retries = 0;
    while ((authProvider.state == AuthState.initial ||
            authProvider.state == AuthState.loading) &&
        retries < 25) {
      await Future.delayed(
        const Duration(milliseconds: 100),
      );
      retries++;
      if (!mounted) return;
    }

    _navigateToNextScreen(authProvider);
  }

  void _navigateToNextScreen(AuthProvider authProvider) {
    if (!mounted) return;

    late final Widget targetScreen;

    if (authProvider.isAuthenticated) {
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
        transitionDuration: const Duration(
          milliseconds: 600,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) =>
            targetScreen,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
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
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF176B2C);
    const splashBg = Color(0xFFF9F7EF);

    return Scaffold(
      backgroundColor: splashBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen Splash Art
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                'assets/images/splash_screen_art.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: splashBg,
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: primaryGreen,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom subtle progress indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Color(0x33000000),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
