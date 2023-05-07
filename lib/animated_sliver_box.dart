// Copyright (C) 2023 Joan Schipper
// 
// This file is part of animated_sliver_box.
// 
// animated_sliver_box is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// animated_sliver_box is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with animated_sliver_box.  If not, see <http://www.gnu.org/licenses/>.

library animated_sliver_box;

import 'package:animated_sliver_box/sliver_row_box_model.dart';
import 'package:flutter/material.dart';
import 'flex_size_sliver/flex_size_sliver_list.dart';
import 'sliver_box_controller.dart';

enum BoxItemTransitionState {
  insert,
  visible,
  remove,
  insertLater,
  invisible,
  appear,
  disappear
}

enum SliverBoxAction { animate, appear, disappear, dispose, none }

typedef IgnorePointerCallback = Function(bool ignore);

typedef CreateSliverRowBoxModel<T extends AnimatedSliverBoxModel> = T Function(
    AnimatedSliverBoxState<T> sliverRowBoxContext);

typedef UpdateSliverRowBoxModel<T extends AnimatedSliverBoxModel> = Function(
    T model);

typedef BuildSliverBoxItem<Tag, P extends BoxItemProperties> = Widget Function(
    {Animation? animation,
    required int index,
    required int length,
    required P state,
    required SingleBoxModel<Tag, P> model});

class AnimatedSliverBox<T extends AnimatedSliverBoxModel>
    extends StatefulWidget {
  final SliverBoxController<T> controllerSliverRowBox;
  final CreateSliverRowBoxModel<T> createSliverRowBoxModel;
  final UpdateSliverRowBoxModel<T> updateSliverRowBoxModel;
  final IgnorePointerCallback? ignorePointerCallback;

  const AnimatedSliverBox(
      {Key? key,
      required this.controllerSliverRowBox,
      required this.createSliverRowBoxModel,
      required this.updateSliverRowBoxModel,
      this.ignorePointerCallback})
      : super(key: key);

  @override
  State<AnimatedSliverBox<T>> createState() => AnimatedSliverBoxState<T>();

  static AnimatedSliverBoxState? of(BuildContext context) {
    return context.findAncestorStateOfType<AnimatedSliverBoxState>();
  }
}

class AnimatedSliverBoxState<T extends AnimatedSliverBoxModel>
    extends State<AnimatedSliverBox<T>> with TickerProviderStateMixin {
  late SliverBoxController<T> _controllerSliverRowBox;

  late T model;

  @override
  void initState() {
    _controllerSliverRowBox = widget.controllerSliverRowBox;
    model = _controllerSliverRowBox.addModel(
        model: widget.createSliverRowBoxModel(this));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AnimatedSliverBox<T> oldWidget) {
    widget.updateSliverRowBoxModel(model);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controllerSliverRowBox.removeModel(model);
    widget.ignorePointerCallback?.call(false);
    super.dispose();
  }

  void change() {
    setState(() {});
  }

  void changeWithCallback(VoidCallback callback) {
    setState(callback);
  }

  @override
  Widget build(BuildContext context) {
    return FlexSizeSliverList(
        delegate: _FlexSizeSliverChildDelegate(
          model,
        ),
        model: model);
  }
}

class _FlexSizeSliverChildDelegate extends SliverChildDelegate {
  final AnimatedSliverBoxModel model;

  _FlexSizeSliverChildDelegate(
    this.model,
  );

  @override
  Widget? build(BuildContext context, int index) {
    // int m = 0;
    // for (SingleBoxModel single in model.iterator()) {
    //   debugPrint('model ${m++} ${single.visibleItems.length}');
    // }

    int count = 0;
    for (SingleBoxModel single in model.iterator()) {
      final length = single.visibleItems.length;

      if (index < count + length) {
        // debugPrint('index $index length $length count $count');
        return single.build(
            context: context, model: model, index: index - count);
      }
      count += length;
    }
    return null;
  }

  @override
  int? get estimatedChildCount => model.length;

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return model.estimateMaxScrollOffset(
        firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return true;
  }
}

class BoxItemProperties {
  BoxItemTransitionState transitionStatus;
  bool single;
  String id;
  double size;
  double measuredSize;
  bool useSizeOfChild;
  bool animateOutside;
  bool innerTransition;

  BoxItemProperties({
    this.transitionStatus = BoxItemTransitionState.visible,
    this.single = false,
    required this.id,
    required this.size,
    this.measuredSize = 0.0,
    this.useSizeOfChild = false,
    this.animateOutside = false,
    this.innerTransition = false,
  });

  double? get flexSize {
    return (transitionStatus == BoxItemTransitionState.visible &&
            !useSizeOfChild &&
            !innerTransition)
        ? size
        : null;
  }

  void setTransition(BoxItemTransitionState transitionState, bool outside) {
    transitionStatus = transitionState;
  }

  void garbageCollected() {}
}
