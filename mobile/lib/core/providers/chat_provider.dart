import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../network/api_client.dart';
import '../socket/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _activeMessages = [];
  String? _activeConversationId;
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get activeMessages => _activeMessages;
  String? get activeConversationId => _activeConversationId;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    SocketService().listenToNewMessages((data) {
      if (data is Map<String, dynamic>) {
        final message = MessageModel.fromJson(data);
        if (_activeConversationId != null && message.conversationId == _activeConversationId) {
          _activeMessages.add(message);
          notifyListeners();
        }
      }
    });
  }

  Future<void> fetchConversations({String role = 'CUSTOMER'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().dio.get('/chat/conversations');
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _conversations = list.map((json) => ConversationModel.fromJson(json, currentRole: role)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> openConversation({
    required String farmerId,
    required String customerId,
    String? vegetableId,
    String? dealId,
  }) async {
    try {
      final res = await ApiClient().dio.post('/chat/conversations', data: {
        'farmerId': farmerId,
        'customerId': customerId,
        'vegetableId': vegetableId,
        'dealId': dealId,
      });

      if (res.data['success'] == true) {
        final convId = res.data['data']['_id'];
        _activeConversationId = convId;
        SocketService().joinConversation(convId);
        await fetchMessages(convId);
        return convId;
      }
    } catch (e) {
      debugPrint('Error opening conversation: $e');
    }
    return null;
  }

  Future<void> fetchMessages(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().dio.get('/chat/conversations/$conversationId/messages');
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _activeMessages = list.map((json) => MessageModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? imageUrl}) async {
    if (_activeConversationId == null || text.trim().isEmpty) return;

    final data = {
      'conversationId': _activeConversationId,
      'text': text.trim(),
      'imageUrl': imageUrl ?? '',
    };

    try {
      final res = await ApiClient().dio.post(
        '/chat/conversations/$_activeConversationId/messages',
        data: data,
      );

      if (res.data['success'] == true) {
        final message = MessageModel.fromJson(res.data['data']);
        _activeMessages.add(message);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void leaveActiveChat() {
    if (_activeConversationId != null) {
      SocketService().leaveConversation(_activeConversationId!);
      _activeConversationId = null;
      _activeMessages = [];
    }
  }
}
