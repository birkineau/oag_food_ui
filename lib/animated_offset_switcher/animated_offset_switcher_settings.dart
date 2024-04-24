part of 'animated_offset_switcher.dart';

class AnimatedOffsetSwitcherSettings {
  const AnimatedOffsetSwitcherSettings({
    required this.manual,
    required this.beginDuration,
    required this.middleDuration,
    required this.endDuration,
    required this.beginCurve,
    this.endCurve,
    required this.beginOffset,
    this.middleOffset = Offset.zero,
    required this.endOffset,
  });

  const AnimatedOffsetSwitcherSettings.topToBottom({
    this.manual = false,
    this.beginDuration = const Duration(milliseconds: 500),
    this.middleDuration = const Duration(milliseconds: 3750),
    this.endDuration = const Duration(milliseconds: 500),
    this.beginCurve = Curves.fastOutSlowIn,
    this.endCurve = Curves.fastOutSlowIn,
    this.beginOffset = const Offset(.0, -32.0),
    this.middleOffset = Offset.zero,
    this.endOffset = const Offset(.0, 32.0),
  });

  final bool manual;

  final Duration beginDuration;
  final Duration middleDuration;
  final Duration endDuration;

  final Curve beginCurve;
  final Curve? endCurve;

  final Offset beginOffset;
  final Offset middleOffset;
  final Offset endOffset;

  AnimatedOffsetSwitcherSettings copyWith({
    bool? manual,
    Duration? beginDuration,
    Duration? middleDuration,
    Duration? endDuration,
    Curve? beginCurve,
    Curve? endCurve,
    Offset? beginOffset,
    Offset? middleOffset,
    Offset? endOffset,
  }) {
    return AnimatedOffsetSwitcherSettings(
      manual: manual ?? this.manual,
      beginDuration: beginDuration ?? this.beginDuration,
      middleDuration: middleDuration ?? this.middleDuration,
      endDuration: endDuration ?? this.endDuration,
      beginCurve: beginCurve ?? this.beginCurve,
      endCurve: endCurve ?? this.endCurve,
      beginOffset: beginOffset ?? this.beginOffset,
      middleOffset: middleOffset ?? this.middleOffset,
      endOffset: endOffset ?? this.endOffset,
    );
  }
}
