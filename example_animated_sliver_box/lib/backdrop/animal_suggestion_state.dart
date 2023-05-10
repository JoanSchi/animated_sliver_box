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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animal_az_list.dart';
import '../animal_sliver_properties.dart';
import '../animal_sliver_box_model.dart';

final animalSuggestionProvider =
    StateNotifierProvider<AnimalSuggestionNotifier, AnimalSuggestion>((ref) {
  return AnimalSuggestionNotifier();
});

class AnimalSuggestionNotifier extends StateNotifier<AnimalSuggestion> {
  AnimalSuggestionNotifier() : super(AnimalSuggestion.from(animalsFromAtoZ));

  void invertSelected() {
    final list = state.sliverBoxController.tryModel?.suggestedAnimalBox.items;
    if (list != null) {
      for (AnimalSuggestionSliverBoxProperties suggested in list) {
        suggested.value.inverseSelected();
      }
      state = state.copyWith();
    }
  }

  void insert({required List<String> names}) {
    final animals = [
      for (String name in names)
        AnimalSuggestionSliverBoxProperties(
            id: name,
            size: animalHeightSuggestion,
            transitionStatus: BoxItemTransitionState.insert,
            value: AnimalSuggestionItem(name: name))
    ];

    state = state.copyWith(
        suggestedAnimalBox: state.suggestedAnimalBox
          ..addAll(animals)
          ..sort((a, b) {
            return a.value.name
                .toLowerCase()
                .compareTo(b.value.name.toLowerCase());
          }));
  }

  List<String> selectedToRemove() {
    List<String> removed = [];

    final feedback = state.sliverBoxController
        .feedBackTryModel((SuggestedAnimalSliverBoxModel model) {
      return model.changeAnimal(change: (List<BoxItemProperties> list) {
        for (var t in model.suggestedAnimalBox.items) {
          if (t.value.selected) {
            t.transitionStatus = BoxItemTransitionState.remove;
            removed.add(t.value.name);
          }
        }
      });
    });
    if (feedback == SliverBoxRequestFeedBack.accepted) {
      state.copyWith();
    }
    return removed;
  }

  update() {
    state = state.copyWith();
  }
}

class AnimalSuggestion {
  SliverBoxController<SuggestedAnimalSliverBoxModel> sliverBoxController;

  List<AnimalSuggestionSliverBoxProperties> suggestedAnimalBox;

  AnimalSuggestion({
    required this.sliverBoxController,
    required this.suggestedAnimalBox,
  });

  AnimalSuggestion.from(List<String> names)
      : sliverBoxController = SliverBoxController(),
        suggestedAnimalBox = suggestionList(names);

  static List<AnimalSuggestionSliverBoxProperties> suggestionList(
      List<String> names) {
    List<AnimalSuggestionSliverBoxProperties> list = [];
    for (int i = 0; i < names.length; i++) {
      if (!(i % 6 < 2)) {
        final a = AnimalSuggestionItem(name: names[i]);
        list.add(AnimalSuggestionSliverBoxProperties(
          id: a.name,
          size: animalHeightSuggestion,
          transitionStatus: BoxItemTransitionState.visible,
          value: a,
        ));
      }
    }
    return list;
  }

  AnimalSuggestion copyWith({
    SliverBoxController<SuggestedAnimalSliverBoxModel>? sliverBoxController,
    List<AnimalSuggestionSliverBoxProperties>? suggestedAnimalBox,
  }) {
    return AnimalSuggestion(
      sliverBoxController: sliverBoxController ?? this.sliverBoxController,
      suggestedAnimalBox: suggestedAnimalBox ?? this.suggestedAnimalBox,
    );
  }
}

class AnimalSuggestionItem {
  bool selected;
  String name;

  void inverseSelected() => selected = !selected;

  AnimalSuggestionItem({
    required this.name,
    this.selected = false,
  });
}
