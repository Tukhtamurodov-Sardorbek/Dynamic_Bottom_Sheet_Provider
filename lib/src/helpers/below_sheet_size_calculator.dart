import 'package:flutter/widgets.dart';
import 'package:dynamic_bottom_sheet/src/helpers/sheet_size_calculator.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_sheet_content.dart';

class BelowSheetSizeCalculator extends SheetSizeCalculator {
  final SheetContent? content;
  final double currentPosition;
  final double maxHeight;
  final double grabbingHeight;
  final Axis axis;

  BelowSheetSizeCalculator({
    required this.content,
    required this.currentPosition,
    required this.maxHeight,
    required this.axis,
    required this.grabbingHeight,
  }) : super(content, maxHeight);

  @override
  double getSheetEndPosition() {
    return maxHeight - currentPosition + grabbingHeight / 2;
  }

  @override
  double getVisibleHeight() {
    return maxHeight - getSheetEndPosition();
  }

  @override
  Positioned positionWidget({required Widget child}) {
    if (axis == Axis.horizontal) {
      return Positioned(
        top: 0,
        bottom: 0,
        right: getSheetEndPosition(),
        left: getSheetStartPosition(),
        child: child,
      );
    }
    return Positioned(
      left: 0,
      right: 0,
      top: getSheetEndPosition(),
      bottom: getSheetStartPosition(),
      child: child,
    );
  }
}
