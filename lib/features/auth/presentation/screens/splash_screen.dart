import 'package:cms/core/theme/campus_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/application/auth_repository_provider.dart';
import '../../../auth/data/models/auth_user.dart';

/// Splash screen with logo animation and smooth transition to login.
///
/// Features:
/// - Rounded-square logo matching native launch, then a gentle bounce
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
  static const double _logoSize = 128;

  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

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

    // First frame matches the native tile; then bounce gently and settle.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.12,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
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

  Future<void> _onAnimationComplete() async {
    if (!mounted || _hasNavigated) return;

    try {
      final storage = ref.read(secureStorageProvider);
      final repo = ref.read(authRepositoryProvider);
      final token = await storage.getAccessToken();

      if (token == null) {
        _goToLogin();
        return;
      }

      try {
        final user = await repo.getCurrentUser();
        _goToDashboard(user);
        return;
      } catch (_) {
        // Access token might just be expired — try one refresh before giving up.
      }

      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final newAccess = await repo.refreshAccessToken(refreshToken);
          await storage.saveToken(
            accessToken: newAccess,
            refreshToken: refreshToken,
          );
          final user = await repo.getCurrentUser();
          _goToDashboard(user);
          return;
        } catch (_) {
          // fall through to login
        }
      }

      await storage.clearToken();
      _goToLogin();
    } catch (_) {
      // If anything goes wrong, go to login screen as fallback
      if (mounted) {
        _goToLogin();
      }
    }
  }

  Future<void> _goToLogin() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _goToDashboard(AuthUser user) async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _prefersReducedMotion
        ? const AlwaysStoppedAnimation<double>(1)
        : _opacityAnimation;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4DF),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: opacity,
                child: const CampusBackground(),
              ),
            ),
            // Match native size and position before the Flutter bounce begins.
            Center(
              child: SizedBox(
                width: _logoSize,
                height: _logoSize,
                child: ScaleTransition(
                  scale: _prefersReducedMotion
                      ? const AlwaysStoppedAnimation<double>(1)
                      : _scaleAnimation,
                  child: _buildLogo(context),
                ),
              ),
            ),
            Positioned(
              top: constraints.maxHeight / 2 + _logoSize / 2 + 24,
              left: 24,
              right: 24,
              bottom: 16,
              child: FadeTransition(
                opacity: opacity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'CITY IDEAL SCHOOL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: CampusStyle.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'School portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: CampusStyle.muted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_prefersReducedMotion)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CampusStyle.primary,
                            semanticsLabel: 'Opening your campus portal',
                          ),
                        ),
                      const SizedBox(height: 14),
                      const Text(
                        'Opening your campus portal…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: CampusStyle.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _logoSize),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF4DF), Color(0xFFFFDFAC)],
            ),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0x80F18432), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28243C78),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x183B82F6),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'lib/core/assets/logo/city_ideal_school.jpeg',
              fit: BoxFit.contain,
              semanticLabel: 'City Ideal School crest',
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school_rounded,
                size: 90,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
