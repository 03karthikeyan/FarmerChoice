import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PromoSliderBanner extends StatefulWidget {
  const PromoSliderBanner({super.key});

  @override
  State<PromoSliderBanner> createState() => _PromoSliderBannerState();
}

class _PromoSliderBannerState extends State<PromoSliderBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _slides = [
    {
      'tag': '100% DIRECT',
      'title': 'Zero Middlemen Commission',
      'subtitle': 'Connect directly with local verified farmers at transparent mandi rates.',
      'icon': Icons.handshake_rounded,
      'gradient': const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      'badgeColor': Color(0xFFC8E6C9),
      'badgeTextColor': Color(0xFF1B5E20),
    },
    {
      'tag': 'DIRECT PAYMENT',
      'title': 'Pay Farmer on Delivery',
      'subtitle': 'Zero platform fees. Inspect vegetables & pay farmers directly via Cash/UPI.',
      'icon': Icons.verified_user_rounded,
      'gradient': const [Color(0xFF004D40), Color(0xFF00796B)],
      'badgeColor': Color(0xFFB2DFDB),
      'badgeTextColor': Color(0xFF004D40),
    },
    {
      'tag': 'FRESH HARVEST',
      'title': 'Farm to Kitchen in Hours',
      'subtitle': 'Harvested fresh every morning directly from organic farms in your district.',
      'icon': Icons.eco_rounded,
      'gradient': const [Color(0xFF33691E), Color(0xFF558B2F)],
      'badgeColor': Color(0xFFDCEDC8),
      'badgeTextColor': Color(0xFF33691E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextPage = _currentPage + 1;
      if (nextPage >= _slides.length) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (slide['gradient'][0] as Color).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: slide['badgeColor'] as Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slide['tag'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: slide['badgeTextColor'] as Color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slide['subtitle'] as String,
                            style: const TextStyle(
                              color: Color(0xFFE8F5E9),
                              fontSize: 11,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(slide['icon'] as IconData, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primaryGreen : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
