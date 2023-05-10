import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:flutter/widgets.dart';

import 'some_colors.dart';

const initialNormalHeight = 100.0;
const initialNormalWidth = 200.0;
const itemEditHeight = 500.0;
const itemEditWidth = 400.0;
const horizontalHeight = 440.0;

enum PanelSimpleItem { normal, edit }

class SimpleItem {
  ColorName colorName;
  int index;

  SimpleItem({
    required this.index,
    required this.colorName,
  });
}

class ResizableItemsSliverBoxProperties extends BoxItemProperties {
  PanelSimpleItem panel;
  PanelSimpleItem? toPanel;
  SimpleItem value;
  double normalWidth;
  double normalHeight;
  double width;
  double height;
  bool aliveOutsideView;

  double measureHeight;

  ResizableItemsSliverBoxProperties({
    super.transitionStatus = BoxItemTransitionState.visible,
    required super.id,
    required this.panel,
    this.toPanel,
    super.single = false,
    required this.value,
    required this.normalWidth,
    required this.normalHeight,
    this.aliveOutsideView = false,
  })  : width = normalWidth,
        height = normalHeight,
        measureHeight = itemEditHeight;

  fixPanel() {
    final to = toPanel;
    if (to == null) {
      return;
    }
    toPanel = null;
    panel = to;
    innerTransition = false;
  }

  setToPanel(PanelSimpleItem? panel) {
    toPanel = panel;

    if (panel == null) {
      innerTransition = false;
    } else {
      innerTransition = true;
    }
  }

  String idKey() {
    return 'item_$id';
  }

  @override
  void garbageCollected(Axis axis) {
    if (aliveOutsideView) {
      panel = toPanel ?? panel;
    } else {
      panel = PanelSimpleItem.normal;
    }
    toPanel = null;
    innerTransition = false;
  }

  void setNormalSize({required double size, required Axis axis}) {
    if (axis == Axis.vertical) {
      normalHeight = size;
    } else {
      normalWidth = size;
    }
  }

  @override
  double size(Axis axis) {
    if (axis == Axis.vertical) {
      return panel == PanelSimpleItem.normal ? height : itemEditHeight;
    } else {
      return panel == PanelSimpleItem.normal ? width : itemEditWidth;
    }
  }

  @override
  bool useSizeOfChild(Axis axis) {
    return axis == Axis.vertical ? panel == PanelSimpleItem.normal : true;
  }

  @override
  double suggestedSize(Axis axis) {
    if (axis == Axis.vertical) {
      return panel == PanelSimpleItem.normal ? height : measureHeight;
    } else {
      return panel == PanelSimpleItem.normal ? width : itemEditWidth;
    }
  }

  @override
  void setMeasuredSize(Axis axis, double size) {
    if (axis == Axis.vertical) {
      measureHeight = size;
    }
  }
}
