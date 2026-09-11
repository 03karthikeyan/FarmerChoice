import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';
import '../constants/app_colors.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 Background FCM message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title ?? message.data['title']}');
  debugPrint('Body: ${message.notification?.body ?? message.data['body']}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Function(RemoteMessage)? onForegroundMessageReceived;

  Future<void> initialize() async {
    try {
      // 1. Request notification permissions (Android 13+ & iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 FCM Notification authorization status: ${settings.authorizationStatus}');

      // Set foreground notification presentation options
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Obtain FCM Token and sync with Backend
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint('📲 FCM Device Token: $token');
        await registerFcmTokenWithBackend(token);
      }

      // 3. Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        await registerFcmTokenWithBackend(newToken);
      });

      // 4. Foreground message listener (triggers real-time in-app foreground banner)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('⚡ Foreground FCM Notification: ${message.notification?.title}');
        
        // Trigger callback if registered
        onForegroundMessageReceived?.call(message);

        // Show in-app banner for active user experience
        showForegroundBanner(
          title: message.notification?.title ?? message.data['title'] ?? 'Notification',
          body: message.notification?.body ?? message.data['body'] ?? '',
          data: message.data,
        );
      });

      // 5. App opened from background notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📱 Notification clicked from background: ${message.data}');
        handleNotificationClick(message.data);
      });

      // 6. App launched from terminated state via notification tap
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App launched from terminated state via notification: ${initialMessage.data}');
        handleNotificationClick(initialMessage.data);
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing NotificationService: $e');
    }
  }

  /// Register FCM token with backend API
  Future<void> registerFcmTokenWithBackend(String token) async {
    try {
      final response = await ApiClient().dio.post(
        '/notifications/fcm-token',
        data: {'fcmToken': token},
      );
      if (response.statusCode == 200) {
        debugPrint('✅ FCM Token successfully synced with Farmer Choice backend.');
      }
    } catch (e) {
      debugPrint('ℹ️ FCM token sync notice: $e');
    }
  }

  /// Display a floating real-time banner when app is in the foreground
  void showForegroundBanner({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ForegroundNotificationToast(
        title: title,
        body: body,
        onTap: () {
          overlayEntry.remove();
          if (data != null) {
            handleNotificationClick(data);
          }
        },
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Automatically remove toast after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Handle routing / screen opening when user taps on a notification
  void handleNotificationClick(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    debugPrint('👉 Handling notification click for type: $type, data: $data');
    // Navigation can be handled or screen opened based on referenceId/type
  }
}

/// Rich in-app drop-down notification toast for foreground alerts
class _ForegroundNotificationToast extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _ForegroundNotificationToast({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_ForegroundNotificationToast> createState() => _ForegroundNotificationToastState();
}

class _ForegroundNotificationToastState extends State<_ForegroundNotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B382B),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.body,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
