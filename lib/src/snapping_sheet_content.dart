import 'package:flutter/widgets.dart';
import 'sheet_size_behaviors.dart';

enum SheetLocation {
  above,
  below,
  unknown,
}

class SheetContent {
  final bool isDraggable;
  final SheetSizeBehavior sizeBehavior;
  final PageController pageController;
  final List<SheetPage> _children;
  SheetLocation location = SheetLocation.unknown;

  SheetContent({
    this.isDraggable = false,
    this.sizeBehavior = const SheetSizeFill(),
    required this.pageController,
    required List<SheetPage> children,
  }) : _children = children;


  double? _getHeight() {
    var sizeBehavior = this.sizeBehavior;
    if (sizeBehavior is SheetSizeStatic) return sizeBehavior.size;
    return null;
  }
  Widget childAt(int index) {
    return SizedBox(
      height: _getHeight(),
      child: _children[index].child,
    );
  }
  SheetPage pageAt(int index) => _children[index];

  int get childCount => _children.length;
  List<SheetPage> get children => _children;
}

class SheetPage {
  final bool isListView;
  Widget? _child;
  ScrollController? _scrollController;

  SheetPage({
    required this.isListView,
    required Widget child,
  }){
    _child = isListView ? sheetListView(child) : child;
  }

  Widget sheetListView(Widget child){
    final receivedListView = child as ListView;
    _scrollController = receivedListView.controller ?? ScrollController();

    final listView = ListView.custom(
      shrinkWrap: true,
      controller: _scrollController,
      childrenDelegate: receivedListView.childrenDelegate,
    );
    return SizedBox(
      width: 250,
      child: listView,
    );
  }

  Widget get child => _child!;
  ScrollController? get scrollController => _scrollController;
}