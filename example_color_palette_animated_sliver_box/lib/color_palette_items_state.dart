// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:animated_sliver_box/flex_size_sliver/flex_size_tracker.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'color_palette_items_model.dart';
import 'box_properties.dart';
import 'some_colors.dart';

final colorPaletteProvider =
    StateNotifierProvider<ResizableItemsNotifier, ColorPaletteListState>(
        (ref) => ResizableItemsNotifier(ColorPaletteListState()));

class ResizableItemsNotifier extends StateNotifier<ColorPaletteListState> {
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
      {required SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>
          single,
      required ColorPaletteItemSliverBoxProperties properties}) {
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

  void add({BoxItemProperties? properties}) {
    bool next = false;
    FirstVisual? firstVisual;
    if (properties == null) {
      firstVisual = state.sliverBoxController.tryModel?.firstVisual();

      final firstViewBoxProperties = firstVisual?.boxItemProperties;

      if (firstViewBoxProperties != null) {
        properties = firstViewBoxProperties;
        next = (firstVisual?.overflow ?? 0.0) > 0.0;
      }
    }
    state.sliverBoxController.feedBackTryModel((model) {
      for (SingleBoxModel single in model.singleModels) {
        final listIndex = properties == null
            ? 0
            : single.items.indexOf(properties) + (next ? 1 : 0);
        if (listIndex != -1) {
          final feedback = model.changeGroups(changeSingleBoxModels: [
            ChangeSingleModel(single, (list) {
              int itemIndex = state.itemIndex++;
              single.items.insert(
                  listIndex,
                  ColorPaletteItemSliverBoxProperties(
                      transitionStatus: listIndex == 0
                          ? BoxItemTransitionState.insertFront
                          : BoxItemTransitionState.insert,
                      id: '$itemIndex',
                      innerTransition: true,
                      panel: PanelSimpleItem.edit,
                      value: SimpleItem(
                          index: itemIndex,
                          colorName: ColorName(name: '', color: Colors.white)),
                      normalWidth: initialNormalWidth,
                      normalHeight: initialNormalHeight));
            }, SliverBoxAction.animate)
          ], checkAllGroups: false);

          if (firstVisual != null &&
              next &&
              feedback == SliverBoxRequestFeedBack.accepted) {
            //0.1 Show previous a little to insert after previous
            model.animateDelta(firstVisual.deltaOverlowToEnd - 0.1);
          }
          return feedback;
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

  void changeCenter() {
    state = state.copyWith(center: !state.center);
  }
}

class ColorPaletteListState {
  SliverBoxController<ColorPaletteSliverBoxModel> sliverBoxController;
  List<List<ColorPaletteItemSliverBoxProperties>> panelsList;
  int indexColorPanel;
  Axis axis;
  int itemIndex;
  bool visible;
  bool center;

  List<ColorPaletteItemSliverBoxProperties> get colorList =>
      panelsList[indexColorPanel];

  ColorPaletteListState(
      {SliverBoxController<ColorPaletteSliverBoxModel>? sliverBoxController,
      List<List<ColorPaletteItemSliverBoxProperties>>? sliverItemsList,
      Axis? axis,
      int? indexColorPanel,
      int? itemIndex,
      bool? visible,
      bool? center})
      : sliverBoxController = sliverBoxController ??
            SliverBoxController<ColorPaletteSliverBoxModel>(),
        panelsList = sliverItemsList ?? generateList(axis ?? Axis.vertical),
        axis = axis ?? Axis.vertical,
        indexColorPanel = indexColorPanel ?? 0,
        itemIndex = itemIndex ?? someColors.length,
        visible = visible ?? true,
        center = center ?? false;

  static List<List<ColorPaletteItemSliverBoxProperties>> generateList(
      Axis axis) {
    int pallets = someColors.length ~/ 50;

    return [
      for (int p = 0; p < pallets; p++)
        [
          for (int i = p * 50; i < (p * 50 + 50); i++)
            ColorPaletteItemSliverBoxProperties(
                panel: PanelSimpleItem.normal,
                id: '$i',
                value: SimpleItem(
                  index: i,
                  colorName: someColors[i],
                ),
                normalHeight: initialNormalHeight,
                normalWidth: initialNormalWidth)
        ],
      for (int p = 0; p < 5; p++)
        [
          for (int i = p * 3; i < 3 * p + 3; i++)
            ColorPaletteItemSliverBoxProperties(
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

  ColorPaletteListState copyWith({
    SliverBoxController<ColorPaletteSliverBoxModel>? sliverBoxController,
    List<List<ColorPaletteItemSliverBoxProperties>>? panelsList,
    Axis? axis,
    int? indexColorPanel,
    int? itemIndex,
    bool? visible,
    bool? center,
  }) {
    return ColorPaletteListState(
        sliverBoxController: sliverBoxController ?? this.sliverBoxController,
        sliverItemsList: panelsList ?? this.panelsList,
        axis: axis ?? this.axis,
        indexColorPanel: indexColorPanel ?? this.indexColorPanel,
        itemIndex: itemIndex ?? this.itemIndex,
        visible: visible ?? this.visible,
        center: center ?? this.center);
  }
}
