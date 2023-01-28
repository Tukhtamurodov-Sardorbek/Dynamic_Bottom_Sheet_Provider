import 'package:flutter/material.dart';

class DragWrapper extends StatelessWidget {
  final Widget child;
  final Function(double) dragUpdate;
  final VoidCallback dragEnd;
  final Axis axis;

  const DragWrapper({
    Key? key,
    required this.dragEnd,
    required this.child,
    required this.axis,
    required this.dragUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.horizontal) {
      return GestureDetector(
        onHorizontalDragEnd: (_) {
          dragEnd();
        },
        onHorizontalDragUpdate: (dragData) {
          dragUpdate(-dragData.delta.dx);
        },
        child: child,
      );
    }
    return GestureDetector(
      onVerticalDragEnd: (_) {
        dragEnd();
      },
      onVerticalDragUpdate: (dragData) {
        dragUpdate(dragData.delta.dy);
      },
      child: child,
    );
  }
}
