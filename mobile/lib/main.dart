import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/vegetable_provider.dart';
import 'core/providers/deal_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/farmer_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/customer_main_screen.dart';
import 'features/farmer/farmer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error / skipped: $e');
  }
  await StorageService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VegetableProvider()),
        ChangeNotifierProvider(create: (_) => DealProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
      ],
      child: const FarmerChoiceApp(),
    ),
  );
}

class FarmerChoiceApp extends StatelessWidget {
  const FarmerChoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Choice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootRoleNavigator(),
    );
  }
}

class RootRoleNavigator extends StatelessWidget {
  const RootRoleNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Initial cold startup splash screen only
    if (authProvider.state == AuthState.initial) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/farmer_choice_logo.png',
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF1B5E20),
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const CircularProgressIndicator(
                color: Color(0xFF1B5E20),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      );
    }

    // Authenticated role-based dynamic navigation
    if (authProvider.isAuthenticated) {
      if (authProvider.isFarmer) {
        return const FarmerMainScreen();
      } else {
        return const CustomerMainScreen();
      }
    }

    // Not logged in
    return const LoginScreen();
  }
}
