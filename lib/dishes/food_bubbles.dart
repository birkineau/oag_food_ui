import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:oag_food_ui/utility/utility.dart';

import 'ui_design/cpaint.dart';
import 'ui_design/cpaint_child.dart';

class FoodBubbles extends StatefulWidget {
  const FoodBubbles({
    super.key,
    this.spacing = 8.0,
  });

  final double spacing;

  @override
  State<FoodBubbles> createState() => FoodBubblesState();
}

class FoodBubblesState extends State<FoodBubbles>
    with SingleTickerProviderStateMixin {
  final _cpaintKey = GlobalKey();
  CData _cdata = CData.zero;

  void generateBubbles() {
    setState(
      () {
        _cdata = generateCircles(context.size!, widget.spacing)
          ..circles.sort(_byCenterDy);
      },
    );

    final cpaint = _cpaintKey.currentContext?.findRenderObject();

    if (cpaint == null) {
      throw StateError("Unable to find $RenderCPaint.");
    }

    (cpaint as RenderCPaint).animate();
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) => generateBubbles(),
    );
  }

  @override
  void dispose() {
    _cpaintKey.currentContext?.findRenderObject()?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CPaint(
      key: _cpaintKey,
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.fastOutSlowIn,
      children: [
        for (var i = 0; i < _cdata.circles.length; ++i)
          CPaintChild(
            circle: _cdata.circles[i],
            child: const _CircleChild(),
          ),
      ],
    );
  }

  int _byCenterDy(Circle a, Circle b) => a.center.dy.compareTo(b.center.dy);
}

class _CircleChild extends StatelessWidget {
  const _CircleChild();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 246),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(3.5),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(100.0)),
          child: Image(
            image: AssetImage("assets/images/beef_stew.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
