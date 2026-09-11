import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../network/api_client.dart';
import '../socket/socket_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotificationProvider() {
    _initSocketListener();
  }

  void _initSocketListener() {
    // Listen to real-time notifications arriving via Socket.IO
    SocketService().listenToNotifications((data) {
      try {
        if (data is Map<String, dynamic>) {
          final notification = AppNotification.fromJson(data);
          handleIncomingNotification(notification);
        }
      } catch (e) {
        debugPrint('Socket notification parsing error: $e');
      }
    });

    // Also register foreground FCM listener
    NotificationService().onForegroundMessageReceived = (message) {
      final notif = AppNotification(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '',
        title: message.notification?.title ?? message.data['title'] ?? 'Notification',
        body: message.notification?.body ?? message.data['body'] ?? '',
        type: message.data['type'] ?? 'SYSTEM_ANNOUNCEMENT',
        referenceId: message.data['referenceId'],
        referenceType: message.data['referenceType'],
        isRead: false,
        createdAt: DateTime.now(),
      );
      // If not already in notifications
      if (!_notifications.any((n) => n.id == notif.id)) {
        _notifications.insert(0, notif);
        _unreadCount += 1;
        notifyListeners();
      }
    };
  }

  /// Fetch all notifications from backend
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/notifications');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        _notifications = list.map((item) => AppNotification.fromJson(item)).toList();
        _unreadCount = response.data['unreadCount'] ?? _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch unread notifications count for badges
  Future<void> fetchUnreadCount() async {
    try {
      final response = await ApiClient().dio.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _unreadCount = response.data['unreadCount'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  /// Receive notification in real-time (from Socket.IO or FCM foreground handler)
  void handleIncomingNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount += 1;
    notifyListeners();

    // Show drop-down in-app banner for foreground feedback
    NotificationService().showForegroundBanner(
      title: notification.title,
      body: notification.body,
      data: {
        'type': notification.type,
        'referenceId': notification.referenceId,
      },
    );
  }

  /// Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      if (_unreadCount > 0) _unreadCount -= 1;
      notifyListeners();

      try {
        await ApiClient().dio.patch('/notifications/$notificationId/read');
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      await ApiClient().dio.patch('/notifications/read-all');
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
