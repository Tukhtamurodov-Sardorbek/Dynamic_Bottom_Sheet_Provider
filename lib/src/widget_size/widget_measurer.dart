import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// https://api.flutter.dev/flutter/widgets/BuildOwner-class.html
/// Example:
///          print(
///            MeasureUtil.measureWidget(
///              Directionality(
///                textDirection: TextDirection.ltr,
///                child: Row(
///                  mainAxisSize: MainAxisSize.min,
///                  children: const [
///                    Icon(Icons.abc),
///                    SizedBox(
///                      width: 100,
///                    ),
///                    Text("Moin Meister")
///                  ],
///                ),
///              ),
///            ),
///          );
///          Size(210.0, 24.0)
class MeasureUtil {
  static Widget wrap(Widget widget){
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return widget;
      },
    );
  }

  static Size measureWidget(Widget widget) {
    final PipelineOwner pipelineOwner = PipelineOwner();
    final _MeasurementView rootView = pipelineOwner.rootNode = _MeasurementView();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> element =
    RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: widget,
    ).attachToRenderTree(buildOwner);
    try {
      rootView.scheduleInitialLayout();
      pipelineOwner.flushLayout();
      return rootView.size;
    } finally {
      // Clean up.
      element.update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
      buildOwner.finalizeTree();
    }
  }
}

class _MeasurementView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    assert(child != null);
    child!.layout(const BoxConstraints(), parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
