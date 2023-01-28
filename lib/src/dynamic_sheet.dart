import 'package:dynamic_bottom_sheet/src/data/provider.dart';
import 'package:dynamic_bottom_sheet/src/data/singleton.dart';
import 'package:dynamic_bottom_sheet/src/widget_size/size_notifier.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_bottom_sheet/src/helpers/on_drag_wrapper.dart';
import 'package:dynamic_bottom_sheet/src/helpers/sheet_position_data.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_position.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_sheet_content.dart';
import 'package:provider/provider.dart';

import 'header.dart';

class DynamicSheet extends StatefulWidget {

  DynamicSheet({
    super.key,
    required double sheetFactor,
    required SheetContent content,
    required Widget scaffoldBody,
    required PageController pageController,
    bool lockOverflowDrag = true,
    double horizontalPadding = 16,
    SnappingPosition? initialPosition,
    SnappingSheetController? sheetController,
    Function(SheetPositionData positionData)? onSheetMoved,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapCompleted,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapStart,
  }){
    assert(sheetFactor >= 0 && sheetFactor <= 1, 'Sheet factor must be between 0 and 1');
    SheetData.createInstance(
      sheetFactor: sheetFactor,
      horizontalPadding: horizontalPadding,
      axis: Axis.vertical,
      content: content,
      scaffoldBody: scaffoldBody,
      lockOverflowDrag: lockOverflowDrag,
      pageController: pageController,
      initialPosition: initialPosition,
      sheetController: sheetController,
      onSheetMoved: onSheetMoved,
      onSnapCompleted: onSnapCompleted,
      onSnapStart: onSnapStart,
    );
  }

  DynamicSheet.horizontal({
    super.key,
    required double sheetFactor,
    required SheetContent content,
    required Widget scaffoldBody,
    required PageController pageController,
    bool lockOverflowDrag = true,
    double horizontalPadding = 16,
    SnappingPosition? initialPosition,
    SnappingSheetController? sheetController,
    Function(SheetPositionData positionData)? onSheetMoved,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapCompleted,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapStart,
  }){
    assert(sheetFactor >= 0 && sheetFactor <= 1, 'Sheet factor must be between 0 and 1');
    SheetData.createInstance(
      sheetFactor: sheetFactor,
      horizontalPadding: horizontalPadding,
      axis: Axis.horizontal,
      content: content,
      scaffoldBody: scaffoldBody,
      lockOverflowDrag: lockOverflowDrag,
      pageController: pageController,
      initialPosition: initialPosition,
      sheetController: sheetController,
      onSheetMoved: onSheetMoved,
      onSnapCompleted: onSnapCompleted,
      onSnapStart: onSnapStart,
    );
  }

  @override
  _DynamicSheetState createState() => _DynamicSheetState();
}

class _DynamicSheetState extends State<DynamicSheet> with TickerProviderStateMixin {
  final data = SheetData.instance;
  late AnimationController _animationController;
  Animation<double>? _snappingAnimation;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: SheetData.instance.content.childCount, vsync: this);
    final headerHeight = context.read<SheetProvider>();
    final childrenHeights = context.read<SheetProvider>().getChildrenSizesBeforeBuild();
    print('HEIGHT: $childrenHeights');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SheetProvider>().updateChildrenSizes(childrenHeights);
    });

    context.read<SheetProvider>().setSheetLocationData();

    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      if (_snappingAnimation == null) return;
      context.read<SheetProvider>().currentPosition = _snappingAnimation!.value;
      // setState(() {});
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        SheetData.instance.onSnapCompleted?.call(
          context.read<SheetProvider>().createPositionData,
          context.read<SheetProvider>().lastSnappingPosition,
        );
      }
    });

    Future.delayed(const Duration(seconds: 0)).then((value) {
      final screenSize = context.read<SheetProvider>().screenSize;
      final grabbingHeight = context.read<SheetProvider>().grabbingHeight;
      final position = SheetData.instance.initialPosition ?? const SnappingPosition.pixels(positionPixels: 0.0);
      context.read<SheetProvider>().currentPosition = position.getPositionInPixels(
        screenSize,
        grabbingHeight,
      );
    });

    if (SheetData.instance.sheetController != null) {
      SheetData.instance.sheetController!._attachState(this);
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DynamicSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    Provider.of<SheetProvider>(context).setSheetLocationData();
  }


  void _setSheetPositionPixel(double positionPixel) {
    _animationController.stop();
    context.read<SheetProvider>().currentPosition = positionPixel;
  }

  void _setSheetPositionFactor(double factor) {
    _animationController.stop();
    final screenSize = context.read<SheetProvider>().screenSize;
    context.read<SheetProvider>().currentPosition = factor * screenSize;
  }

  void _dragSheet(double dragAmount) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    context.read<SheetProvider>().updateCurrentPosition(dragAmount);
  }

  void _dragEnd() {
    final position = context.read<SheetProvider>().snappingCalculator.getBestSnappingPosition();
    _snapToPosition(position);
  }

  TickerFuture _snapToPosition(SnappingPosition snappingPosition) {
    final position = context.read<SheetProvider>().createPositionData;
    data.onSnapStart?.call(position, snappingPosition);
    context.read<SheetProvider>().lastSnappingPosition = snappingPosition;
    return _animateToPosition(snappingPosition);
  }

  TickerFuture _animateToPosition(SnappingPosition snappingPosition) {
    final screenSize = context.read<SheetProvider>().screenSize;
    final grabbingHeight = context.read<SheetProvider>().grabbingHeight;
    final currentPosition = context.read<SheetProvider>().currentPosition;

    _animationController.duration = snappingPosition.snappingDuration;
    var endPosition = snappingPosition.getPositionInPixels(
      screenSize,
      grabbingHeight,
    );
    _snappingAnimation = Tween(begin: currentPosition, end: endPosition).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: snappingPosition.snappingCurve,
      ),
    );
    _animationController.reset();
    return _animationController.forward();
  }


  @override
  Widget build(BuildContext context) {
    print('SHEET IS REBUILT');
    return LayoutBuilder(
      builder: (context, constraints) {
        context.read<SheetProvider>().constraints = constraints;
        return Stack(
          children: [
            Positioned.fill(child: data.scaffoldBody),

            header(),

            Positioned(
              left: 0,
              right: data.axis == Axis.horizontal ? context.read<SheetProvider>().screenSize - context.read<SheetProvider>().currentPosition : 0,
              bottom: 0,
              top: data.axis == Axis.horizontal ? 0 : context.read<SheetProvider>().screenSize - context.read<SheetProvider>().currentPosition,
              child: ColoredBox(
                color: Colors.white,
                child: TweenAnimationBuilder<double>(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 200),
                  tween: Tween<double>(begin: context.read<SheetProvider>().previousPageSize, end: context.watch<SheetProvider>().currentPageSize),
                  builder: (context, value, child) {
                    return SizedBox(
                      height: value,
                      child: child,
                    );
                  },
                  child: PageView(
                    controller: data.pageController,
                    onPageChanged: (index) {
                      tabController.animateTo(index);
                      context.read<SheetProvider>().onPageChanged(index);
                      _snapToPosition(Provider.of<SheetProvider>(context, listen: false).maxSnappingPosition);
                    },
                    padEnds: false,
                    children: _getWrappedChildren(),
                    // children: widget.sheetBelow.children.map((e) => _wrapWithNecessaryWidgets(e)).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _getWrappedChildren() {
    List<Widget> children = [];
    for (int index = 0; index < data.content.childCount; index++) {
      children.add(
        OverflowBox(
          minHeight: 0,
          minWidth: null,
          maxHeight: double.infinity,
          maxWidth: null,
          alignment: Alignment.topCenter,
          child: SizeNotifier(
            dragUpdate: _dragSheet,
            dragEnd: _dragEnd,
            axis: data.axis,
            sheetLocation: data.content.location,
            currentPosition: context.read<SheetProvider>().currentPosition,
            snappingCalculator: context.read<SheetProvider>().snappingCalculator,
            onSizeChange: (size) {
              print('New Height: ${size.height} : Current Height: ${context.read<SheetProvider>().childrenSizes[index]}');

              context.read<SheetProvider>().updateChildSizeAt(index: index, height: size.height);
            },
            content: data.content,
            childIndex: index,
          ),
        ),
      );
    }

    return children;
  }

  Widget header() {
    final position = context.read<SheetProvider>().currentPosition;
    final dragWrapper = DragWrapper(
      axis: SheetData.instance.axis,
      dragEnd: _dragEnd,
      dragUpdate: _dragSheet,
      child: SheetHeader(tabController: tabController),
    );
    if (SheetData.instance.axis == Axis.horizontal) {
      return Positioned(
        left: position,
        bottom: 0,
        top: 0,
        width: context.read<SheetProvider>().grabbingHeight,
        child: dragWrapper,
      );
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: position,
      height: context.read<SheetProvider>().grabbingHeight,
      child: dragWrapper,
    );
  }
}

class SnappingSheetController {
  _DynamicSheetState? _state;

  /// If a state is attached to this controller. [isAttached] must be true
  /// before any function call from this controller is made
  bool get isAttached => _state != null;

  void _attachState(_DynamicSheetState state) {
    _state = state;
  }

  void _checkAttachment() {
    assert(
      isAttached,
      "SnappingSheet must be attached before calling any function from the controller. Pass in the controller to the snapping sheet widget to attached. Use [isAttached] to check if it is attached or not.",
    );
  }

  /// Snaps to a given snapping position.
  TickerFuture snapToPosition(SnappingPosition snappingPosition) {
    _checkAttachment();
    return _state!._snapToPosition(snappingPosition);
  }

  /// This sets the position of the snapping sheet directly without any
  /// animation. To use animation, see the [snapToPosition] method.
  void setSnappingSheetPosition(double positionInPixels) {
    _checkAttachment();
    _state!._setSheetPositionPixel(positionInPixels);
  }

  /// This sets the position of the snapping sheet directly without any
  /// animation. To use animation, see the [snapToPosition] method.
  void setSnappingSheetFactor(double positionAsFactor) {
    _checkAttachment();
    _state!._setSheetPositionFactor(positionAsFactor);
  }

  /// Getting the current position of the sheet. This is calculated from bottom
  /// to top. That is, when the grabbing widget is at the bottom, the
  /// [currentPosition] is close to zero. If the grabbing widget is at the top,
  /// the [currentPosition] is close the the height of the available height of
  /// the [SnappingSheet].
  double get currentPosition {
    _checkAttachment();
    // return _state!._currentPosition;
    final position = _state!.context.read<SheetProvider>().currentPosition;
    return position;
  }

  /// Getting the current snapping position of the sheet.
  SnappingPosition get currentSnappingPosition {
    _checkAttachment();
    // return _state!._lastSnappingPosition;
    final position = _state!.context.read<SheetProvider>().lastSnappingPosition;
    return position;
  }

  /// Returns true if the snapping sheet is currently trying to snap to a
  /// position.
  bool get currentlySnapping {
    _checkAttachment();
    return _state!._animationController.isAnimating;
  }

  /// Stops the current snapping if there is one ongoing.
  void stopCurrentSnapping() {
    _checkAttachment();
    return _state!._animationController.stop();
  }
}


