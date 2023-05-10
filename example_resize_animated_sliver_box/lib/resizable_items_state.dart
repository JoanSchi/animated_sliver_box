// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'package:example_resize_animated_sliver_box/some_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'resizable_items_model.dart';
import 'box_properties.dart';

final resizableItemProvider =
    StateNotifierProvider<ResizableItemsNotifier, ResizableListState>(
        (ref) => ResizableItemsNotifier(ResizableListState()));

class ResizableItemsNotifier extends StateNotifier<ResizableListState> {
  ResizableItemsNotifier(super.state);

  String changeHeight({required int index, required double size}) {
    final length = state.panelsList.length;

    if (index < 0 || index >= length) {
      return 'Index $index outside range (0 - $length)';
    }
    state.panelsList[state.indexColorPanel][index]
        .setNormalSize(size: size, axis: state.axis);
    state = state.copyWith();
    return '';
  }

  void changedAxis() {
    final axis = state.axis == Axis.vertical ? Axis.horizontal : Axis.vertical;

    AnimatedSliverBoxModel.resetBoxProperties(
        state.panelsList[state.indexColorPanel]);

    state = state.copyWith(axis: axis);
  }

  void remove(
      {required SingleBoxModel<String, ResizableItemsSliverBoxProperties>
          single,
      required ResizableItemsSliverBoxProperties properties}) {
    state.sliverBoxController.feedBackTryModel((model) {
      return model.changeGroups(changeSingleBoxModels: [
        ChangeSingleModel(single, (list) {
          if (list.contains(properties)) {
            properties.transitionStatus = BoxItemTransitionState.remove;
          }
        }, SliverBoxAction.animate)
      ], checkAllGroups: false);
    });
    state = state.copyWith();
  }

  void add({required ResizableItemsSliverBoxProperties properties}) {
    state.sliverBoxController.feedBackTryModel((model) {
      for (SingleBoxModel single in model.singleModels) {
        final listIndex = single.items.indexOf(properties);
        if (listIndex != -1) {
          return model.changeGroups(changeSingleBoxModels: [
            ChangeSingleModel(single, (list) {
              int itemIndex = state.itemIndex++;
              single.items.insert(
                  listIndex,
                  ResizableItemsSliverBoxProperties(
                      transitionStatus: BoxItemTransitionState.insert,
                      id: '$itemIndex',
                      panel: PanelSimpleItem.edit,
                      value: SimpleItem(
                          index: itemIndex,
                          colorName: ColorName(name: '', color: Colors.white)),
                      normalWidth: initialNormalWidth,
                      normalHeight: initialNormalHeight));
            }, SliverBoxAction.animate)
          ], checkAllGroups: false);
        }
      }
      return SliverBoxRequestFeedBack.error;
    });

    state = state.copyWith();
  }

  void replaceColorPanel(int index) {
    state.sliverBoxController.feedBackTryModel((model) {
      // Wrap in model
      //

      final suggestedPanel = state.panelsList[index];

      for (var single in model.singleModels) {
        if (single.items == suggestedPanel) {
          return SliverBoxRequestFeedBack.nothingToDo;
        }
      }
      final single =
          SingleBoxModel(tag: 'panel_$index', items: state.panelsList[index]);

      var feedback = model.changeGroups(
          animateInsertDeleteAbove: false,
          changeSingleBoxModels: [
            ChangeSingleModel(single, (list) {
              for (var properties in list) {
                properties.transitionStatus =
                    BoxItemTransitionState.insertFront;
              }
            }, SliverBoxAction.appear),
            for (var single in model.singleModels)
              ChangeSingleModel(single, (list) {
                for (var property in list) {
                  if (property.transitionStatus !=
                      BoxItemTransitionState.invisible) {
                    property.transitionStatus =
                        BoxItemTransitionState.disappear;
                  }
                }
              }, SliverBoxAction.dispose)
          ],
          checkAllGroups: false,
          insertModel: () {
            model.singleModels.insert(0, single);
          });

      if (feedback == SliverBoxRequestFeedBack.accepted ||
          feedback == SliverBoxRequestFeedBack.noModel) {}
      return feedback;
    });

    state = state.copyWith(indexColorPanel: index, visible: true);
  }

  void changeVisibility() {
    final visible = !state.visible;

    final feedback = state.sliverBoxController.feedBackTryModel((model) {
      return visible ? model.appear() : model.disappear();
    });

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state = state.copyWith(visible: visible);
    }
  }

  void changeUseSwipe(bool value) {
    state = state.copyWith(useSwipe: value);
  }
}

class ResizableListState {
  SliverBoxController<ResizableItemsSliverBoxModel> sliverBoxController;
  List<List<ResizableItemsSliverBoxProperties>> panelsList;
  int indexColorPanel;
  Axis axis;
  int itemIndex;
  bool visible;
  bool useSwipe;

  List<ResizableItemsSliverBoxProperties> get colorList =>
      panelsList[indexColorPanel];

  ResizableListState(
      {SliverBoxController<ResizableItemsSliverBoxModel>? sliverBoxController,
      List<List<ResizableItemsSliverBoxProperties>>? sliverItemsList,
      Axis? axis,
      int? indexColorPanel,
      int? itemIndex,
      bool? visible,
      bool? useSwipe})
      : sliverBoxController = sliverBoxController ??
            SliverBoxController<ResizableItemsSliverBoxModel>(),
        panelsList = sliverItemsList ?? generateList(axis ?? Axis.vertical),
        axis = axis ?? Axis.vertical,
        indexColorPanel = indexColorPanel ?? 0,
        itemIndex = itemIndex ?? someColors.length,
        visible = visible ?? true,
        useSwipe = useSwipe ?? false;

  static List<List<ResizableItemsSliverBoxProperties>> generateList(Axis axis) {
    int pallets = someColors.length ~/ 50;
    return [
      for (int p = 0; p < pallets; p++)
        [
          for (int i = p * 50; i < (p * 50 + 50); i++)
            ResizableItemsSliverBoxProperties(
                panel: PanelSimpleItem.normal,
                id: '$i',
                value: SimpleItem(
                  index: i,
                  colorName: someColors[i],
                ),
                normalHeight: initialNormalHeight,
                normalWidth: initialNormalWidth)
        ]
    ];
  }

  ResizableListState copyWith({
    SliverBoxController<ResizableItemsSliverBoxModel>? sliverBoxController,
    List<List<ResizableItemsSliverBoxProperties>>? panelsList,
    Axis? axis,
    int? indexColorPanel,
    int? itemIndex,
    bool? visible,
    bool? useSwipe,
  }) {
    return ResizableListState(
        sliverBoxController: sliverBoxController ?? this.sliverBoxController,
        sliverItemsList: panelsList ?? this.panelsList,
        axis: axis ?? this.axis,
        indexColorPanel: indexColorPanel ?? this.indexColorPanel,
        itemIndex: itemIndex ?? this.itemIndex,
        visible: visible ?? this.visible,
        useSwipe: useSwipe ?? this.useSwipe);
  }
}
