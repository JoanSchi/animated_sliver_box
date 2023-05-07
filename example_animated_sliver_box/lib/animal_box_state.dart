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

import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'package:animated_sliver_box/sliver_row_box_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'animal_az_list.dart';
import 'animal_sliver_box_properties.dart';
import 'animal_sliver_row_box_model.dart';

enum AnimalPanels { normal, edit }

final animalBoxProvider =
    StateNotifierProvider<AnimalBoxNotifier, AnimalBox>((ref) {
  return AnimalBoxNotifier();
});

class AnimalBoxNotifier extends StateNotifier<AnimalBox> {
  AnimalBoxNotifier() : super(AnimalBox.from(animalsFromAtoZ));

  List<String> selectedToRemove() {
    List<String> removed = [];
    final feedback = state.controllerSliverBox.feedBackTryModel((model) {
      return model.changeAnimal(change: (list) {
        for (var t in list) {
          if (t.value.selected) {
            t.transitionStatus = BoxItemTransitionState.remove;
            removed.add(t.value.name);
          }
        }
      });
    });

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state = state.copyWith();
    }
    return removed;
  }

  void insertList({
    required List<String> insert,
    Color color = const Color(0xFF80ba27),
  }) {
    final feedback = state.controllerSliverBox.feedBackTryModel((model) =>
        model.changeAnimal(change: (List<AnimalSliverBoxProperties> list) {
          list
            ..addAll([
              for (String name in insert)
                AnimalSliverBoxProperties(
                  id: '${name}_$color',
                  size: animalHeightNormal,
                  transitionStatus: BoxItemTransitionState.insert,
                  panel: AnimalPanels.normal,
                  value: AnimalBoxItem(name: name, color: color),
                )
            ])
            ..sort((a, b) {
              int c = a.value.name
                  .toLowerCase()
                  .compareTo(b.value.name.toLowerCase());

              if (c != 0) {
                return c;
              }
              return (a.value.color?.value ?? 0) - (b.value.color?.value ?? 0);
            });
        }));

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state = state.copyWith();
    }
  }

  void invertSelected() {
    final list = state.controllerSliverBox.tryModel?.animalListItems();

    if (list != null) {
      for (AnimalSliverBoxProperties state in list) {
        state.value.inverseSelected();
      }
      state = state.copyWith();
    }
  }

  void switchVisible() {
    final visible = !state.visible;
    final feedback = state.controllerSliverBox
        .feedBackTryModel((AnimalSliverBoxModel model) {
      if (visible) {
        return model.appear();
      } else {
        return model.disappear();
      }
    });

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state = state.copyWith(visible: visible);
    }
  }

  void insert(AnimalSliverBoxProperties item, {int index = -1}) {
    final SliverBoxRequestFeedBack feedback;
    if (item.single) {
      feedback = state.controllerSliverBox.feedBackTryModel((model) =>
          model.changeIndividualAnimal(
              evaluateVisibleItems: true,
              change: (list) =>
                  list.insert(index == -1 ? list.length : index, item)));
    } else {
      feedback = state.controllerSliverBox.feedBackTryModel((model) =>
          model.changeAnimal(
              change: (list) =>
                  list.insert(index == -1 ? list.length : index, item)));
    }

    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state = state.copyWith();
    } else {
      debugPrint('-----------------feedback: $feedback -----------------');
    }
  }

  void remove(BoxItemProperties item) {
    if (item.single) {
      state = state.copyWith();
    } else {
      final feedback = state.controllerSliverBox.feedBackTryModel((model) =>
          model.changeAnimal(
              change: (list) =>
                  item.transitionStatus = BoxItemTransitionState.remove));

      if (feedback == SliverBoxRequestFeedBack.accepted) {
        state = state.copyWith();
      } else {
        debugPrint('-----------------feedback: $feedback -----------------');
      }
    }
  }

  void update() {
    state = state.copyWith();
  }

  changeZoo(Set<String> selected) {
    String add;
    String remove;
    if (selected.contains('Emmen')) {
      add = 'Emmen';
      remove = 'Ouwehands';
    } else {
      add = 'Ouwehands';
      remove = 'Emmen';
    }
    state.controllerSliverBox.feedBackTryModel((AnimalSliverBoxModel model) {
      for (SingleBoxModel<String, AnimalSliverBoxProperties> single
          in model.animalBoxList) {
        //Feed list to dispose
        //
        if (single.sliverBoxAction != SliverBoxAction.dispose &&
            single.tag == remove) {
          final feedback = model.changeGroups(
            changeSingleBoxModels: [
              ChangeSingleModel(single, (list) {
                for (var p in list) {
                  p.transitionStatus = BoxItemTransitionState.disappear;
                }
              }, SliverBoxAction.dispose),
            ],
            checkAllGroups: false,
          );

          if (feedback != SliverBoxRequestFeedBack.accepted) {
            return feedback;
          }
        }
      }
      //New List
      //

      final addModel = SingleBoxModel<String, AnimalSliverBoxProperties>(
          tag: add,
          items: selected.contains('Emmen')
              ? state.animalBoxOne
              : state.animalBoxTwo);
      model.animalBoxList.insert(0, addModel);

      model.changeGroups(
        changeSingleBoxModels: [
          ChangeSingleModel(addModel, (list) {
            for (var p in list) {
              p.transitionStatus = BoxItemTransitionState.appear;
            }
          }, SliverBoxAction.appear)
        ],
        checkAllGroups: false,
      );

      return SliverBoxRequestFeedBack.accepted;
    });

    state = state.copyWith(selectedZoo: selected);
  }
}

class AnimalBox {
  SliverBoxController<AnimalSliverBoxModel> controllerSliverBox;
  List<AnimalSliverBoxProperties> animalBoxOne;
  List<AnimalSliverBoxProperties> animalBoxTwo;
  List<BoxItemProperties> topBox;
  List<BoxItemProperties> bottomBox;
  bool visible;
  Set<String> selectedZoo;

  AnimalBox(
      {required this.controllerSliverBox,
      required this.visible,
      required this.topBox,
      required this.animalBoxOne,
      required this.animalBoxTwo,
      required this.bottomBox,
      required this.selectedZoo});

  AnimalBox.from(List<String> names)
      : visible = true,
        topBox = [
          BoxItemProperties(
            id: 'top',
            size: animalTop,
          )
        ],
        bottomBox = [
          BoxItemProperties(
              id: 'bottom', size: animalBottom, animateOutside: true)
        ],
        animalBoxOne = itemsFromNames(names),
        animalBoxTwo = itemsFromNames(names,
            start: 2, end: 2, color: const Color.fromARGB(255, 180, 110, 6)),
        controllerSliverBox = SliverBoxController<AnimalSliverBoxModel>(),
        selectedZoo = {'Emmen'};

  static List<AnimalSliverBoxProperties> itemsFromNames(List<String> names,
      {int range = 6,
      int start = 0,
      end = 1,
      Color color = const Color.fromARGB(255, 138, 169, 75)}) {
    final length = animalsFromAtoZ.length;

    List<AnimalSliverBoxProperties> list = [];

    for (int i = 0; i < length; i++) {
      final o = i % range;
      if (start <= o && o <= end) {
        final a = AnimalBoxItem(name: animalsFromAtoZ[i], color: color);

        list.add(AnimalSliverBoxProperties(
          id: a.key,
          size: animalHeightNormal,
          value: a,
          panel: AnimalPanels.normal,
        ));
      }
    }
    return list;
  }

  AnimalBox copyWith({
    SliverBoxController<AnimalSliverBoxModel>? controllerSliverBox,
    List<BoxItemProperties>? topBox,
    List<AnimalSliverBoxProperties>? animalBoxOne,
    List<AnimalSliverBoxProperties>? animalBoxTwo,
    List<BoxItemProperties>? bottomBox,
    bool? visible,
    Set<String>? selectedZoo,
  }) {
    return AnimalBox(
      controllerSliverBox: controllerSliverBox ?? this.controllerSliverBox,
      topBox: topBox ?? this.topBox,
      animalBoxOne: animalBoxOne ?? this.animalBoxOne,
      animalBoxTwo: animalBoxTwo ?? this.animalBoxTwo,
      bottomBox: bottomBox ?? this.bottomBox,
      visible: visible ?? this.visible,
      selectedZoo: selectedZoo ?? this.selectedZoo,
    );
  }
}

class AnimalBoxItem {
  bool selected;
  Color? color;
  String name;

  AnimalBoxItem({
    this.color,
    required this.name,
    this.selected = false,
  });

  void inverseSelected() => selected = !selected;

  String get key => '${name}_$color';
}
