import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const ChatBubble({
    super.key,
    this.text="",
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;   

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      constraints: BoxConstraints(
        maxWidth: maxBubbleWidth,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: AnimatedTextKit(
        totalRepeatCount: 1,
        isRepeatingAnimation: false,
        animatedTexts: [
          TypewriterAnimatedText(
            widget.text,
            textStyle: TextStyle(
              color: widget.textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
      ),
    );
  }
}
