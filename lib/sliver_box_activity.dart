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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'animated_sliver_box.dart';
import 'sliver_row_box_model.dart';

abstract class SliverBoxActivity {
  const SliverBoxActivity();

  Animation<double>? get animation;
  bool get isAnimating;
  void dispose();
}

class NoSliverBoxActivity extends SliverBoxActivity {
  const NoSliverBoxActivity();

  @override
  Animation<double>? get animation => null;

  @override
  bool get isAnimating => false;

  @override
  void dispose() {}
}

class AnimatedSliverBoxActivity extends SliverBoxActivity {
  AnimationController controller;
  final AnimatedSliverBoxModel model;
  final SingleBoxModel singleBoxModel;
  final VoidCallback endOfAnimation;
  late final Animation<double> _animation;

  AnimatedSliverBoxActivity({
    required AnimatedSliverBoxState vsync,
    required this.model,
    required this.singleBoxModel,
    required this.endOfAnimation,
    required Animatable<double> animatable,
    required Duration? duration,
  }) : controller = AnimationController(
            vsync: vsync,
            duration: duration ??
                singleBoxModel.duration ??
                const Duration(milliseconds: 300)) {
    _animation = controller.drive(animatable);
  }

  @override
  void dispose() {
    controller.dispose();
  }

  @override
  bool get isAnimating => controller.isAnimating;

  @override
  Animation<double>? get animation => _animation;

  void changeGroup({required SliverBoxAction sliverBoxAction}) {
    singleBoxModel
      ..evaluateVisibleItems()
      ..sliverBoxAction = sliverBoxAction;
    model.sliverBoxContext?.changeWithCallback(() {
      model.setIgnorePointer(true);
      animate();
    });
  }

  void animate() {
    controller.value = 0.0;

    controller.forward().then((value) {
      _toStatic();
      _end();
    });
  }

  void _toStatic() {
    List<BoxItemProperties> list = singleBoxModel.items;
    int length = list.length;
    int i = 0;
    while (i < length) {
      BoxItemProperties state = list[i];

      if (state.transitionStatus == BoxItemTransitionState.insertLater ||
          state.transitionStatus == BoxItemTransitionState.insert) {
        state.transitionStatus = BoxItemTransitionState.visible;
        i++;
      } else if (!state.single &&
          state.transitionStatus == BoxItemTransitionState.remove) {
        list.removeAt(i);
        length--;
      } else if (state.transitionStatus == BoxItemTransitionState.disappear) {
        state.transitionStatus = BoxItemTransitionState.invisible;
        i++;
      } else {
        i++;
      }
    }
  }

  _end() {
    if (singleBoxModel.sliverBoxAction == SliverBoxAction.dispose) {
      // ScheduleMicrotask because the List can still be iterated!
      //
      scheduleMicrotask(() {
        model.disposeSingleModel(singleBoxModel);
      });
    }

    singleBoxModel
      ..evaluateVisibleItems()
      ..sliverBoxAction = SliverBoxAction.none
      ..setActivity(const NoSliverBoxActivity());

    model.animationEnd();
  }
}

class OutsideSliverBoxActivity extends SliverBoxActivity {
  final AnimatedSliverBoxModel model;
  final SingleBoxModel singleBoxModel;

  OutsideSliverBoxActivity({
    required this.model,
    required this.singleBoxModel,
  });

  @override
  void dispose() {}

  @override
  bool get isAnimating => false;

  @override
  Animation<double>? get animation => null;

  void changeGroup({required SliverBoxAction sliverBoxAction}) {
    singleBoxModel.sliverBoxAction = sliverBoxAction;
    _toStatic();
    _end();
  }

  void _toStatic() {
    List<BoxItemProperties> list = singleBoxModel.items;
    int length = list.length;
    int i = 0;
    while (i < length) {
      BoxItemProperties state = list[i];

      if (state.transitionStatus == BoxItemTransitionState.insertLater ||
          state.transitionStatus == BoxItemTransitionState.insert) {
        state.transitionStatus = BoxItemTransitionState.visible;
        i++;
      } else if (!state.single &&
          state.transitionStatus == BoxItemTransitionState.remove) {
        list.removeAt(i);
        length--;
      } else if (state.transitionStatus == BoxItemTransitionState.disappear) {
        state.transitionStatus = BoxItemTransitionState.invisible;
        i++;
      } else {
        i++;
      }
    }
  }

  _end() {
    if (singleBoxModel.sliverBoxAction == SliverBoxAction.dispose) {
      // ScheduleMicrotask because the List can still be iterated!
      //
      scheduleMicrotask(() {
        model.disposeSingleModel(singleBoxModel);
      });
    }

    singleBoxModel
      ..evaluateVisibleItems()
      ..sliverBoxAction = SliverBoxAction.none
      ..setActivity(const NoSliverBoxActivity());
  }
}
