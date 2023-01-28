// import 'package:flutter/material.dart';
// import 'package:dynamic_bottom_sheet/src/on_drag_wrapper.dart';
// import 'package:dynamic_bottom_sheet/src/scroll_controller_override.dart';
// import 'package:dynamic_bottom_sheet/src/sheet_size_calculator.dart';
// import 'package:dynamic_bottom_sheet/src/snapping_calculator.dart';
// import 'package:dynamic_bottom_sheet/src/snapping_sheet_content.dart';
//
// class SheetContentWrapper extends StatefulWidget {
//   final SheetSizeCalculator sizeCalculator;
//   final SheetContent? sheetData;
//   final double previousSize;
//   final double currentSize;
//   final Function(int) onPageChanged;
//
//   final Function(double) dragUpdate;
//   final VoidCallback dragEnd;
//   final double currentPosition;
//   final SnappingCalculator snappingCalculator;
//   final Axis axis;
//
//   const SheetContentWrapper({
//     Key? key,
//     required this.sheetData,
//     required this.sizeCalculator,
//     required this.currentPosition,
//     required this.snappingCalculator,
//     required this.dragUpdate,
//     required this.dragEnd,
//     required this.axis, required this.previousSize, required this.currentSize, required this.onPageChanged,
//   }) : super(key: key);
//
//   @override
//   _SheetContentWrapperState createState() => _SheetContentWrapperState();
// }
//
// class _SheetContentWrapperState extends State<SheetContentWrapper> {
//   Widget _wrapWithDragWrapper(Widget child) {
//     return OnDragWrapper(
//       axis: widget.axis,
//       dragEnd: widget.dragEnd,
//       dragUpdate: widget.dragUpdate,
//       child: child,
//     );
//   }
//
//   Widget _wrapWithScrollControllerOverride(Widget child) {
//     return ScrollControllerOverride(
//       axis: widget.axis,
//       scrollController: widget.sheetData!.scrollController!,
//       dragUpdate: widget.dragUpdate,
//       dragEnd: widget.dragEnd,
//       currentPosition: widget.currentPosition,
//       snappingCalculator: widget.snappingCalculator,
//       sheetLocation: widget.sheetData!.location,
//       child: child,
//     );
//   }
//
//   Widget _wrapWithNecessaryWidgets(Widget child) {
//     Widget wrappedChild = child;
//     if (widget.sheetData!.draggable) {
//       if (widget.sheetData!.scrollController != null) {
//         wrappedChild = _wrapWithScrollControllerOverride(wrappedChild);
//       } else {
//         wrappedChild = _wrapWithDragWrapper(wrappedChild);
//       }
//     }
//     return wrappedChild;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('CURRENT POSITION: ${widget.currentPosition}');
//     if (widget.sheetData == null) return const SizedBox();
//     return widget.sizeCalculator.positionWidget(
//       // child: _wrapWithNecessaryWidgets(widget.sheetData!.child),
//       child: ColoredBox(
//         color: Colors.white,
//         child: TweenAnimationBuilder<double>(
//           curve:  Curves.easeInOutCubic,
//           duration: const Duration(milliseconds: 200),
//           tween: Tween<double>(begin: widget.previousSize, end: widget.currentSize),
//           builder: (context, value, child) {
//             return SizedBox(
//               height: value,
//               child: child,
//             );
//           },
//           child: PageView(
//             onPageChanged: (index) {
//               print('Previous ${widget.previousSize} -> ${widget.currentSize} Current');
//               print('Page Changed to => $index');
//               widget.onPageChanged;
//               print('Previous ${widget.previousSize} -> ${widget.currentSize} Current');
//             },
//             padEnds: false,
//             children: widget.sheetData!.children.map((e) => _wrapWithNecessaryWidgets(e)).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
