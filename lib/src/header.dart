import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'data/provider.dart';
import 'data/singleton.dart';
import 'helpers/snapping_sheet_content.dart';

class SheetHeader extends StatefulWidget {
  final TabController tabController;
  const SheetHeader({Key? key, required this.tabController}) : super(key: key);

  @override
  State<SheetHeader> createState() => _SheetHeaderState();
}

class _SheetHeaderState extends State<SheetHeader> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("SHIT IS REBUILT");
    return Material(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      child: Container(
        height: context.read<SheetProvider>().grabbingHeight.r,
        padding: REdgeInsets.only(top: 10, bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4.r,
              width: 54.r,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            SizedBox(height: 10.r),
            if(isValid(SheetData.instance.content.children, true))
              _SheetTabBar(tabController: widget.tabController),
          ],
        ),
      ),
    );
  }

  Widget tabBar(){
    return TabBar(
      onTap: (index) {
        SheetData.instance.pageController.jumpToPage(index);
      },
      controller: widget.tabController,
      isScrollable: SheetData.instance.content.childCount > 4,
      physics: SheetData.instance.content.childCount > 4 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      // indicatorPadding: const EdgeInsets.symmetric(horizontal: -4),
      padding: REdgeInsets.symmetric(horizontal: SheetData.instance.horizontalPadding),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.blueGrey,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
      indicatorWeight: 0.0,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Creates border
        color: CupertinoColors.activeGreen,
      ),
      tabs: [
        for(int i = 0; i < SheetData.instance.content.childCount; i++)
          Tab(
            height: 40,
            text: SheetData.instance.content.pageAt(i).childTitle,
          ),
      ],
    );
  }
}

class _SheetTabBar extends StatelessWidget {
  final TabController tabController;
  const _SheetTabBar({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      onTap: (index) {
        SheetData.instance.pageController.jumpToPage(index);
      },
      controller: tabController,
      isScrollable: SheetData.instance.content.childCount > 4,
      physics: SheetData.instance.content.childCount > 4 ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      // indicatorPadding: const EdgeInsets.symmetric(horizontal: -4),
      padding: REdgeInsets.symmetric(horizontal: SheetData.instance.horizontalPadding),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.blueGrey,
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
      indicatorWeight: 0.0,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Creates border
        color: CupertinoColors.activeGreen,
      ),
      tabs: [
        for(int i = 0; i < SheetData.instance.content.childCount; i++)
          Tab(
            height: 40,
            text: SheetData.instance.content.pageAt(i).childTitle,
          ),
      ],
    );
  }
}
