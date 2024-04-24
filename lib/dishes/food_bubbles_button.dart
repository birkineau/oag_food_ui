import 'package:flutter/material.dart';

import '../scale_button/scale_button.dart';

class FoodBubblesButton extends StatelessWidget {
  const FoodBubblesButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFFFFFD57);
    const buttonOffset = Offset(.0, .0);

    return ScaleButton(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      onPressed: onPressed,
      child: Transform.translate(
        offset: buttonOffset,
        child: Container(
          width: 56.0,
          height: 56.0,
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: highlightColor,
            shape: BoxShape.circle,
          ),
          child: const Image(
            image: AssetImage("assets/images/icon/bubble_solid.png"),
          ),
        ),
      ),
    );
  }
}
