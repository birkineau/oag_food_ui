import 'package:flutter/material.dart';

import '../animated_offset_switcher/animated_offset_switcher.dart';
import 'food.dart';

class FoodTile extends StatefulWidget {
  static const height = 192.0;

  const FoodTile({
    super.key,
    this.placement = FoodTilePlacement.right,
    required this.asset,
    required this.name,
    required this.tags,
  });

  final FoodTilePlacement placement;
  final String asset;
  final String name;
  final List<FoodTag> tags;

  @override
  State<FoodTile> createState() => FoodTileState();
}

class FoodTileState extends State<FoodTile> {
  final _offsetKey = GlobalKey<AnimatedOffsetSwitcherState>();

  AnimatedOffsetSwitcherState get offsetSwitcherState {
    final offsetState = _offsetKey.currentState;

    if (offsetState == null) {
      throw Exception(
        "OffsetSwitcherState is null; make sure the $FoodTile is mounted.",
      );
    }

    return offsetState;
  }

  @override
  Widget build(BuildContext context) {
    final isLeftPlacement = widget.placement == FoodTilePlacement.left;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final offset = Offset(isLeftPlacement ? -width : width, .0);
        const duration = Duration(milliseconds: 650);

        return AnimatedOffsetSwitcher(
          key: _offsetKey,
          settings: AnimatedOffsetSwitcherSettings(
            manual: true,
            beginOffset: offset,
            endOffset: offset,
            beginDuration: duration,
            middleDuration: Duration.zero,
            endDuration: duration,
            beginCurve: Curves.easeOutQuart,
            endCurve: Curves.fastOutSlowIn,
          ),
          itemCount: 1,
          itemBuilder: (context, index) {
            return _itemBuilder(context, index, width, isLeftPlacement);
          },
        );
      },
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    double width,
    bool isLeftPlacement,
  ) {
    const radius = Radius.circular(28.0);
    const cardColor = Color(0xFF3F3F48);
    const white80 = Color(0xCCFFFFFF);

    const imageOffset = 32.0;
    final imageWidth = width * .475;
    final informationPadding = imageWidth - imageOffset + 8.0;

    final image = Positioned(
      top: .0,
      bottom: .0,
      left: isLeftPlacement ? .0 : null,
      right: isLeftPlacement ? null : .0,
      width: imageWidth,
      child: Transform.translate(
        offset: Offset(isLeftPlacement ? -imageOffset : imageOffset, .0),
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(widget.asset),
          ),
        ),
      ),
    );

    final information = Positioned(
      top: 20.0,
      bottom: 20.0,
      left: isLeftPlacement ? .0 : null,
      right: isLeftPlacement ? null : .0,
      width: width,
      child: Container(
        padding: EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
          left: isLeftPlacement ? informationPadding : 16.0,
          right: isLeftPlacement ? 16.0 : informationPadding,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: isLeftPlacement ? Radius.zero : radius,
            bottomLeft: isLeftPlacement ? Radius.zero : radius,
            topRight: isLeftPlacement ? radius : Radius.zero,
            bottomRight: isLeftPlacement ? radius : Radius.zero,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: isLeftPlacement
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            /// Dish name.
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20.5,
              ),
            ),

            /// Preperation time.
            const _IconLabelRow(
              icon: Icon(Icons.timer_outlined, color: white80, size: 20.0),
              label: "15 minutes",
            ),

            /// Ingredient count.
            _IconLabelRow(
              icon: const SizedBox(
                width: 20.0,
                child: Image(
                  image: AssetImage("assets/images/icon/ingredient.png"),
                  width: 16.5,
                  height: 16.5,
                  color: white80,
                ),
              ),
              label: "${widget.tags.length} ingredients",
            ),

            /// Tags.
            SizedBox(
              height: 40.0,
              child: FoodTagList(
                reverse: isLeftPlacement,
                tags: widget.tags,
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      key: ValueKey("item_$index"),
      width: width,
      height: FoodTile.height,
      child: Stack(
        children: [
          information,
          image,
        ],
      ),
    );
  }
}

class _IconLabelRow extends StatelessWidget {
  const _IconLabelRow({
    required this.icon,
    required this.label,
  });

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const white80 = Color(0xCCFFFFFF);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6.0),
        Text(
          label,
          style: const TextStyle(
            color: white80,
            fontWeight: FontWeight.w500,
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }
}

enum FoodTilePlacement {
  left,
  right,
}
