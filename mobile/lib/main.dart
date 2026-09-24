import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/vegetable_provider.dart';
import 'core/providers/deal_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/farmer_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'features/auth/login_screen.dart';
import 'features/customer/customer_main_screen.dart';
import 'features/farmer/farmer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase init error / notice: $e');
  }
  await StorageService().init();

  final authProvider = AuthProvider();
  await authProvider.checkAuthSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => VegetableProvider()),
        ChangeNotifierProvider(create: (_) => DealProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
      navigatorKey: NotificationService.navigatorKey,
      title: 'Farmer Choice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

/// Automatically opens directly into Farmer/Customer Screen or Login Screen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated && auth.currentUser != null) {
          if (auth.isFarmer) {
            return const FarmerMainScreen();
          } else {
            return const CustomerMainScreen();
          }
        }
        return const LoginScreen();
      },
    );
  }
}
