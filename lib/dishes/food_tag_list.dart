import 'package:flutter/material.dart';

import 'food_tag.dart';

class FoodTagList extends StatelessWidget {
  const FoodTagList({
    super.key,
    required this.reverse,
    required this.tags,
  });

  final bool reverse;
  final List<FoodTag> tags;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      reverse: reverse,
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];

        return Tooltip(
          message: tag.name,
          preferBelow: true,
          triggerMode: TooltipTriggerMode.tap,
          child: Image(
            image: tag.icon,
            fit: BoxFit.scaleDown,
            width: 24.0,
            height: 24.0,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(width: 8.0);
      },
    );
  }
}
