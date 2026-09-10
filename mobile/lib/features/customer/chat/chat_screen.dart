import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String recipientName;
  final String? vegetableName;
  final String? dealNumber;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.vegetableName,
    this.dealNumber,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchMessages(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final chatProv = Provider.of<ChatProvider>(context, listen: false);
    await chatProv.sendMessage(text);

    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () {
            Provider.of<ChatProvider>(context, listen: false).leaveActiveChat();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.lightGreenBg,
              child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Contextual deal or vegetable banner
          if (widget.vegetableName != null || widget.dealNumber != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.lightGreenBg,
              child: Row(
                children: [
                  const Icon(Icons.eco, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    widget.vegetableName != null
                        ? 'Topic: ${widget.vegetableName}'
                        : 'Deal Reference: #${widget.dealNumber}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: chatProvider.activeMessages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.activeMessages[index];
                      final isMe = msg.senderId == currentUserId;
                      final timeStr = DateFormat('h:mm a').format(msg.createdAt);

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                            ),
                            border: Border.all(
                              color: isMe ? const Color(0xFFC5E1A5) : AppColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.text,
                                style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, height: 1.3),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.done_all, size: 13, color: AppColors.primaryGreen),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.textLight),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image upload supported')),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FAF6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
