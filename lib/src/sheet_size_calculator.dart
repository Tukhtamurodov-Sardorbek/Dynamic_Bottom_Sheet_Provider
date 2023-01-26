import 'package:flutter/widgets.dart';
import 'package:dynamic_bottom_sheet/src/sheet_size_behaviors.dart';
import 'package:dynamic_bottom_sheet/src/snapping_sheet_content.dart';

abstract class SheetSizeCalculator {
  final SheetContent? content;
  final double maxHeight;

  SheetSizeCalculator(
    this.content,
    this.maxHeight,
  );

  double? getSheetStartPosition() {
    var sizeBehavior = content!.sizeBehavior;
    if (sizeBehavior is SheetSizeFill) return 0;
    if (sizeBehavior is SheetSizeStatic) {
      if (!sizeBehavior.expandOnOverflow) return null;
      if (getVisibleHeight() > sizeBehavior.size) {
        return 0;
      }
    }
    return null;
  }

  double getVisibleHeight();
  double getSheetEndPosition();
  Positioned positionWidget({required Widget child});
}
