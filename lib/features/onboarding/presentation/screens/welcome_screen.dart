import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/preferences_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentSlide = 0;
  late PageController _pageController;

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
      title: 'Welcome to Fridge Forager',
      description:
          'Manage your food inventory and reduce waste with smart tracking.',
      color: const Color(0xFF2D5016),
    ),
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1662219904792-57feb861791f?q=80&w=745',
      title: 'Track Expiry Dates',
      description:
          'Never waste food again! Get reminders for items about to expire.',
      color: const Color(0xFFD4441B),
    ),
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=687',
      title: 'Discover Recipes',
      description:
          'Find delicious recipes based on ingredients you already have.',
      color: const Color(0xFF8B4513),
    ),
    OnboardingSlide(
      imageUrl:
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=800&q=80',
      title: 'Shop Smart',
      description:
          'Keep a smart shopping list and sync it across your devices.',
      color: const Color(0xFF1B5E20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(slides[index]);
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: _handleSkip,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45, Colors.black87],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: slides.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 7,
                      dotWidth: 7,
                      spacing: 6,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2D5016),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black.withValues(alpha: 0.25),
                      ),
                      onPressed: _handleGetStarted,
                      child: Text(
                        _currentSlide == slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
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

  Widget _buildSlide(OnboardingSlide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: slide.color,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: slide.color,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Loading image...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleGetStarted() {
    if (_currentSlide == slides.length - 1) {
      PreferencesService().markOnboardingComplete();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth',
        (route) => false,
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSkip() {
    PreferencesService().markOnboardingComplete();
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/auth',
      (route) => false,
    );
  }
}

class OnboardingSlide {
  final String imageUrl;
  final String title;
  final String description;
  final Color color;

  OnboardingSlide({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.color,
  });
}
