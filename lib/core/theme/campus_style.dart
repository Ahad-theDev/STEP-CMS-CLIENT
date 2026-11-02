import 'app_colors.dart';
import 'package:flutter/material.dart';

class CampusBackground extends StatelessWidget {
  const CampusBackground({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // Base luminous gradient: rich light purple with soft pinkish-blue tint
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDDD5F3),
                Color(0xFFE8E0F8),
                Color(0xFFEEF0FC),
                Color(0xFFD8E6FA),
                Color(0xFFE6EDF9), // Crisp campus slate base
              ],
              stops: [0.0, 0.25, 0.55, 0.80, 1.0],
            ),
          ),
        ),
      ),
      // Deep glowing ambient purple orb (top-left)
      Positioned(
        top: -60,
        left: -50,
        child: IgnorePointer(
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x248B5CF6), // Noticeable glowing purple
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      // Ambient soft blue glow (top-right)
      Positioned(
        top: 80,
        right: -60,
        child: IgnorePointer(
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x263B82F6), // Soft blue light
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      // Mid-left subtle purple glow
      Positioned(
        top: 280,
        left: -50,
        child: IgnorePointer(
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x127C3AED), // Secondary soft purple glow
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      // Ambient pastel blue glow orb (bottom-left)
      Positioned(
        bottom: -60,
        left: -20,
        child: IgnorePointer(
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0x2238BDF8), // Airy light blue
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      const Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CampusBackgroundPainter()),
          ),
        ),
      ),
    ],
  );
}

// Quiet architectural lines keep the background decorative and unobtrusive.
class _CampusBackgroundPainter extends CustomPainter {
  const _CampusBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = const Color(0x145266A0);
    for (double x = 20; x < size.width; x += 32) {
      for (double y = 20; y < size.height; y += 32) {
        canvas.drawCircle(Offset(x, y), 0.8, dots);
      }
    }
    final lines = Paint()
      ..color = const Color(0x165668AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final radius in [160.0, 204.0, 248.0]) {
      canvas.drawCircle(
        Offset(size.width + 55, size.height * 0.22),
        radius,
        lines,
      );
      canvas.drawCircle(Offset(-90, size.height * 0.86), radius, lines);
    }
  }

  @override
  bool shouldRepaint(covariant _CampusBackgroundPainter oldDelegate) => false;
}

class CampusStyle {
  CampusStyle._();
  static const primary = AppColors.primary;
  static const accent = AppColors.secondary;
  static const ink = AppColors.onSurface;
  static const muted = AppColors.onSurfaceVariant;
  static BoxDecoration get card => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFF6F1FF), Color(0xFFF0F6FF)],
      stops: [0, .55, 1],
    ),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFDADDF4)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x127C3AED),
        blurRadius: 30,
        offset: Offset(0, 10),
      ),
    ],
  );
  static InputDecoration input(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: muted, fontSize: 13),
    floatingLabelStyle: const TextStyle(
      color: accent,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(icon, color: accent, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD9DFF0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: accent, width: 1.8),
    ),
  );
}
