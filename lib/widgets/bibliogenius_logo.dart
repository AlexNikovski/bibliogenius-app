import 'package:flutter/material.dart';

class BiblioGeniusLogo extends StatelessWidget {
  final double size;
  final Color color;

  const BiblioGeniusLogo({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Determine relative sizes based on the total height 'size'
    final bookSize = size * 0.8;
    final bulbSize = size * 0.5;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // The Book
        Padding(
          padding: EdgeInsets.only(
            top: size * 0.25,
          ), // Push book down slightly more
          child: Icon(Icons.menu_book_rounded, size: bookSize, color: color),
        ),
        // The Lightbulb
        Positioned(
          top: 0,
          child: Icon(Icons.lightbulb_outlined, size: bulbSize, color: color),
        ),
      ],
    );
  }
}
