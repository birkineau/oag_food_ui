import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oag_food_ui/dishes/food.dart';
import 'package:oag_food_ui/utility/color_extension.dart';

class FoodApplication extends StatefulWidget {
  const FoodApplication({super.key});

  @override
  State<FoodApplication> createState() => _FoodApplicationState();
}

class _FoodApplicationState extends State<FoodApplication> {
  final _foodTileDisplayKey = GlobalKey<FoodTileDisplayState>();
  final _foodBubblesKey = GlobalKey<FoodBubblesState>();

  bool _showBubbles = false;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    const searchBarHeight = 56.0;
    const backgroundColor = Color(0xFF292930);
    const cardColor = Color(0xFF3F3F48);

    final topPadding = viewPadding.top == .0 ? 12.0 : viewPadding.top;
    final bottomPadding = viewPadding.bottom == .0 ? 12.0 : viewPadding.bottom;
    const foodMenuHeight = 64.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor.darken(66),
                backgroundColor.lighten(5),
              ],
              stops: const [.0, 1.0],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Top padding.
            SizedBox(height: topPadding),

            /// Search bar & filter button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Search bar.
                  const Expanded(
                    child: SearchBar(
                      elevation: MaterialStatePropertyAll(.0),
                      backgroundColor: MaterialStatePropertyAll(cardColor),
                      surfaceTintColor: MaterialStatePropertyAll(
                        Colors.transparent,
                      ),
                      textStyle: MaterialStatePropertyAll(
                        TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  /// Filter button.
                  Container(
                    width: searchBarHeight,
                    height: searchBarHeight,
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),

            /// Food picks & bubble buttons.
            Row(
              children: [
                FoodPicksButton(onPressed: _animateFoodTilesInAndOutWithDelay),
                FoodBubblesButton(onPressed: _showFoodBubbles),
              ],
            ),

            /// Food tile display.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final Widget child;

                  if (_showBubbles) {
                    child = Padding(
                      key: const ValueKey("food_bubbles"),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 12.0,
                      ),
                      child: FoodBubbles(
                        key: _foodBubblesKey,
                        spacing: 8.0,
                      ),
                    );
                  } else {
                    child = SingleChildScrollView(
                      key: const ValueKey("food_tiles"),
                      child: FoodTileDisplay(
                        key: _foodTileDisplayKey,
                        availableHeight: constraints.maxHeight,
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: child,
                  );
                },
              ),
            ),

            /// Bottom menu.
            const Center(child: FoodMenu(height: foodMenuHeight)),

            /// Bottom padding.
            SizedBox(height: bottomPadding),
          ],
        ),
      ],
    );
  }

  void _animateFoodTilesInAndOutWithDelay() {
    HapticFeedback.selectionClick();
    _foodTileDisplayKey.currentState?.animateTilesInAndOutWithDelay();

    if (!_showBubbles) {
      return;
    }

    setState(() {
      _showBubbles = false;
    });
  }

  void _showFoodBubbles() {
    if (_showBubbles) {
      HapticFeedback.selectionClick();
      _foodBubblesKey.currentState?.generateBubbles();
      return;
    }

    setState(() {
      _showBubbles = true;
    });
  }
}
