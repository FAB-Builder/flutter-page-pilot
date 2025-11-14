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
class TooltipWithFlushArrow extends StatefulWidget {
  final Widget child;
  final PointerPosition pointerPosition;
  final double arrowSize;
  final Color color;
  final double borderRadius;
  final double height;
  final double width;
  final GlobalKey targetKey;
  final bool showArrow;

  const TooltipWithFlushArrow({
    super.key,
    required this.child,
    this.pointerPosition = PointerPosition.bottom,
    this.arrowSize = 10.0,
    this.color = Colors.black87,
    this.borderRadius = 8.0,
    required this.height,
    required this.width,
    required this.targetKey,
    this.showArrow = false,
  });

  @override
  State<TooltipWithFlushArrow> createState() => _TooltipWithFlushArrowState();
}

class _TooltipWithFlushArrowState extends State<TooltipWithFlushArrow> {
  Offset? position;

  Size? size;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getPosition());
  }

  void getPosition() {
    final box =
        widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      setState(() {
        position = box.localToGlobal(Offset.zero);
        size = box.size;
      });
    }
  }

  double _calculateArrowLeft({
    required double containerWidth,
    required double arrowSize,
    required double targetDx,
    required double childWidth,
  }) {
    // Convert global target X to local inside child
    double arrowLeft = targetDx - (arrowSize / 2);

    // Clamp inside the child
    arrowLeft = arrowLeft.clamp(0, containerWidth - arrowSize);

    return arrowLeft;
  }

  @override
  Widget build(BuildContext context) {
    // Stack so arrow can overflow without changing child's layout
    getPosition();
    print("pointerPosition: ${position}");
    print("size: ${size}");
    print(MediaQuery.of(context).size);
    return Container(
      height: widget.height,
      width: widget.width,
      color: widget.color,
      child: Stack(
        clipBehavior: Clip.none,
        // alignment: Alignment.center,
        children: [
          widget.child,

          // Pointer overlay
          if (position != null && size != null && widget.showArrow)
            Positioned(
              bottom: widget.pointerPosition == PointerPosition.top
                  ? null
                  : -widget.arrowSize / 1.75,
              top: widget.pointerPosition == PointerPosition.bottom
                  ? null
                  : -widget.arrowSize / 1.75,
              left: _calculateArrowLeft(
                containerWidth: widget.width,
                arrowSize: widget.arrowSize,
                targetDx: position!.dx,
                childWidth: size!.width,
              ),
              child: Transform.rotate(
                angle: widget.pointerPosition == PointerPosition.left
                    ? 3.14
                    : widget.pointerPosition == PointerPosition.right
                        ? 0
                        : widget.pointerPosition == PointerPosition.topLeft
                            ? 3.14 / 2
                            : widget.pointerPosition == PointerPosition.topRight
                                ? -3.14 / 2
                                : widget.pointerPosition ==
                                        PointerPosition.bottomLeft
                                    ? 3.14 / 2
                                    : widget.pointerPosition ==
                                            PointerPosition.bottomRight
                                        ? -3.14 / 2
                                        : widget.pointerPosition ==
                                                PointerPosition.top
                                            ? 3.14
                                            : 0,
                child: Icon(Icons.arrow_drop_down,
                    size: widget.arrowSize, color: widget.color),
              ),
            ),

          // // Arrow - positioned depending on pointerPosition using negative offsets
          // if (widget.pointerPosition == PointerPosition.bottom &&
          //     widget.showArrow)
          //   Positioned(
          //     // left: null,
          //     right: null,
          //     bottom: -widget.arrowSize, // negative to overlap flush
          //     left: MediaQuery.of(context).size.width * 0.5 - widget.arrowSize,
          //     child: _Triangle(
          //       size: widget.arrowSize,
          //       color: widget.color,
          //       direction: PointerPosition.bottom,
          //     ),
          //   )
          // else if (widget.pointerPosition == PointerPosition.top &&
          //     widget.showArrow)
          //   Positioned(
          //     top: -widget.arrowSize,
          //     left: MediaQuery.of(context).size.width * 0.5 - widget.arrowSize,
          //     child: _Triangle(
          //       size: widget.arrowSize,
          //       color: widget.color,
          //       direction: PointerPosition.top,
          //     ),
          //   )
          // else if (widget.pointerPosition == PointerPosition.left &&
          //     widget.showArrow)
          //   Positioned(
          //     left: -widget.arrowSize,
          //     top: (_centerY(context, widget.child) ?? 0) - widget.arrowSize,
          //     child: _Triangle(
          //       size: widget.arrowSize,
          //       color: widget.color,
          //       direction: PointerPosition.left,
          //     ),
          //   )
          // else if (widget.pointerPosition == PointerPosition.right &&
          //     widget.showArrow)
          //   Positioned(
          //     right: -widget.arrowSize,
          //     top: (_centerY(context, widget.child) ?? 0) - widget.arrowSize,
          //     child: _Triangle(
          //       size: widget.arrowSize,
          //       color: widget.color,
          //       direction: PointerPosition.right,
          //     ),
          //   )
          // else if (widget.pointerPosition == PointerPosition.bottomLeft &&
          //     widget.showArrow)
          //   Positioned(
          //     bottom: -widget.arrowSize,
          //     left: MediaQuery.of(context).size.width * 0.15,
          //     child: _Triangle(
          //         size: widget.arrowSize,
          //         color: widget.color,
          //         direction: PointerPosition.bottom),
          //   )
          // else if (widget.pointerPosition == PointerPosition.bottomRight &&
          //     widget.showArrow)
          //   Positioned(
          //     bottom: -widget.arrowSize,
          //     right: MediaQuery.of(context).size.width * 0.15,
          //     child: _Triangle(
          //         size: widget.arrowSize,
          //         color: widget.color,
          //         direction: PointerPosition.bottom),
          //   )
          // else if (widget.pointerPosition == PointerPosition.topLeft &&
          //     widget.showArrow)
          //   Positioned(
          //     top: -widget.arrowSize,
          //     left: MediaQuery.of(context).size.width * 0.15,
          //     child: _Triangle(
          //         size: widget.arrowSize,
          //         color: widget.color,
          //         direction: PointerPosition.top),
          //   )
          // else if (widget.pointerPosition == PointerPosition.topRight &&
          //     widget.showArrow)
          //   Positioned(
          //     top: -widget.arrowSize,
          //     right: MediaQuery.of(context).size.width * 0.15,
          //     child: _Triangle(
          //         size: widget.arrowSize,
          //         color: widget.color,
          //         direction: PointerPosition.top),
          //   ),
        ],
      ),
    );
  }

  // Helpers — try to estimate center offsets relative to child's RenderBox.
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
