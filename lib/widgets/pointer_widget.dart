import 'package:flutter/material.dart';

enum PointerPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Use this widget around your existing child (e.g. SizedBox with WebView).
class TooltipWithFlushArrow extends StatelessWidget {
  final Widget child;
  final PointerPosition pointerPosition;
  final double arrowSize;
  final Color color;
  final double borderRadius;
  final double height;

  const TooltipWithFlushArrow({
    super.key,
    required this.child,
    this.pointerPosition = PointerPosition.bottom,
    this.arrowSize = 10.0,
    this.color = Colors.black87,
    this.borderRadius = 8.0,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Stack so arrow can overflow without changing child's layout
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.loose,
        clipBehavior: Clip.none,
        children: [
          // The main content (no padding added)
          child,

          // Arrow - positioned depending on pointerPosition using negative offsets
          if (pointerPosition == PointerPosition.bottom)
            Positioned(
              // left: null,
              right: null,
              bottom: -arrowSize, // negative to overlap flush
              left: MediaQuery.of(context).size.width * 0.5 - arrowSize,
              child: _Triangle(
                size: arrowSize,
                color: color,
                direction: PointerPosition.bottom,
              ),
            )
          else if (pointerPosition == PointerPosition.top)
            Positioned(
              top: -arrowSize,
              left: MediaQuery.of(context).size.width * 0.5 - arrowSize,
              child: _Triangle(
                size: arrowSize,
                color: color,
                direction: PointerPosition.top,
              ),
            )
          else if (pointerPosition == PointerPosition.left)
            Positioned(
              left: -arrowSize,
              top: (_centerY(context, child) ?? 0) - arrowSize,
              child: _Triangle(
                size: arrowSize,
                color: color,
                direction: PointerPosition.left,
              ),
            )
          else if (pointerPosition == PointerPosition.right)
            Positioned(
              right: -arrowSize,
              top: (_centerY(context, child) ?? 0) - arrowSize,
              child: _Triangle(
                size: arrowSize,
                color: color,
                direction: PointerPosition.right,
              ),
            )
          else if (pointerPosition == PointerPosition.bottomLeft)
            Positioned(
              bottom: -arrowSize,
              left: MediaQuery.of(context).size.width * 0.15,
              child: _Triangle(
                  size: arrowSize,
                  color: color,
                  direction: PointerPosition.bottom),
            )
          else if (pointerPosition == PointerPosition.bottomRight)
            Positioned(
              bottom: -arrowSize,
              right: MediaQuery.of(context).size.width * 0.15,
              child: _Triangle(
                  size: arrowSize,
                  color: color,
                  direction: PointerPosition.bottom),
            )
          else if (pointerPosition == PointerPosition.topLeft)
            Positioned(
              top: -arrowSize,
              left: MediaQuery.of(context).size.width * 0.15,
              child: _Triangle(
                  size: arrowSize,
                  color: color,
                  direction: PointerPosition.top),
            )
          else if (pointerPosition == PointerPosition.topRight)
            Positioned(
              top: -arrowSize,
              right: MediaQuery.of(context).size.width * 0.15,
              child: _Triangle(
                  size: arrowSize,
                  color: color,
                  direction: PointerPosition.top),
            ),
        ],
      ),
    );
  }

  // Helpers — try to estimate center offsets relative to child's RenderBox.
  // These use context.findRenderObject which may be null in some build timings;
  // they fallback to 0 so arrow still shows (tweak positions manually if needed).
  double? _centerX(BuildContext context, Widget childWidget) {
    // Can't reliably compute child's size here synchronously for arbitrary widget.
    // Return null so we don't crash; you can pass explicit offsets if needed.
    return null;
  }

  double? _centerY(BuildContext context, Widget childWidget) {
    return null;
  }
}

/// triangle painter widget
class _Triangle extends StatelessWidget {
  final double size;
  final Color color;
  final PointerPosition direction;

  const _Triangle({
    required this.size,
    required this.color,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    // width/height tuned per direction
    final w =
        direction == PointerPosition.left || direction == PointerPosition.right
            ? size
            : size * 2;
    final h =
        direction == PointerPosition.left || direction == PointerPosition.right
            ? size * 2
            : size;
    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: _TrianglePainter(color: color, direction: direction),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final PointerPosition direction;
  _TrianglePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final Path path = Path();

    switch (direction) {
      case PointerPosition.bottom:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        path.close();
        break;
      case PointerPosition.top:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.close();
        break;
      case PointerPosition.left:
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        path.close();
        break;
      case PointerPosition.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        path.close();
        break;
      default:
        // corners reuse top/bottom drawing
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => false;
}
