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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'animated_sliver_box.dart';
import 'flex_size_sliver/flex_size_sliver_list.dart';
import 'flex_size_sliver/flex_size_tracker.dart';
import 'sliver_box_activity.dart';
import 'sliver_box_controller.dart';

class ChangeSingleModel<Taq, P extends BoxItemProperties> {
  final SingleBoxModel<Taq, P> singleBoxModel;
  final Function(List<P> list) _changeSliverProperties;
  final SliverBoxAction sliverBoxAction;

  ChangeSingleModel(
    this.singleBoxModel,
    this._changeSliverProperties,
    this.sliverBoxAction,
  );

  void changeSliverProperties() {
    _changeSliverProperties(singleBoxModel.items);
  }
}

typedef BuildStateItem<Tag, P extends BoxItemProperties> = Widget Function(
    {required BuildContext buildContext,
    Animation<double>? animation,
    required AnimatedSliverBoxModel<Tag> model,
    required P properties,
    required SingleBoxModel<Tag, P> singleBoxModel,
    required int index});

abstract class AnimatedSliverBoxModel<Tag> {
  AnimatedSliverBoxState? sliverBoxContext;
  final Animatable<double> animatable;
  Axis axis;
  double animationAfterLayout = 0.0;
  Duration duration;

  AnimatedSliverBoxModel(
      {required this.sliverBoxContext,
      Animatable<double>? animatable,
      required this.duration,
      required this.axis})
      : animatable = animatable ?? CurveTween(curve: Curves.easeInOut);

  int get length => iterator().fold<int>(
      0,
      (int previous, SingleBoxModel singleBoxModel) =>
          previous + singleBoxModel.visibleItems.length);

  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return null;
  }

  Iterable<SingleBoxModel> iterator();

  BoxItemProperties getProperties(int index) {
    int count = 0;
    for (SingleBoxModel single in iterator()) {
      final length = single.visibleItems.length;

      if (index < count + length) {
        return single.visibleItems[index - count];
      }
      count += length;
    }
    throw IndexError.withLength(index, count);
  }

  SliverBoxRequestFeedBack feedBackModel(
      {required List<ChangeSingleModel>? changeSingleModels,
      required bool individual,
      required bool checkAllGroups}) {
    SliverBoxRequestFeedBack feedback = SliverBoxRequestFeedBack.noModel;

    if (changeSingleModels == null || checkAllGroups) {
      for (SingleBoxModel singleBoxModel in iterator()) {
        feedback = changeRequest(model: singleBoxModel, individual: false);
        if (feedback != SliverBoxRequestFeedBack.accepted) {
          return feedback;
        }
      }
      return feedback;
    }

    for (ChangeSingleModel change in changeSingleModels) {
      feedback =
          changeRequest(model: change.singleBoxModel, individual: individual);
      if (feedback != SliverBoxRequestFeedBack.accepted) {
        return feedback;
      }
    }
    return feedback;
  }

  SliverBoxRequestFeedBack changeGroups(
      {final List<ChangeSingleModel>? changeSingleBoxModels,
      final Function(
        List<BoxItemProperties> list,
        Tag tag,
      )? changeGroupModelProperties,
      bool individual = false,
      required bool checkAllGroups,
      SliverBoxAction groupModelAction = SliverBoxAction.none,
      Animatable<double>? animatable,
      bool animateInsertDeleteAbove = true,
      VoidCallback? insertModel}) {
    //
    // Feedback check
    //
    //
    final feedback = feedBackModel(
        changeSingleModels: changeSingleBoxModels,
        checkAllGroups: checkAllGroups,
        individual: individual);

    if (feedback != SliverBoxRequestFeedBack.accepted) {
      return feedback;
    }

    //
    // Evaluation
    //
    //
    insertModel?.call();

    evaluateState(
      modelsToEvaluate: changeSingleBoxModels,
      changeSliverProperties: changeGroupModelProperties,
      animateInsertDeleteAbove: animateInsertDeleteAbove,
      sliverBoxAction: groupModelAction,
      changeModel: (
          {required SingleBoxModel single,
          required bool animation,
          required SliverBoxAction sliverBoxAction}) {
        SliverBoxActivity activity;
        if (animation) {
          activity = AnimatedSliverBoxActivity(
              animatable: animatable ?? this.animatable,
              endOfAnimation: animationEnd,
              model: this,
              singleBoxModel: single,
              vsync: sliverBoxContext!,
              duration: single.duration ?? duration)
            ..changeGroup(sliverBoxAction: sliverBoxAction);
        } else {
          activity = OutsideSliverBoxActivity(
            model: this,
            singleBoxModel: single,
          )..changeGroup(sliverBoxAction: sliverBoxAction);
        }
        single.setActivity(activity);
      },
    );

    return feedback;
  }

  SliverBoxRequestFeedBack changeIndividual(
      {required SingleBoxModel singleBoxModel,
      required Function(List<BoxItemProperties> list) change,
      required bool evaluateVisibleItems,
      Animatable<double>? animatable}) {
    final feedback = changeRequest(model: singleBoxModel, individual: true);

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      change(singleBoxModel.items);
      if (evaluateVisibleItems) {
        singleBoxModel.evaluateVisibleItems();
      }
    }
    return feedback;
  }

  SliverBoxRequestFeedBack appear() {
    return changeGroups(
        changeGroupModelProperties: (List<BoxItemProperties> list, _) {
          for (BoxItemProperties item in list) {
            item.transitionStatus = BoxItemTransitionState.insert;
          }
        },
        checkAllGroups: true,
        groupModelAction: SliverBoxAction.appear,
        animateInsertDeleteAbove: false);
  }

  SliverBoxRequestFeedBack disappear() {
    return changeGroups(
        changeGroupModelProperties: (List<BoxItemProperties> list, _) {
          for (BoxItemProperties item in list) {
            item.transitionStatus = BoxItemTransitionState.disappear;
          }
        },
        checkAllGroups: true,
        groupModelAction: SliverBoxAction.disappear,
        animateInsertDeleteAbove: false);
  }

  void individualRemoval(
      SingleBoxModel singleBoxModel, BoxItemProperties state) {
    sliverBoxContext?.changeWithCallback(() {
      singleBoxModel
        ..items.remove(state)
        ..evaluateVisibleItems();
    });
  }

  SliverBoxRequestFeedBack changeRequest(
      {required SingleBoxModel model, required bool individual}) {
    if (model.sliverBoxAction != SliverBoxAction.none) {
      return SliverBoxRequestFeedBack.groupAnimation;
    } else if (!individual && model.individualTransition != 0) {
      return SliverBoxRequestFeedBack.individualAnimation;
    } else {
      return SliverBoxRequestFeedBack.accepted;
    }
  }

  void evaluateState(
      {final List<ChangeSingleModel>? modelsToEvaluate,
      final Function(List<BoxItemProperties> list, Tag tag)?
          changeSliverProperties,
      SliverBoxAction sliverBoxAction = SliverBoxAction.none,
      required Function(
              {required SingleBoxModel single,
              required bool animation,
              required SliverBoxAction sliverBoxAction})
          changeModel,
      required bool animateInsertDeleteAbove}) {
    FlexSizeRenderSliverList? r = sliverBoxContext?.context.findRenderObject()
        as FlexSizeRenderSliverList?;
    double scrollOffset = r?.constraints.scrollOffset ?? 0.0;
    double viewportSize = r?.constraints.viewportMainAxisExtent ?? 0.0;
    assert((r?.constraints.axis ?? axis) == axis,
        'Axis from AnimatedSliverBox $axis is not equal to CustomScrollview: ${r?.constraints.axis} ');
    // debugPrint(
    //     'Evaluate scrollOffset: $scrollOffset, viewportHeight: $viewportHeight');

    double end = 0.0;
    double visibleEnd = 0.0;
    double insertEnd = 0.0;
    double removeEnd = 0.0;
    double correct = 0.0;

    //If somehow the layout is not triggered the newLengthToVisual should set to -1 again.
    FirstVisual? firstVisual = r?.firstVisual?..newLengthToVisual = -1;
    bool searchFirstVisual = true;
    int newLengthToVisual = 0;
    double virtualOffset = -(firstVisual?.overflow ?? 0.0);

    bool evaluateList({required List<BoxItemProperties> list}) {
      bool animationVisible = false;
      int count = list.length;
      int i = 0;
      while (i < count) {
        final item = list[i];
        final itemSize = item.suggestedSize(axis);
        bool removed = false;

        if (searchFirstVisual) {
          if (firstVisual == null) {
            searchFirstVisual = false;
          } else if (item == firstVisual.boxItemProperties) {
            newLengthToVisual++;
            firstVisual.newLengthToVisual = newLengthToVisual;
            searchFirstVisual = false;
          }
        }

        if (searchFirstVisual) {
          switch (item.transitionStatus) {
            case BoxItemTransitionState.insertFront:
              {
                if (virtualOffset + insertEnd < viewportSize) {
                  insertEnd += itemSize;

                  // newLengthToVisual++;
                } else {
                  item.transitionStatus = BoxItemTransitionState.insertLater;
                }
                animationVisible = true;

                break;
              }
            case BoxItemTransitionState.appear:
            case BoxItemTransitionState.insert:
              {
                newLengthToVisual++;
                item.transitionStatus = BoxItemTransitionState.visible;
                correct += itemSize;

                //Draag niet bij aan end, omdat in het begin klein is.
                // end += itemHeight;

                break;
              }
            case BoxItemTransitionState.visible:
              {
                newLengthToVisual++;
                visibleEnd = insertEnd = removeEnd = end += itemSize;
                break;
              }
            case BoxItemTransitionState.disappear:
              {
                item.transitionStatus = BoxItemTransitionState.invisible;
                correct -= itemSize;
                visibleEnd = insertEnd = removeEnd = end += itemSize;
                break;
              }
            case BoxItemTransitionState.invisible:
              {
                //Invisible doet niet mee
                break;
              }
            case BoxItemTransitionState.remove:
              {
                correct -= itemSize;
                visibleEnd = insertEnd = removeEnd = end += itemSize;
                list.removeAt(i);
                removed = true;
                break;
              }
            case BoxItemTransitionState.insertLater:
              {
                assert(false,
                    'InsertLater before scrollOffset should never happen!');
                break;
              }
          }
        } else {
          switch (item.transitionStatus) {
            case BoxItemTransitionState.appear:
            case BoxItemTransitionState.insertLater:
            case BoxItemTransitionState.insert:
              {
                if (insertEnd > scrollOffset + viewportSize &&
                    !item.animateOutside) {
                  item.transitionStatus = BoxItemTransitionState.insertLater;

                  // Animatie draaien anders verschijnt die als nog meteen.
                  if (visibleEnd < scrollOffset + viewportSize) {
                    animationVisible = true;
                  }
                } else {
                  item.transitionStatus = BoxItemTransitionState.insert;
                  animationVisible = true;
                }
                end += itemSize;
                insertEnd += itemSize;
                break;
              }
            case BoxItemTransitionState.visible:
              {
                end += itemSize;
                visibleEnd += itemSize;
                insertEnd += itemSize;
                removeEnd += itemSize;
                break;
              }
            case BoxItemTransitionState.remove:
              {
                if (removeEnd > scrollOffset + viewportSize &&
                    !item.animateOutside) {
                  list.removeAt(i);
                  removed = true;
                } else {
                  end += itemSize;
                  removeEnd += itemSize;
                  animationVisible = true;
                }
                break;
              }

            case BoxItemTransitionState.invisible:
              {
                break;
              }
            case BoxItemTransitionState.disappear:
              if (removeEnd > scrollOffset + viewportSize &&
                  !item.animateOutside) {
                item.transitionStatus = BoxItemTransitionState.invisible;
              } else {
                end += itemSize;
                removeEnd += itemSize;
                animationVisible = true;
              }
              break;
            case BoxItemTransitionState.insertFront:
              {
                if (virtualOffset + insertEnd < viewportSize) {
                  insertEnd += itemSize;
                  newLengthToVisual++;
                } else {
                  item.transitionStatus = BoxItemTransitionState.insertLater;
                }
                animationVisible = true;

                debugPrint(
                    'Insert front after visual is dectected should not happen.');
                break;
              }
          }
          // debugPrint('count: $count ${item.transitionStatus}');
        }

        if (removed) {
          count--;
        } else {
          i++;
        }
      }
      return animationVisible;
    }

    if (modelsToEvaluate == null) {
      for (SingleBoxModel single in iterator()) {
        changeSliverProperties!.call(single.items, single.tag);
        changeModel(
            single: single,
            animation: evaluateList(
              list: single.items,
            ),
            sliverBoxAction: sliverBoxAction);
      }
    } else {
      for (SingleBoxModel single in iterator()) {
        int index = modelsToEvaluate
            .indexWhere((ChangeSingleModel c) => c.singleBoxModel == single);

        if (index != -1) {
          final changeSingleModel = modelsToEvaluate[index]
            ..changeSliverProperties();

          changeModel(
              single: single,
              animation:
                  evaluateList(list: changeSingleModel.singleBoxModel.items),
              sliverBoxAction: changeSingleModel.sliverBoxAction);

          modelsToEvaluate.removeAt(index);

          if (modelsToEvaluate.isEmpty &&
              end > scrollOffset + correct + viewportSize) {
            break;
          }
        } else {
          evaluateList(list: single.items);
        }
      }
    }

    animationAfterLayout = animateInsertDeleteAbove && correct != 0.0
        ? (correct < 0.0 ? 30 : -30)
        : 0.0;
  }

  void disposeSingleModel(SingleBoxModel singleBoxModel);

  void animationEnd() {
    cancelIgnorePointer();
    sliverBoxContext?.change();
  }

  void cancelIgnorePointer() {
    bool oneOrMoreAnimating = false;
    for (SingleBoxModel single in iterator()) {
      if (single.sliverBoxAction == SliverBoxAction.animate ||
          single.sliverBoxAction == SliverBoxAction.dispose) {
        oneOrMoreAnimating = true;
        break;
      }
    }
    if (!oneOrMoreAnimating) {
      setIgnorePointer(false);
    }
  }

  void dispose() {
    setIgnorePointer(false);

    for (SingleBoxModel single in iterator()) {
      single.dispose();
    }
    sliverBoxContext = null;
  }

  void setIgnorePointer(bool ignore) {
    sliverBoxContext?.widget.ignorePointerCallback?.call(ignore);
  }

  static void resetBoxProperties(List<BoxItemProperties> items) {
    items.removeWhere((element) {
      bool remove = false;
      switch (element.transitionStatus) {
        case BoxItemTransitionState.visible:
          break;
        case BoxItemTransitionState.appear:
        case BoxItemTransitionState.insertLater:
        case BoxItemTransitionState.insert:
        case BoxItemTransitionState.insertFront:
          element.transitionStatus = BoxItemTransitionState.visible;
          break;

        case BoxItemTransitionState.invisible:
          break;
        case BoxItemTransitionState.disappear:
          element.transitionStatus = BoxItemTransitionState.invisible;
          break;
        case BoxItemTransitionState.remove:
          remove = true;
          break;
      }
      return remove;
    });
  }

  FirstVisual? firstVisual() {
    FlexSizeRenderSliverList? r = sliverBoxContext?.context.findRenderObject()
        as FlexSizeRenderSliverList?;

    return r?.firstVisual;
  }

  void animateDelta(double delta) {
    final context = sliverBoxContext?.context;
    if (context != null) {
      final position = Scrollable.of(context).position;
      position.animateTo(position.pixels + delta,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // Animation for the correction can only be scheduled after the scrollOffsetCorrection with SliverGeometry is performed.
  // The scheduleCorrect is called in the layout.
  //
  //

  void scheduleAnimationAfterLayout() {
    final delta = animationAfterLayout;
    if (delta != 0.0) {
      scheduleMicrotask(() {
        animateDelta(delta);
      });
    }
    animationAfterLayout = 0.0;
  }
}

class SingleBoxModel<Tag, P extends BoxItemProperties> {
  Tag tag;
  SliverBoxAction sliverBoxAction;
  final List<P> items;
  List<P> visibleItems = [];
  int _individualTransition = 0;
  BuildStateItem<Tag, P>? buildStateItem;
  SliverBoxActivity _activity = const NoSliverBoxActivity();
  Duration? duration;

  setActivity(SliverBoxActivity activity) {
    _activity.dispose();
    _activity = activity;
  }

  set individualTransition(int value) {
    assert(_individualTransition >= 0,
        'Individual transition count $_individualTransition');
    _individualTransition = value;
  }

  int get individualTransition => _individualTransition;

  SingleBoxModel({
    required this.tag,
    this.sliverBoxAction = SliverBoxAction.none,
    required this.items,
    this.buildStateItem,
    this.duration,
  }) {
    evaluateVisibleItems();
  }

  bool get allowed => sliverBoxAction == SliverBoxAction.none;

  evaluateVisibleItems() {
    visibleItems = [
      for (var t in items)
        if (!(t.transitionStatus == BoxItemTransitionState.invisible ||
            t.transitionStatus == BoxItemTransitionState.insertLater))
          t
    ];
  }

  Widget build(
      {required BuildContext context,
      required AnimatedSliverBoxModel<Tag> model,
      required int index}) {
    return buildStateItem == null
        ? SizedBox(
            height: model.axis == Axis.vertical
                ? this.visibleItems[index].size(Axis.vertical)
                : null,
            width: model.axis == Axis.horizontal
                ? this.visibleItems[index].size(Axis.horizontal)
                : null,
            child: ErrorWidget(
                'Oops no build found, add a build directly or with the function updateSliverRowBoxModel!'))
        : buildStateItem!.call(
            buildContext: context,
            model: model,
            animation: _activity.animation,
            singleBoxModel: this,
            properties: this.visibleItems[index],
            index: index);
  }

  dispose() {
    if (_activity != const NoSliverBoxActivity()) {}
    setActivity(const NoSliverBoxActivity());
  }
}
