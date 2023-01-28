import 'package:dynamic_bottom_sheet/src/helpers/below_sheet_size_calculator.dart';
import 'package:dynamic_bottom_sheet/src/data/singleton.dart';
import 'package:dynamic_bottom_sheet/src/helpers/sheet_position_data.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_calculator.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_position.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_sheet_content.dart';
import 'package:dynamic_bottom_sheet/src/widget_size/widget_measurer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SheetProvider extends ChangeNotifier {
  // * Variables
  final double _grabbingHeight = 45;
  int _currentPageIndex = 0;
  int _previousPageIndex = 0;
  double _currentPosition = 0.0;
  BoxConstraints? _constraints;
  SnappingPosition _lastSnappingPosition = SheetData.instance.initialPosition ?? const SnappingPosition.pixels(positionPixels: 0.0);
  final List<double> _childrenSizes = List.filled(SheetData.instance.content.childCount, 0);
  final List<SnappingPosition> _snappingPositions = [
    const SnappingPosition.pixels(positionPixels: 0.0),
    const SnappingPosition.pixels(positionPixels: 0.0),
  ];

  // * Getters & Setters
  List<double> get childrenSizes => _childrenSizes;
  double get previousPageSize => _childrenSizes[_previousPageIndex];
  double get currentPageSize => _childrenSizes[_currentPageIndex];
  double get screenSize {
    if(_constraints != null){
      final size = SheetData.instance.axis == Axis.horizontal ? _constraints!.maxWidth : _constraints!.maxHeight;
      return size;
    }
    final size = SheetData.instance.axis == Axis.horizontal ? ScreenUtil().screenWidth : ScreenUtil().screenHeight;
    return size;
  }
  double get screenHeight {
    final height = _constraints!.maxHeight;
    return height;
  }
  double get screenWidth {
    final width = _constraints!.maxWidth;
    return width;
  }

  double get maxSheetSize {
    final maxSize = screenSize * SheetData.instance.sheetFactor;
    return maxSize;
  }
  double get grabbingHeight => _grabbingHeight;
  SnappingPosition get lastSnappingPosition => _lastSnappingPosition;
  SnappingPosition get maxSnappingPosition => _snappingPositions[1];
  double get currentPosition => _currentPosition;
  SnappingCalculator get snappingCalculator {
    final calculator = SnappingCalculator(
        allSnappingPositions: _snappingPositions,
        lastSnappingPosition: _lastSnappingPosition,
        maxHeight: screenSize,
        grabbingHeight: _grabbingHeight,
        currentPosition: _currentPosition,
    );
    return calculator;
  }
  SheetPositionData get createPositionData {
    final data = SheetPositionData(_currentPosition, snappingCalculator);
    return data;
  }
  BelowSheetSizeCalculator get sheetBelowSizeCalculator {
    final calculator = BelowSheetSizeCalculator(
      axis: SheetData.instance.axis,
      content: SheetData.instance.content,
      currentPosition: _currentPosition,
      maxHeight: screenSize,
      grabbingHeight: grabbingHeight,
    );
    return calculator; 
  }

  set lastSnappingPosition(SnappingPosition position){
    if(_lastSnappingPosition != position){
      _lastSnappingPosition = position;
      // notifyListeners();
    }
  }
  set currentPosition(double position) {
    if(_currentPosition != position){
      _currentPosition = position;
      notifyListeners();
      SheetData.instance.onSheetMoved?.call(createPositionData);
    }
  }
  set constraints(BoxConstraints? constraints){
    if(_constraints != constraints){
      _constraints = constraints;
      // notifyListeners();
    }
  }

  // * Methods
  List<double> getChildrenSizesBeforeBuild() {
    final length = SheetData.instance.content.childCount;
    List<double> sizesBeforeRender = List.filled(length, 0);
    try{
      for (int i = 0; i < length; i++) {
        final size = MeasureUtil.measureWidget(MeasureUtil.wrap(SheetData.instance.content.childAt(i)));
        sizesBeforeRender[i] = size.height > maxSheetSize ? maxSheetSize : size.height;
      }
    } catch(e){
      print('An unexpected error occurred while measuring widget constraints before render ...');
    }
    return sizesBeforeRender;
  }

  void updateChildrenSizes(List<double> sizes) {
    if (sizes.length == _childrenSizes.length) {
      for (int i = 0; i < sizes.length; i++) {
        updateChildSizeAt(index: i, height: sizes[i]);
      }
    }
  }

  void updateChildSizeAt({required int index, required double height}) {
    if (_childrenSizes[index] != height) {
      if (height >= maxSheetSize) {
        if (_childrenSizes[index] != maxSheetSize) {
          _childrenSizes[index] = maxSheetSize;
          notifyListeners();
        }
      } else {
        _childrenSizes[index] = height;
        notifyListeners();
      }
      if (index == _currentPageIndex) {
        updateMaxSnap();
      }
    }
  }

  void updateMaxSnap() {
    final height = _childrenSizes[_currentPageIndex];
    final snapPosition = SnappingPosition.pixels(positionPixels: height);

    if (_snappingPositions[1] != snapPosition) {
      _snappingPositions[1] = snapPosition;
      notifyListeners();
    }
    print('SNAP AFTER: ${_snappingPositions[1]} with ${_snappingPositions[1].pixel} pixel');
  }

  void setSheetLocationData() {
    // if (widget.sheetAbove != null) {
    //   widget.sheetAbove!.location = SheetLocation.above;
    // }
    SheetData.instance.content.location = SheetLocation.below;
  }
  
  void onPageChanged(int index){
    if(_currentPageIndex != index){
      _previousPageIndex = _currentPageIndex;
      _currentPageIndex = index;
      notifyListeners();
      updateMaxSnap();
    }
  }

  double getNewPosition(double dragAmount) {
    var newPosition = _currentPosition - dragAmount;
    if (SheetData.instance.lockOverflowDrag) {
      var calculator = snappingCalculator;
      var maxPos = calculator.getBiggestPositionPixels();
      var minPos = calculator.getSmallestPositionPixels();
      if (newPosition > maxPos) return maxPos;
      if (newPosition < minPos) return minPos;
    }
    return newPosition;
  }
  
  
  void updateCurrentPosition(double dragAmount){
    currentPosition = getNewPosition(dragAmount);
  }
}