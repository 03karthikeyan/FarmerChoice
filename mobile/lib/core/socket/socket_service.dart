import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../network/api_client.dart';
import '../storage/storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await StorageService().getAccessToken();
    if (token == null) return;

    try {
      _socket = IO.io(
        ApiClient.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      _socket!.onConnect((_) {
        _isConnected = true;
        debugPrint('[Socket] Connected successfully to ${ApiClient.socketUrl}');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        debugPrint('[Socket] Disconnected');
      });

      _socket!.onConnectError((err) {
        _isConnected = false;
        debugPrint('[Socket] Connect Error: $err');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('[Socket] Exception initializing socket: $e');
    }
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', {'conversationId': conversationId});
  }

  void sendMessage(Map<String, dynamic> data, Function(dynamic) onAck) {
    _socket?.emitWithAck('send_message', data, ack: onAck);
  }

  void listenToNewMessages(Function(dynamic) onMessage) {
    _socket?.on('new_message', onMessage);
  }

  void stopListeningMessages() {
    _socket?.off('new_message');
  }

  void listenToNotifications(Function(dynamic) onNotification) {
    _socket?.on('new_notification', onNotification);
  }

  void stopListeningNotifications() {
    _socket?.off('new_notification');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
