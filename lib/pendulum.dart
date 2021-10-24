import 'package:flutter/material.dart';

class Pendulum extends StatelessWidget {
  final List<Offset> nodes;

  const Pendulum({
    Key? key,
    required this.nodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: PendulumPainter(nodes: nodes));
}

/// Draw a set of [nodes] which are Pendulum edges
class PendulumPainter extends CustomPainter {
  final List<Offset> nodes;

  const PendulumPainter({required this.nodes});

  static const _circleRadius = 10.0;
  static const _circleBorderWidth = 3.0;
  static const _circleColor = Color(0xFF000000);
  static const _circleShadowRadius = 35.0;
  static const _lineColor = Color(0xFF333333);

  static const paddingX = 35.0;
  static const paddingY = 35.0;

  void _drawCircles(
    Canvas canvas, {
    required double radius,
    required List<Offset> circles,
    required Color color,
  }) {
    for (final center in circles) {
      final path = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));

      final topBorder = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius * 1.2));

      final paint = Paint()..color = color;
      final topBorderPaint = Paint()..color = Colors.white;

      _drawCircleShadow(canvas, radius: radius, center: center);
      canvas.drawPath(topBorder, topBorderPaint);
      canvas.drawPath(path, paint);
    }
  }

  void _drawCircleShadow(
    Canvas canvas, {
    double alpha = 0.75,
    required double radius,
    required Offset center,
  }) {
    final circle = Rect.fromCircle(center: center, radius: radius);

    final shadowColor = Colors.white.withOpacity(alpha);

    final maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      _convertRadiusToSigma(_circleShadowRadius),
    );

    final path = Path()
      ..addOval(circle)
      ..fillType = PathFillType.evenOdd;

    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = maskFilter;

    canvas.drawPath(path, paint);
  }

  double _convertRadiusToSigma(double radius) => radius * 0.57735 + 0.5;

  void _drawLineFromTo(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = _circleBorderWidth;

    canvas.drawLine(from, to, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - paddingX - paddingX;
    final height = size.height - paddingY - paddingY;

    final center = Offset(width / 2 + paddingX, height / 2 + paddingY);

    final maxWidth = width / 2 / (nodes.length - 1);
    final maxHeight = height / 2 / (nodes.length - 1);

    final relativeNodes = [
      for (final node in nodes)

        /// [nodes] contains all nodes based on percentage (max 1 and min 0)
        /// We need to convert it to current avaiable screen size
        Offset(node.dx * maxWidth + center.dx, node.dy * maxHeight + center.dy),
    ];

    for (int i = 0; i < relativeNodes.length - 1; i++) {
      _drawConnection(canvas, relativeNodes[i], relativeNodes[i + 1]);
    }
  }

  void _drawConnection(Canvas canvas, Offset p1, Offset p2) {
    _drawLineFromTo(canvas, p1, p2);

    final circles = [p1, p2];

    const color = _circleColor;

    _drawCircles(canvas, radius: _circleRadius, circles: circles, color: color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
