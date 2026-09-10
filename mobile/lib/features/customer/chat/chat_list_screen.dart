import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/chat_provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = Provider.of<AuthProvider>(context, listen: false).currentUser?.role ?? 'CUSTOMER';
      Provider.of<ChatProvider>(context, listen: false).fetchConversations(role: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isFarmerRole = authProvider.currentUser?.role == 'FARMER';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isFarmerRole ? 'Customer Inquiries' : 'Farmer Conversations',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => chatProvider.fetchConversations(role: isFarmerRole ? 'FARMER' : 'CUSTOMER'),
        color: AppColors.primaryGreen,
        child: chatProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : chatProvider.conversations.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 50, color: AppColors.textLight),
                            SizedBox(height: 12),
                            Text(
                              'No chat messages yet.',
                              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap "Chat with Farmer" on any vegetable to start a conversation.',
                              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: chatProvider.conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final conv = chatProvider.conversations[index];
                      final partner = isFarmerRole ? conv.customer : conv.farmer;
                      final partnerName = partner?.name ?? (isFarmerRole ? 'Customer' : 'Farmer');

                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: conv.id,
                                recipientName: partnerName,
                                vegetableName: conv.vegetable?.name,
                              ),
                            ),
                          );
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                partner?.profileImage.isNotEmpty == true
                                    ? partner!.profileImage
                                    : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          partnerName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
                        ),
                        subtitle: Text(
                          conv.lastMessageText.isNotEmpty ? conv.lastMessageText : 'No messages yet',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: conv.unreadCount > 0
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${conv.unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textLight),
                      );
                    },
                  ),
      ),
    );
  }
}
