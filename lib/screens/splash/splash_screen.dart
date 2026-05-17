import 'package:fizmat_app/providers/auth_provider.dart';
import 'package:fizmat_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Icon animation controller (scale and rotation)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade out controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Icon scale animation with elastic effect
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    // Icon rotation animation (subtle)
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOutBack,
      ),
    );

    // Text opacity animation
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Wait a bit before starting
    await Future.delayed(const Duration(milliseconds: 300));

    // Start icon animation
    await _iconController.forward();

    // Small delay before text
    await Future.delayed(const Duration(milliseconds: 200));

    // Start text animation
    await _textController.forward();

    // Wait to show the full splash
    await Future.delayed(const Duration(milliseconds: 800));

    // Check authentication and navigate
    if (mounted) {
      await _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait a bit for auth to initialize
    await Future.delayed(const Duration(milliseconds: 300));

    // Check for birthdays and create notifications (runs in background)
    _checkBirthdaysAndCleanup();

    // Fade out animation
    await _fadeController.forward();

    if (!mounted) return;

    // Navigate based on auth state
    if (authProvider.isAuthenticated && authProvider.userModel != null) {
      // User is logged in - go to main app
      Navigator.pushReplacementNamed(context, '/FizNavBar');
    } else {
      // User not logged in - go to login
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  /// Check for birthdays and cleanup expired notifications
  Future<void> _checkBirthdaysAndCleanup() async {
    try {
      final notificationService = NotificationService();

      // Create birthday notifications for today (if any)
      await notificationService.createBirthdayNotifications();

      // Clean up expired notifications (older than 30 days)
      await notificationService.cleanupExpiredNotifications();
    } catch (e) {
      // Silently fail - don't block app startup
      debugPrint('Error checking birthdays/cleanup: $e');
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F1D4E),
                Color(0xFF1B2A6B),
                Color(0xFF24357A),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Icon
                  AnimatedBuilder(
                    animation: _iconController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _iconRotationAnimation.value,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/app_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Animated Text
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: const Column(
                            children: [
                              Text(
                                'FizmatApp',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
