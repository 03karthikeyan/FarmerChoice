import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/login_screen.dart';
import '../support/support_screen.dart';
import 'edit_customer_profile_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  void _confirmSignOut(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFF176B2C)),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out from your Customer account?',
          style: TextStyle(fontSize: 13, color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF176B2C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed),
            SizedBox(width: 8),
            Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your customer account? All your requests, chats, reviews, and favorites will be permanently erased. This cannot be undone.',
          style: TextStyle(fontSize: 13, color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await authProvider.deleteAccount();
              if (ok && context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } else if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.errorMessage.isNotEmpty ? authProvider.errorMessage : 'Failed to delete account.'),
                    backgroundColor: AppColors.dangerRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF176B2C), size: 28),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditCustomerProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE8F5E9),
                    backgroundImage: (user?.profileImage != null && user!.profileImage.isNotEmpty)
                        ? NetworkImage(user.profileImage)
                        : null,
                    child: (user?.profileImage == null || user!.profileImage.isEmpty)
                        ? Text(
                            user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'C',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF176B2C)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Customer Name',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.phone ?? '',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ROLE: CUSTOMER',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF176B2C)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Quick Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditCustomerProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF176B2C), size: 18),
                label: const Text('Edit Profile Information', style: TextStyle(color: Color(0xFF176B2C), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF176B2C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Color(0xFF176B2C)),
                    title: const Text('Help & Support Tickets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: Color(0xFF176B2C)),
                    title: const Text('Safety & Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Direct payment & meeting advice', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Farmer Choice Safety Rules'),
                          content: const Text(
                            '1. Farmer Choice never processes money.\n2. Always verify vegetables before cash or direct UPI payment.\n3. Never share passwords or bank OTPs with anyone.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('I Understand')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.translate, color: Color(0xFF176B2C)),
                    title: const Text('Language / மொழி', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Text('English / தமிழ்', style: TextStyle(fontSize: 12, color: Color(0xFF176B2C), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context, authProvider),
                icon: const Icon(Icons.logout, color: Color(0xFF176B2C)),
                label: const Text('Sign Out', style: TextStyle(color: Color(0xFF176B2C), fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF176B2C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _confirmDeleteAccount(context, authProvider),
                icon: const Icon(Icons.delete_forever_rounded, color: AppColors.dangerRed, size: 20),
                label: const Text('Delete Customer Account', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
