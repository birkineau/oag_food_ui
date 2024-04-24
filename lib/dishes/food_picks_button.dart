import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../scale_button/scale_button.dart';

class FoodPicksButton extends StatelessWidget {
  const FoodPicksButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const highlightColor = Color(0xFFFFFD57);
    const buttonOffset = Offset(.0, .0);

    final foodPicksButtonContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: highlightColor,
        borderRadius: BorderRadius.all(Radius.circular(48.0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.solidHandPointRight,
            color: Colors.black,
            size: 24.0,
          ),
          SizedBox(width: 8.0),
          Text(
            "chow picks",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );

    return ScaleButton(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      onPressed: onPressed,
      child: Transform.translate(
        offset: buttonOffset,
        child: foodPicksButtonContent,
      ),
    );
  }
}
