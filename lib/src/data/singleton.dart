import 'package:dynamic_bottom_sheet/src/helpers/sheet_position_data.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_position.dart';
import 'package:dynamic_bottom_sheet/src/helpers/snapping_sheet_content.dart';
import 'package:dynamic_bottom_sheet/src/dynamic_sheet.dart';
import 'package:flutter/material.dart';

class SheetData {
  final double _horizontalPadding;
  final double _sheetFactor;
  final Axis _axis;
  final SheetContent _content;
  final Widget _scaffoldBody;
  final bool _lockOverflowDrag;
  final SnappingPosition? _initialPosition;
  final SnappingSheetController? _sheetController;
  final PageController _pageController;
  final Function(SheetPositionData positionData)? _onSheetMoved;
  final Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? _onSnapCompleted;
  final Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? _onSnapStart;

  const SheetData._internal({
    required double sheetFactor,
    required Axis axis,
    required SheetContent content,
    required Widget scaffoldBody,
    required bool lockOverflowDrag,
    required PageController pageController,
    required double horizontalPadding,
    SnappingPosition? initialPosition,
    SnappingSheetController? sheetController,
    Function(SheetPositionData positionData)? onSheetMoved,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapCompleted,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapStart,
  })  : _sheetFactor = sheetFactor,
        _axis = axis,
        _horizontalPadding = horizontalPadding,
        _content = content,
        _scaffoldBody = scaffoldBody,
        _lockOverflowDrag = lockOverflowDrag,
        _initialPosition = initialPosition,
        _sheetController = sheetController,
        _pageController = pageController,
        _onSheetMoved = onSheetMoved,
        _onSnapCompleted = onSnapCompleted,
        _onSnapStart = onSnapStart;


  double get sheetFactor => _sheetFactor;
  double get horizontalPadding => _horizontalPadding;
  Axis get axis => _axis;
  SheetContent get content => _content;
  Widget get scaffoldBody => _scaffoldBody;
  bool get lockOverflowDrag => _lockOverflowDrag;
  SnappingPosition? get initialPosition => _initialPosition;
  SnappingSheetController? get sheetController => _sheetController;
  PageController get pageController => _pageController;
  Function(SheetPositionData positionData)? get onSheetMoved => _onSheetMoved;
  Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? get onSnapCompleted => _onSnapCompleted;
  Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? get onSnapStart => _onSnapStart;

  static SheetData? _instance;
  static SheetData get instance => _instance!;
  static bool get isCreated => _instance != null;

  static void nullify(){
    _instance = null;
  }

  static void createInstance({
    required double sheetFactor,
    required double horizontalPadding,
    required Axis axis,
    required SheetContent content,
    required Widget scaffoldBody,
    required bool lockOverflowDrag,
    required PageController pageController,
    SnappingPosition? initialPosition,
    SnappingSheetController? sheetController,
    Function(SheetPositionData positionData)? onSheetMoved,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapCompleted,
    Function(SheetPositionData positionData, SnappingPosition snappingPosition,)? onSnapStart,
  }){
    _instance ??= SheetData._internal(
      sheetFactor: sheetFactor,
      horizontalPadding: horizontalPadding,
      axis: axis,
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
}
