import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _contentFade;
  late final Animation<double> _footerFade;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation.
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Very subtle logo breathing animation.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.0,
          0.65,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeOut,
        ),
      ),
    );

    _contentFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.35,
          0.8,
          curve: Curves.easeOut,
        ),
      ),
    );

    _footerFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.65,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.985,
      end: 1.015,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entranceController.forward();

    _startNavigationTimer();
  }

  Future<void> _startNavigationTimer() async {
    // Keep splash visible long enough for branding.
    await Future.delayed(
      const Duration(milliseconds: 2200),
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Farmer Choice brand colors.
    const backgroundColor = Color(0xFFF7F3E8);
    const primaryGreen = Color(0xFF176B2C);
    const secondaryText = Color(0xFF667568);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              // ---------------------------------------------------------
              // TOP SPACE
              // ---------------------------------------------------------
              const Spacer(
                flex: 3,
              ),

              // ---------------------------------------------------------
              // CENTER BRANDING
              // ---------------------------------------------------------
              AnimatedBuilder(
                animation: _entranceController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ---------------------------------------------------
                    // CENTER APP LOGO
                    // ---------------------------------------------------
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/farmer_choice_logo.png',
                        width: size.width * 0.62,
                        height: size.width * 0.62,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryGreen
                                          .withValues(alpha: 0.10),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  size: 58,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),
                    // ---------------------------------------------------
                    // SHORT TAGLINE
                    // ---------------------------------------------------
                    FadeTransition(
                      opacity: _contentFade,
                      child: Text(
                        'Fresh. Local. Trusted.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------
              // SPACE BETWEEN CENTER AND FOOTER
              // ---------------------------------------------------------
              const Spacer(
                flex: 4,
              ),

              // ---------------------------------------------------------
              // BOTTOM LOADING AREA
              // ---------------------------------------------------------
              FadeTransition(
                opacity: _footerFade,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Minimal loading indicator.
                      SizedBox(
                        width: 110,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor:
                                Color(0xFFE3DDCB),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              primaryGreen,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Text(
                        'Connecting you to fresh choices',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
