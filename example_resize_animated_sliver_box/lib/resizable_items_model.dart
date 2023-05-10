import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'package:example_resize_animated_sliver_box/box_properties.dart';

class ResizableItemsSliverBoxModel extends AnimatedSliverBoxModel<String> {
  ResizableItemsSliverBoxModel({
    required super.sliverBoxContext,
    required SingleBoxModel<String, ResizableItemsSliverBoxProperties>
        singleModel,
    required super.axis,
    required super.duration,
  }) : singleModels = [singleModel];

  List<SingleBoxModel<String, ResizableItemsSliverBoxProperties>> singleModels;

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
}
