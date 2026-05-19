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
  late AnimationController _fadeController;

  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _iconController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 300));
    _checkBirthdaysAndCleanup();
    await _fadeController.forward();
    if (!mounted) return;
    if (authProvider.isAuthenticated && authProvider.userModel != null) {
      Navigator.pushReplacementNamed(context, '/FizNavBar');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _checkBirthdaysAndCleanup() async {
    try {
      final notificationService = NotificationService();
      await notificationService.createBirthdayNotifications();
      await notificationService.cleanupExpiredNotifications();
    } catch (e) {
      debugPrint('Error checking birthdays/cleanup: $e');
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: const Color(0xFF00285C),
          child: Center(
            child: AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _iconRotationAnimation.value,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Image.asset(
                        'assets/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
