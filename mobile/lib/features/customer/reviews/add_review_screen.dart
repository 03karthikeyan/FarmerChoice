import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/deal_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final DealModel deal;

  const AddReviewScreen({super.key, required this.deal});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share your review comments.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiClient().dio.post('/reviews', data: {
        'dealId': widget.deal.id,
        'rating': _rating,
        'comment': comment,
      });

      if (res.data['success'] == true) {
        if (mounted) {
          await Provider.of<DealProvider>(context, listen: false).fetchMyDeals(role: 'customer');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verified review posted successfully! Thank you for supporting our farmers.'),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to submit review.';
        if (e is DioException && e.response?.data?['message'] != null) {
          msg = e.response!.data['message'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.dangerRed,
          ),
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
        title: const Text('Write Verified Review', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Deal #${widget.deal.dealNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark),
                        ),
                        Text(
                          'Farmer: ${widget.deal.farmer?.name ?? 'Farmer'} • Item: ${widget.deal.vegetable?.name ?? 'Vegetable'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Rate your experience', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 36,
                    color: AppColors.sunlightYellow,
                  ),
                  onPressed: () => setState(() => _rating = (index + 1).toDouble()),
                );
              }),
            ),
            const SizedBox(height: 20),

            const Text('Your feedback & vegetable quality', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),

            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share how fresh the vegetables were, packaging, farmer communication, etc.',
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Verified Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
