import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'package:flutter/rendering.dart';

import 'box_properties.dart';

class ColorPaletteSliverBoxModel extends AnimatedSliverBoxModel<String> {
  ColorPaletteSliverBoxModel({
    required super.sliverBoxContext,
    required SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>
        singleModel,
    required super.axis,
    required super.duration,
  }) : singleModels = [singleModel];

  List<SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>>
      singleModels;

  @override
  Iterable<SingleBoxModel> iterator() sync* {
    for (var single in singleModels) {
      yield single;
    }
  }

  SliverBoxRequestFeedBack changeAnimal(
      {required List<ChangeSingleModel> change,
      sliverBoxAction = SliverBoxAction.animate}) {
    return changeGroups(changeSingleBoxModels: change, checkAllGroups: false);
  }

  @override
  void disposeSingleModel(SingleBoxModel singleBoxModel) {
    singleModels.remove(singleBoxModel);
  }

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return trailingScrollOffset +
        (length - lastIndex - 1) *
            (axis == Axis.vertical ? initialNormalHeight : initialNormalWidth);
  }
}
