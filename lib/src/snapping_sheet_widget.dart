import 'package:dynamic_bottom_sheet/src/widget_size/size_notifier.dart';
import 'package:dynamic_bottom_sheet/src/widget_size/widget_measurer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_bottom_sheet/src/below_sheet_size_calculator.dart';
import 'package:dynamic_bottom_sheet/src/on_drag_wrapper.dart';
import 'package:dynamic_bottom_sheet/src/sheet_position_data.dart';
import 'package:dynamic_bottom_sheet/src/snapping_calculator.dart';
import 'package:dynamic_bottom_sheet/src/snapping_position.dart';
import 'package:dynamic_bottom_sheet/src/snapping_sheet_content.dart';

class DynamicSheet extends StatefulWidget {
  final double maxSheetHeight;

  // final SnappingSheetContent? sheetAbove;
  final SheetContent content;
  // final Widget grabbing;
  // final double grabbingHeight;
  final Widget? child;
  final bool lockOverflowDrag;
  final SnappingPosition? initialSnappingPosition;
  final SnappingSheetController? controller;
  final Function(SheetPositionData positionData)? onSheetMoved;
  final Function(
    SheetPositionData positionData,
    SnappingPosition snappingPosition,
  )? onSnapCompleted;
  final Function(
    SheetPositionData positionData,
    SnappingPosition snappingPosition,
  )? onSnapStart;
  final Axis axis;

  const DynamicSheet({
    Key? key,
    required this.maxSheetHeight,
    // this.sheetAbove,
    required this.content,
    // this.grabbing = const SizedBox(),
    // this.grabbingHeight = 0,
    this.initialSnappingPosition,
    this.child,
    this.lockOverflowDrag = false,
    this.controller,
    this.onSheetMoved,
    this.onSnapCompleted,
    this.onSnapStart,
  })  : axis = Axis.vertical,
        super(key: key);

  const DynamicSheet.horizontal({
    Key? key,
    required this.maxSheetHeight,
    // SnappingSheetContent? sheetRight,
    required SheetContent sheetLeft,
    // this.grabbing = const SizedBox(),
    // double grabbingWidth = 0,
    this.initialSnappingPosition,
    this.child,
    this.lockOverflowDrag = false,
    this.controller,
    this.onSheetMoved,
    this.onSnapCompleted,
    this.onSnapStart,
  })  : content = sheetLeft,
        // sheetAbove = sheetRight,
        axis = Axis.horizontal,
        // grabbingHeight = grabbingWidth,
        super(key: key);

  @override
  _DynamicSheetState createState() => _DynamicSheetState();
}

class _DynamicSheetState extends State<DynamicSheet> with TickerProviderStateMixin {
  double _currentPositionPrivate = 0;
  double grabbingHeight = 90;
  BoxConstraints? _latestConstraints;
  late SnappingPosition _lastSnappingPosition;
  late AnimationController _animationController;
  Animation<double>? _snappingAnimation;
  int previousPageIndex = 0;
  int currentPageIndex = 0;
  final List<double> _childrenSizes = List.filled(4, 0);
  final List<SnappingPosition> _snappingPositions = [
    const SnappingPosition.factor(positionFactor: 0.0),
    const SnappingPosition.factor(positionFactor: 0.0),
  ];

  List<double> getChildrenSizesBeforeBuild() {
    List<double> sizesBeforeRender = List.filled(widget.content.childCount, 0);
    try{
      for (int i = 0; i < widget.content.childCount; i++) {
        final size = MeasureUtil.measureWidget(
            MeasureUtil.wrap(widget.content.childAt(i)));
        sizesBeforeRender[i] = size.height > widget.maxSheetHeight
            ? widget.maxSheetHeight
            : size.height;
      }
    } catch(e){}
    return sizesBeforeRender;
  }

  void updateMaxSnap({bool snapAfterUpdate = true}) {
    final height = _childrenSizes[currentPageIndex];
    final snapPosition = SnappingPosition.pixels(positionPixels: height);

    if (_snappingPositions[1] != snapPosition) {
      setState(() {
        _snappingPositions[1] = snapPosition;
      });
    }
    print('SNAP AFTER: ${_snappingPositions[1]} with ${_snappingPositions[1].pixel} pixel');

    if(snapAfterUpdate){
      _snapToPosition(_snappingPositions[1]);
    }
  }

  void updateChildrenSizes(List<double> sizes,{bool snapAfterUpdate = true}) {
    if (sizes.length == _childrenSizes.length) {
      for (int i = 0; i < sizes.length; i++) {
        updateChildSizeAt(index: i, height: sizes[i], snapAfterUpdate: snapAfterUpdate);
      }
    }
  }

  void updateChildSizeAt({required int index, required double height, bool snapAfterUpdate = true}) {
    if (_childrenSizes[index] != height) {
      if (height >= widget.maxSheetHeight) {
        if (_childrenSizes[index] != widget.maxSheetHeight) {
          setState(() {
            _childrenSizes[index] = widget.maxSheetHeight;
          });
        }
      } else {
        setState(() {
          _childrenSizes[index] = height;
        });
      }
      if (index == currentPageIndex) {
        updateMaxSnap(snapAfterUpdate: snapAfterUpdate);
      }
    }
  }

  void onPageChanged(int index) {
    if(currentPageIndex != index){
      setState(() {
        previousPageIndex = currentPageIndex;
        currentPageIndex = index;

      });
      updateMaxSnap();
    }


    // var bestSnappingPosition = _getSnappingCalculator().getBestSnappingPosition();
    _snapToPosition(_snappingPositions[1]);
    print('BEFORE: previousSize: ${_childrenSizes[previousPageIndex]} at $previousPageIndex');
    print('BEFORE: currentSize: ${_childrenSizes[currentPageIndex]} at $currentPageIndex');
    setState(() {
      previousPageIndex = currentPageIndex;
      currentPageIndex = index;
    });
    print('NOW: previousSize: ${_childrenSizes[previousPageIndex]} at $previousPageIndex');
    print('NOW: currentSize: ${_childrenSizes[currentPageIndex]} at $currentPageIndex');
  }

  @override
  void initState() {
    final childrenHeights = getChildrenSizesBeforeBuild();
    print('HEIGHT: $childrenHeights');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateChildrenSizes(childrenHeights, snapAfterUpdate: false);
      print('Snap: ${_snappingPositions[1]}');
    });

    _setSheetLocationData();
    _lastSnappingPosition = _initSnappingPosition;
    _animationController = AnimationController(vsync: this);
    _animationController.addListener(() {
      if (_snappingAnimation == null) return;
      setState(() {
        _currentPosition = _snappingAnimation!.value;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSnapCompleted?.call(
          _createPositionData(),
          _lastSnappingPosition,
        );
      }
    });

    Future.delayed(const Duration(seconds: 0)).then((value) {
      setState(() {
        _currentPosition = _initSnappingPosition.getPositionInPixels(
          sheetSize,
          grabbingHeight,
        );
      });
    });

    if (widget.controller != null) {
      widget.controller!._attachState(this);
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
    _setSheetLocationData();
  }

  void _setSheetLocationData() {
    // if (widget.sheetAbove != null) {
    //   widget.sheetAbove!.location = SheetLocation.above;
    // }
    widget.content.location = SheetLocation.below;
  }

  set _currentPosition(double newPosition) {
    _currentPositionPrivate = newPosition;
    widget.onSheetMoved?.call(_createPositionData());
  }

  double get _currentPosition => _currentPositionPrivate;

  SnappingPosition get _initSnappingPosition {
    return widget.initialSnappingPosition ?? _snappingPositions.first;
  }

  SheetPositionData _createPositionData() {
    return SheetPositionData(
      _currentPosition,
      _getSnappingCalculator(),
    );
  }

  double _getNewPosition(double dragAmount) {
    var newPosition = _currentPosition - dragAmount;
    if (widget.lockOverflowDrag) {
      var calculator = _getSnappingCalculator();
      var maxPos = calculator.getBiggestPositionPixels();
      var minPos = calculator.getSmallestPositionPixels();
      if (newPosition > maxPos) return maxPos;
      if (newPosition < minPos) return minPos;
    }
    return newPosition;
  }

  void _dragSheet(double dragAmount) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    setState(() {
      _currentPosition = _getNewPosition(dragAmount);
    });
  }

  void _dragEnd() {
    var bestSnappingPosition =
        _getSnappingCalculator().getBestSnappingPosition();
    _snapToPosition(bestSnappingPosition);
  }

  TickerFuture _snapToPosition(SnappingPosition snappingPosition) {
    widget.onSnapStart?.call(
      _createPositionData(),
      snappingPosition,
    );
    _lastSnappingPosition = snappingPosition;
    return _animateToPosition(snappingPosition);
  }

  TickerFuture _animateToPosition(SnappingPosition snappingPosition) {
    _animationController.duration = snappingPosition.snappingDuration;
    var endPosition = snappingPosition.getPositionInPixels(
      sheetSize,
      grabbingHeight,
    );
    _snappingAnimation = Tween(
      begin: _currentPosition,
      end: endPosition,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: snappingPosition.snappingCurve,
      ),
    );
    _animationController.reset();
    return _animationController.forward();
  }

  SnappingCalculator _getSnappingCalculator() {
    return SnappingCalculator(
        allSnappingPositions: _snappingPositions,
        lastSnappingPosition: _lastSnappingPosition,
        maxHeight: sheetSize,
        grabbingHeight: grabbingHeight,
        currentPosition: _currentPosition);
  }

  double get sheetSize {
    return widget.axis == Axis.horizontal
        ? _latestConstraints!.maxWidth
        : _latestConstraints!.maxHeight;
  }

  Widget buildGrabbingWidget() {
    final position = _currentPosition;
    final dragWrapper = OnDragWrapper(
      axis: widget.axis,
      dragEnd: _dragEnd,
      dragUpdate: _dragSheet,
      child: grabbing(),
    );
    if (widget.axis == Axis.horizontal) {
      return Positioned(
        left: position,
        bottom: 0,
        top: 0,
        width: grabbingHeight,
        child: dragWrapper,
      );
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: position,
      height: grabbingHeight,
      child: dragWrapper,
    );
  }

  BelowSheetSizeCalculator getWidget() {
    return BelowSheetSizeCalculator(
      axis: widget.axis,
      content: widget.content,
      currentPosition: _currentPosition,
      maxHeight: sheetSize,
      grabbingHeight: grabbingHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _latestConstraints = constraints;
        return Stack(
          children: [
            if (widget.child != null) Positioned.fill(child: widget.child!),

            buildGrabbingWidget(),

            Positioned(
              left: 0,
              right: widget.axis == Axis.horizontal ? sheetSize - _currentPosition : 0,
              bottom: 0,
              top: widget.axis == Axis.horizontal ? 0 : sheetSize - _currentPosition,
              child: ColoredBox(
                color: Colors.white,
                child: TweenAnimationBuilder<double>(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 200),
                  tween: Tween<double>(begin: _childrenSizes[previousPageIndex], end: _childrenSizes[currentPageIndex]),
                  builder: (context, value, child) {
                    return SizedBox(
                      height: value,
                      child: child,
                    );
                  },
                  child: PageView(
                    controller: widget.content.pageController,
                    onPageChanged: (index) {
                      onPageChanged(index);
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
    for (int index = 0; index < widget.content.childCount; index++) {
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
            axis: widget.axis,
            sheetLocation: widget.content.location,
            currentPosition: _currentPosition,
            snappingCalculator: _getSnappingCalculator(),
            onSizeChange: (size) {
              print('New Height: ${size.height} : Current Height: ${_childrenSizes[index]}');
              if (_childrenSizes[index] != size.height) {
                updateChildSizeAt(index: index, height: size.height);
              }
            },
            content: widget.content,
            childIndex: index,
          ),
        ),
      );
    }

    return children;
  }


  Widget grabbing(){
    return Material(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
      child: Container(
        height: grabbingHeight,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 54,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            SizedBox(height: 10),
            CustomTabBar(),
          ],
        ),
      ),
    );
  }


  Widget CustomTabBar() {
    final width = MediaQuery.of(context).size.width;
    final tabWidth = (width - 32) / 4;
    final titles = List.filled(_childrenSizes.length, 'Title');
    return Container(
      height: 48,
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          AnimatedPositioned(
            left: currentPageIndex * tabWidth,
            duration: const Duration(milliseconds: 250),
            curve: Curves.ease,
            child: Container(
              height: 40,
              width: tabWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: CupertinoColors.systemGreen,
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < titles.length; i++)
                InkWell(
                  onTap: () {
                    widget.content.pageController.jumpToPage(i);
                    setState(() {
                      currentPageIndex = i;
                    });
                  },
                  child: SizedBox(
                    width: tabWidth,
                    child: _TabItem(
                      title: titles[i],
                      isSelected: currentPageIndex == i,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }


  void _setSheetPositionPixel(double positionPixel) {
    _animationController.stop();
    setState(() {
      _currentPosition = positionPixel;
    });
  }

  void _setSheetPositionFactor(double factor) {
    _animationController.stop();
    setState(() {
      _currentPosition = factor * sheetSize;
    });
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
    return _state!._currentPosition;
  }

  /// Getting the current snapping position of the sheet.
  SnappingPosition get currentSnappingPosition {
    _checkAttachment();
    return _state!._lastSnappingPosition;
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


class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _TabItem({
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : Colors.blueGrey,
        ),
      ),
    );
  }
}
