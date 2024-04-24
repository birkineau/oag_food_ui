import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oag_food_ui/utility/color_extension.dart';

class FoodMenu extends StatefulWidget {
  const FoodMenu({
    super.key,
    required this.height,
  });

  final double height;

  @override
  State<FoodMenu> createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  DishMenuType _selectedType = DishMenuType.home;

  @override
  Widget build(BuildContext context) {
    const widthSpacer = SizedBox(width: 5.0);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F48),
        borderRadius: BorderRadius.all(Radius.circular(widget.height / 2.0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FoodMenuToggleButton(
            selected: _selectedType == DishMenuType.home,
            onPressed: () {
              _select(DishMenuType.home);
            },
            icon: FontAwesomeIcons.plateWheat,
            size: 21.0,
          ),
          widthSpacer,
          FoodMenuToggleButton(
            selected: _selectedType == DishMenuType.cart,
            onPressed: () {
              _select(DishMenuType.cart);
            },
            icon: FontAwesomeIcons.cartShopping,
          ),
          widthSpacer,
          FoodMenuToggleButton(
            selected: _selectedType == DishMenuType.profile,
            onPressed: () {
              _select(DishMenuType.profile);
            },
            icon: FontAwesomeIcons.userLarge,
          ),
        ],
      ),
    );
  }

  void _select(DishMenuType type) {
    setState(
      () {
        _selectedType = type;
      },
    );

    HapticFeedback.selectionClick();
  }
}

class FoodMenuToggleButton extends StatefulWidget {
  const FoodMenuToggleButton({
    super.key,
    this.onPressed,
    required this.selected,
    required this.icon,
    this.size = 20.0,
  });

  final VoidCallback? onPressed;
  final bool selected;
  final IconData icon;
  final double size;

  @override
  State<FoodMenuToggleButton> createState() => _FoodMenuToggleButtonState();
}

class _FoodMenuToggleButtonState extends State<FoodMenuToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _buttonColorAnimation;
  late final Animation<Color?> _iconColorAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    const highlightColor = Color(0xFFFFFD57);

    _buttonColorAnimation = ColorTween(
      begin: const Color(0xFF3F3F48).lighten(10),
      end: highlightColor,
    ).animate(_animationController);

    _iconColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_animationController);

    _scaleAnimation = Tween(begin: 1.0, end: .925).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    if (widget.selected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FoodMenuToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selected) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttonSize = 56.0;

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                color: _buttonColorAnimation.value,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                widget.icon,
                color: _iconColorAnimation.value,
                size: widget.size,
              ),
            ),
          );
        },
      ),
    );
  }
}

enum DishMenuType {
  home,
  cart,
  profile,
}
