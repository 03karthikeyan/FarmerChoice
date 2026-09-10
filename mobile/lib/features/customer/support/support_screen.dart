import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Deal Issue';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Account Issue',
    'Farmer Issue',
    'Deal Issue',
    'Chat Issue',
    'Fake Profile',
    'Fake Review',
    'Scam',
    'Technical',
    'Other'
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTicket() async {
    final sub = _subjectController.text.trim();
    final desc = _descriptionController.text.trim();

    if (sub.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill subject and description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiClient().dio.post('/support', data: {
        'category': _category,
        'subject': sub,
        'description': desc,
      });

      if (res.data['success'] == true) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support ticket submitted. Our team will review shortly.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit ticket')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Support Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Need help with a deal, farmer communication, or technical issue? We are here to assist.',
              style: TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 24),

            const Text('Issue Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val ?? _category),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                hintText: 'Brief summary of issue',
                prefixIcon: Icon(Icons.title, color: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what happened in detail...',
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTicket,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
