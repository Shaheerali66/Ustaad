import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GoogleMapWidget extends StatefulWidget {
  final double centerLat;
  final double centerLng;
  final double zoom;
  final List<Map<String, dynamic>> markers;
  final Map<String, dynamic>? route;
  final double height;
  final BorderRadius? borderRadius;

  const GoogleMapWidget({
    super.key,
    required this.centerLat,
    required this.centerLng,
    this.zoom = 13,
    this.markers = const [],
    this.route,
    this.height = 300,
    this.borderRadius,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  @override
  Widget build(BuildContext context) {
    final double displayHeight = widget.height < 300 ? 300 : widget.height;
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    return Container(
      height: displayHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.surfaceVariant),
        color: const Color(0xFFE8F1E9), // Google Maps light background green-ish color
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Custom painter to draw grid and mock path
            Positioned.fill(
              child: CustomPaint(
                painter: _MockMapPainter(
                  markersCount: widget.markers.length,
                  hasRoute: widget.route != null,
                ),
              ),
            ),
            // Mock Search Bar Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.markers.isNotEmpty
                            ? 'Navigating to Customer...'
                            : 'Search destination...',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    const Icon(Icons.mic, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            // Mock Location Card Overlay at bottom
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'USTAAD Navigation Mode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.route != null
                                ? 'Directions loaded. Routing worker to customer.'
                                : 'Coordinates: ${widget.centerLat.toStringAsFixed(4)}, ${widget.centerLng.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Compass and Zoom Buttons Overlay on the side
            Positioned(
              right: 12,
              top: 70,
              child: Column(
                children: [
                  _circleButton(Icons.explore, Colors.white, Colors.black87),
                  const SizedBox(height: 8),
                  _circleButton(Icons.add, Colors.white, Colors.black87),
                  const SizedBox(height: 4),
                  _circleButton(Icons.remove, Colors.white, Colors.black87),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, Color bg, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(icon, color: fg, size: 18),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  final int markersCount;
  final bool hasRoute;

  _MockMapPainter({required this.markersCount, required this.hasRoute});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0;

    // Draw grid lines
    const double gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw mock major road green-ish outline
    final roadPaint = Paint()
      ..color = const Color(0xFFFCFDF9)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD4E3D5)
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(20, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.85,
        size.width * 0.6,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.1,
        size.width - 20,
        size.height * 0.3,
      );

    canvas.drawPath(path, roadBorderPaint);
    canvas.drawPath(path, roadPaint);

    // Draw another intersecting road
    final path2 = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.2,
        size.height,
      );

    canvas.drawPath(path2, roadBorderPaint);
    canvas.drawPath(path2, roadPaint);

    // Draw route if active
    if (hasRoute) {
      final routePaint = Paint()
        ..color = const Color(0xFF4285F4) // Google Blue
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final routePath = Path()
        ..moveTo(size.width * 0.3, size.height * 0.6)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.45,
          size.width * 0.7,
          size.height * 0.4,
        );

      canvas.drawPath(routePath, routePaint);

      // Draw dashed inner line to make it look even cooler
      final dashPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Draw worker pin (Blue)
      _drawPin(canvas, Offset(size.width * 0.3, size.height * 0.6), Colors.blue, "Worker");

      // Draw customer pin (Red)
      _drawPin(canvas, Offset(size.width * 0.7, size.height * 0.4), Colors.red, "Customer");
    } else {
      // Just draw center pin
      _drawPin(canvas, Offset(size.width / 2, size.height / 2), AppColors.primary, "Location");
    }
  }

  void _drawPin(Canvas canvas, Offset position, Color color, String label) {
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(Offset(position.dx, position.dy + 2), 6, shadowPaint);

    final pinPaint = Paint()..color = color;
    canvas.drawCircle(position, 6, pinPaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(position, 2.5, innerPaint);

    // Pin stem
    final stemPath = Path()
      ..moveTo(position.dx - 3, position.dy + 2)
      ..lineTo(position.dx, position.dy + 10)
      ..lineTo(position.dx + 3, position.dy + 2)
      ..close();
    canvas.drawPath(stemPath, pinPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - 18),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
