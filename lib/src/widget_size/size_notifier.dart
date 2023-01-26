import 'package:dynamic_bottom_sheet/src/on_drag_wrapper.dart';
import 'package:flutter/material.dart';

import '../scroll_controller_override.dart';
import '../snapping_calculator.dart';
import '../snapping_sheet_content.dart';

class SizeNotifier extends StatefulWidget {
  final SheetContent content;
  final int childIndex;
  final ValueChanged<Size> onSizeChange;

  final Axis axis;
  final SheetLocation sheetLocation;
  final Function(double) dragUpdate;
  final VoidCallback dragEnd;
  final double currentPosition;
  final SnappingCalculator snappingCalculator;

  const SizeNotifier({
    Key? key,
    required this.content,
    required this.childIndex,
    required this.onSizeChange,
    required this.snappingCalculator,
    required this.axis,
    required this.dragUpdate,
    required this.dragEnd,
    required this.currentPosition,
    required this.sheetLocation,
  }) : super(key: key);

  @override
  _SizeNotifierState createState() => _SizeNotifierState();
}

class _SizeNotifierState extends State<SizeNotifier> {
  final _widgetKey = GlobalKey();
  Size? _oldSize;

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size!);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: widget.content.pageAt(widget.childIndex).scrollController != null
            ? scrollableChild()
            : draggableChild(),
      ),
    );
  }

  Widget scrollableChild() {
    return ScrollControllerOverride(
      dragEnd: widget.dragEnd,
      dragUpdate: widget.dragUpdate,
      currentPosition: widget.currentPosition,
      snappingCalculator: widget.snappingCalculator,
      scrollController: widget.content.pageAt(widget.childIndex).scrollController!,
      sheetLocation: widget.sheetLocation,
      axis: widget.axis,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 450),
        key: _widgetKey,
        child: widget.content.childAt(widget.childIndex),
      ),
    );
  }

  Widget draggableChild() {
    return OnDragWrapper(
      dragEnd: widget.dragEnd,
      dragUpdate: widget.dragUpdate,
      axis: widget.axis,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 450),
        key: _widgetKey,
        child: widget.content.childAt(widget.childIndex),
      ),
    );
  }
}
