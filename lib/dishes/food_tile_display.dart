import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'food.dart';

class FoodTileDisplay extends StatefulWidget {
  const FoodTileDisplay({
    super.key,
    required this.availableHeight,
  });

  final double availableHeight;

  @override
  State<FoodTileDisplay> createState() => FoodTileDisplayState();
}

class FoodTileDisplayState extends State<FoodTileDisplay> {
  late final List<GlobalKey<FoodTileState>> _dishTileKeys;

  Future<void> animateTilesInAndOutWithDelay([int delayMs = 100]) async {
    for (var i = 0; i < _dishTileKeys.length; ++i) {
      final dishTileKey = _dishTileKeys[i];
      await Future.delayed(Duration(milliseconds: i * delayMs));
      _animateDishInAndOut(dishTileKey);
    }
  }

  int _tilesThatFit = 0;

  @override
  void initState() {
    super.initState();

    /// Determine how many tiles fit in the available space.
    ///
    /// At least one tile must fit.
    _tilesThatFit = (widget.availableHeight / FoodTile.height).floor();

    assert(
      _tilesThatFit >= 1,
      "At least one tile must fit; otherwise the layout is broken since no "
      "products are shown.",
    );

    _dishTileKeys = [
      for (var i = 0; i < _tilesThatFit; ++i) GlobalKey<FoodTileState>(),
    ];

    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        _showTilesWithDelay();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_tilesThatFit >= 1)
          FoodTile(
            key: _dishTileKeys[0],
            asset: "assets/images/chicken_caesar_salad.png",
            name: "chicken caesar salad",
            tags: const [
              FoodTag.chicken,
              FoodTag.lettuce,
              FoodTag.cheese,
              FoodTag.bread,
              FoodTag.mayonnaise,
            ],
          ),
        if (_tilesThatFit >= 2)
          FoodTile(
            key: _dishTileKeys[1],
            placement: FoodTilePlacement.left,
            asset: "assets/images/beef_stew.jpg",
            name: "classic beef stew",
            tags: const [
              FoodTag.meat,
              FoodTag.potato,
              FoodTag.carrot,
            ],
          ),
        if (_tilesThatFit >= 3)
          FoodTile(
            key: _dishTileKeys[2],
            asset: "assets/images/italian_pasta.jpg",
            name: "italian pasta salad",
            tags: const [
              FoodTag.salami,
              FoodTag.pasta,
              FoodTag.cheese,
              FoodTag.mushroom,
              FoodTag.tomato,
              FoodTag.olive,
            ],
          ),
      ],
    );
  }

  Future<void> _showTilesWithDelay([int delayMs = 100]) async {
    for (var i = 0; i < _dishTileKeys.length; ++i) {
      final dishTileKey = _dishTileKeys[i];
      await Future.delayed(Duration(milliseconds: i * delayMs));
      final state = dishTileKey.currentState?.offsetSwitcherState;

      if (state == null || state.showing) {
        continue;
      }

      state.show();
    }
  }

  Future<void> _animateDishInAndOut(GlobalKey<FoodTileState> offsetKey) async {
    final offsetState = offsetKey.currentState?.offsetSwitcherState;

    if (offsetState == null) {
      return;
    }

    await offsetState.hide();
    return offsetState.show();
  }
}
