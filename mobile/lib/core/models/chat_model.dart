import 'user_model.dart';
import 'vegetable_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final String messageType;
  final String imageUrl;
  final bool isRead;
  final DateTime createdAt;
  final UserModel? sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.messageType = 'TEXT',
    this.imageUrl = '',
    this.isRead = false,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    UserModel? senderObj;
    if (json['senderId'] is Map<String, dynamic>) {
      senderObj = UserModel.fromJson(json['senderId']);
    }

    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: senderObj != null ? senderObj.id : (json['senderId'] ?? ''),
      receiverId: json['receiverId'] ?? '',
      text: json['text'] ?? '',
      messageType: json['messageType'] ?? 'TEXT',
      imageUrl: json['imageUrl'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      sender: senderObj,
    );
  }
}

class ConversationModel {
  final String id;
  final String customerId;
  final String farmerId;
  final UserModel? customer;
  final UserModel? farmer;
  final VegetableModel? vegetable;
  final String lastMessageText;
  final int unreadCount;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.customerId,
    required this.farmerId,
    this.customer,
    this.farmer,
    this.vegetable,
    this.lastMessageText = '',
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {String currentRole = 'CUSTOMER'}) {
    UserModel? cust;
    if (json['customerId'] is Map<String, dynamic>) {
      cust = UserModel.fromJson(json['customerId']);
    }

    UserModel? farm;
    if (json['farmerId'] is Map<String, dynamic>) {
      farm = UserModel.fromJson(json['farmerId']);
    }

    VegetableModel? veg;
    if (json['vegetableId'] is Map<String, dynamic>) {
      veg = VegetableModel.fromJson(json['vegetableId']);
    }

    String lastText = '';
    if (json['lastMessage'] is Map<String, dynamic>) {
      lastText = json['lastMessage']['text'] ?? '';
    }

    final unread = currentRole == 'CUSTOMER'
        ? (json['unreadCountCustomer'] ?? 0)
        : (json['unreadCountFarmer'] ?? 0);

    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: cust != null ? cust.id : (json['customerId'] ?? ''),
      farmerId: farm != null ? farm.id : (json['farmerId'] ?? ''),
      customer: cust,
      farmer: farm,
      vegetable: veg,
      lastMessageText: lastText,
      unreadCount: unread,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
