import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../network/api_client.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUploadImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      return await uploadXFile(pickedFile);
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick or upload image: $e')),
        );
      }
      return null;
    }
  }

  Future<String?> uploadXFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty
          ? file.name
          : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (kIsWeb) {
        // Use base64 upload on Web
        final base64String = base64Encode(bytes);
        final mime = file.mimeType ?? 'image/jpeg';
        final dataUrl = 'data:$mime;base64,$base64String';

        final res = await ApiClient().dio.post(
          '/upload/base64',
          data: {
            'base64Data': dataUrl,
            'filename': filename,
          },
        );

        if (res.data['success'] == true && res.data['data'] != null) {
          final relativeUrl = res.data['data']['url'];
          return _formatImageUrl(relativeUrl);
        }
      } else {
        // Try multipart upload on Mobile
        try {
          final formData = FormData.fromMap({
            'image': MultipartFile.fromBytes(
              bytes,
              filename: filename,
            ),
          });

          final res = await ApiClient().dio.post(
            '/upload',
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
            ),
          );

          if (res.data['success'] == true && res.data['data'] != null) {
            final relativeUrl = res.data['data']['url'];
            return _formatImageUrl(relativeUrl);
          }
        } catch (multipartErr) {
          debugPrint('Multipart upload failed: $multipartErr. Attempting base64 fallback...');
          // Fallback to base64
          final base64String = base64Encode(bytes);
          final mime = file.mimeType ?? 'image/jpeg';
          final dataUrl = 'data:$mime;base64,$base64String';

          final res = await ApiClient().dio.post(
            '/upload/base64',
            data: {
              'base64Data': dataUrl,
              'filename': filename,
            },
          );

          if (res.data['success'] == true && res.data['data'] != null) {
            final relativeUrl = res.data['data']['url'];
            return _formatImageUrl(relativeUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Upload API error: $e');
      rethrow;
    }
    return null;
  }

  static String _formatImageUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }
    final socketUrl = ApiClient.socketUrl;
    final cleanPath = relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl';
    return '$socketUrl$cleanPath';
  }

  // Show bottom sheet to choose Camera or Gallery
  Future<String?> showImageSourceDialog(BuildContext context) async {
    final ImageSource? selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B381E),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                  _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedSource == null) return null;

    if (!context.mounted) return null;

    return await pickAndUploadImage(
      context: context,
      source: selectedSource,
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Icon(icon, color: const Color(0xFF1B5E20), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B381E),
            ),
          ),
        ],
      ),
    );
  }
}
