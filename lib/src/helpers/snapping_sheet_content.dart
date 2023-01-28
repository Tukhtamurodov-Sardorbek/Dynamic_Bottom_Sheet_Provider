import 'package:flutter/widgets.dart';
import 'sheet_size_behaviors.dart';

enum SheetLocation {
  above,
  below,
  unknown,
}
bool isValid(List<SheetPage> pages, [bool checkForNull = false]){
  bool hasAtLeastOneTitle = pages.any((page) => page.childTitle != null);
  bool hasAtLeastOneNullTitle = pages.any((page) => page.childTitle == null);
  bool hasAtLeastOneEmptyTitle = pages.any((page) => page.childTitle?.toString().isEmpty ?? false);

  if(checkForNull){
    final canShowTitles = hasAtLeastOneNullTitle
        ? false
        : hasAtLeastOneTitle
          ? hasAtLeastOneEmptyTitle ? false : true
          : false;
    print("CAN SHOW TABS: $canShowTitles");
    return canShowTitles;
  }

  bool isValid = hasAtLeastOneNullTitle
      ? hasAtLeastOneTitle ? false : true
      : hasAtLeastOneEmptyTitle ? false : true;
  print("IS VALID: $isValid");
  // final best1 = ['1', '2', '3'];
  // final best2 = [null, null, null];
  //
  // final list1 = [null, null, 'one'];
  // final list2 = [null, null, ''];
  // final list3 = [null, 'null', ''];
  // final list4 = ['', '', ''];
  //
  // List<String?> pages = list4;
  //
  // bool hasAtLeastOneTitle = pages.any((page) => page != null);
  // bool hasAtLeastOneNullTitle = pages.any((page) => page == null);
  // bool hasAtLeastOneEmptyTitle = pages.any((page) => page?.toString().isEmpty ?? false);
  //
  // bool isValid = hasAtLeastOneNullTitle
  //     ? hasAtLeastOneTitle ? false : true
  //     : hasAtLeastOneEmptyTitle ? false : true;
  //
  // print("LIST: $pages => IS VALID: $isValid");
  // print("AT LEAST ONE TITLE: $hasAtLeastOneTitle");
  // print("AT LEAST ONE NULL TITLE: $hasAtLeastOneNullTitle");
  // print("AT LEAST ONE EMPTY TITLE: $hasAtLeastOneEmptyTitle");
  return isValid;
}

class SheetContent {
  // final bool isDraggable;
  final SheetSizeBehavior sizeBehavior;
  final List<SheetPage> _children;
  SheetLocation location = SheetLocation.unknown;

  SheetContent({
    // this.isDraggable = false,
    this.sizeBehavior = const SheetSizeFill(),
    required List<SheetPage> children,
  }) :  assert(isValid(children), 'Title for each child must either be provided or null'),
        _children = children;

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
  String? _title;
  Widget? _child;
  ScrollController? _scrollController;

  SheetPage({
    required this.isListView,
    String? title,
    required Widget child,
  }){
    _title = title;
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
  String? get childTitle => _title;
  ScrollController? get scrollController => _scrollController;
}