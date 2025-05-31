import 'package:flutter/material.dart';

class PagePilotPiP extends StatefulWidget {
  final Widget mainContent;
  final Widget pipContent;
  final double pipWidth;
  final double pipHeight;
  final Alignment initialAlignment;
  final bool showPiP;
  final VoidCallback? onClose;
  final VoidCallback? onExpand;

  const PagePilotPiP({
    super.key,
    required this.mainContent,
    required this.pipContent,
    this.pipWidth = 160,
    this.pipHeight = 90,
    this.initialAlignment = Alignment.bottomRight,
    this.showPiP = false,
    this.onClose,
    this.onExpand,
  });

  @override
  State<PagePilotPiP> createState() => _PagePilotPiPState();
}

class _PagePilotPiPState extends State<PagePilotPiP> {
  Offset _position = Offset(0, 0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _position = Offset(
        screenSize.width - widget.pipWidth - 16,
        screenSize.height - widget.pipHeight - 16,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.mainContent,
        if (widget.showPiP)
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _position += details.delta;
                });
              },
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: widget.pipWidth,
                  height: widget.pipHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: widget.pipContent),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: widget.onExpand ?? () => print("Expand tapped"),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: widget.onClose ?? () => print("Close tapped"),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
