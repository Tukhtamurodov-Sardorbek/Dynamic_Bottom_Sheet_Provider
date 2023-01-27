import 'package:dynamic_bottom_sheet/src/snapping_position.dart';
import 'package:dynamic_bottom_sheet/src/snapping_sheet_content.dart';
import 'package:dynamic_bottom_sheet/src/snapping_sheet_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snapping Sheet Examples',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[700],
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        primarySwatch: Colors.grey,
      ),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PageController pageController = PageController();
  final ScrollController listViewController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Example",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          )
        ],
      ),
      body: DynamicSheet(
        sheetFactor: 0.6,
        lockOverflowDrag: true,
        content: SheetContent(
          isDraggable: true,
          pageController: pageController,
          children: [
            SheetPage(isListView: true, child: Mwidget(15)),
            SheetPage(isListView: true, child: Mwidget(5)),
            SheetPage(isListView: false, child: Container(height: 200, color: Colors.black,)),
            SheetPage(isListView: true, child: Mwidget(145)),
            // SheetPage(isListView: true, child: Mwidget(1455)),
          ],
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(16),
          color: Colors.cyanAccent,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                height: 50,
                color: Colors.blueGrey,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget Mwidget(int count) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: count,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          color: Colors.green[200],
          margin: const EdgeInsets.only(bottom: 4),
          child: Center(child: Text(index.toString())),
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Placeholder(
        color: Colors.green[200]!,
      ),
    );
  }
}

class GrabbingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(blurRadius: 25, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 100,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Container(
            color: Colors.grey[200],
            height: 2,
            margin: const EdgeInsets.all(15).copyWith(top: 0, bottom: 0),
          )
        ],
      ),
    );
  }
}
