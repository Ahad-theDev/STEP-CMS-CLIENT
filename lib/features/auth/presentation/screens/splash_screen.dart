import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_screen.dart';

/// Splash screen with logo animation and smooth transition to login.
///
/// Features:
/// - Bounce/scale animation on the logo
/// - Minimum display duration to prevent flashing
/// - Respects reduced motion accessibility setting
/// - Smooth page transition to login screen
/// - Robust error handling for asset loading
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Configuration constants
  static const Duration _minDisplayDuration = Duration(milliseconds: 1500);
  static const Duration _animationDuration = Duration(milliseconds: 1200);
  static const Duration _transitionDuration = Duration(milliseconds: 400);
  static const double _logoSize = 220;
  static const double _maxScale = 1.15;
  static const double _minScale = 0.85;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  bool _hasNavigated = false;
  bool _prefersReducedMotion = false;
  bool _dependenciesReady = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    // Scale animation: starts at 0.85, bounces to 1.15, settles at 1.0
    _scaleAnimation = TweenSequence<double>([
      // Scale up with overshoot (bounce effect)
      TweenSequenceItem(
        tween: Tween<double>(begin: _minScale, end: _maxScale)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      // Settle back to 1.0
      TweenSequenceItem(
        tween: Tween<double>(begin: _maxScale, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // Opacity animation for fade-in
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is now available - check for reduced motion preference
    if (!_dependenciesReady) {
      _dependenciesReady = true;
      _prefersReducedMotion = MediaQuery.of(context).disableAnimations;
      _startSplashSequence();
    }
  }

  Future<void> _startSplashSequence() async {
    if (_prefersReducedMotion) {
      // Skip animation, just wait minimum duration
      await Future.delayed(_minDisplayDuration);
      if (mounted) _onAnimationComplete();
    } else {
      // Start animation and minimum duration timer in parallel
      final animationFuture = _animationController.forward();
      final minDurationFuture = Future.delayed(_minDisplayDuration);

      // Wait for both to complete
      await Future.wait([animationFuture, minDurationFuture]);

      if (mounted) _onAnimationComplete();
    }
  }

  void _onAnimationComplete() {
    if (!mounted || _hasNavigated) return;

    // Navigate to login screen with smooth transition
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionDuration: _transitionDuration,
        reverseTransitionDuration: _transitionDuration,
        transitionsBuilder: (_, animation, _, child) {
          // Fade + slight scale transition
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _scaleAnimation.value.clamp(0.0, double.infinity),
                child: child,
              ),
            );
          },
          child: _buildLogo(context),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with container for visual consistency
        Container(
          width: _logoSize,
          height: _logoSize,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'lib/core/assets/logo/CMS-LOGO-F.png',
              fit: BoxFit.contain, // Changed to contain to show full image
              width: _logoSize,
              height: _logoSize,
              // Error handling for missing/corrupt asset
              errorBuilder: (context, error, stackTrace) {
                // Log error in debug mode
                assert(() {
                  debugPrint('SplashScreen: Failed to load logo asset: $error');
                  return true;
                }());
                // Fallback to icon
                return Icon(
                  Icons.school_rounded,
                  size: _logoSize * 0.5,
                  color: colorScheme.primary,
                );
              },
              // Loading builder for smoother UX
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
            ),
          ),
        ),
        // Optional: App name below logo (can be removed if not needed)
        // const SizedBox(height: 24),
        // Text(
        //   'STEP CMS',
        //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        //         fontWeight: FontWeight.w700,
        //         color: colorScheme.onSurface,
        //         letterSpacing: -0.5,
        //       ),
        // ),
      ],
    );
  }
}