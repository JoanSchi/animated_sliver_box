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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_sliver_box/animated_sliver_box.dart';

import 'animal_box_state.dart';
import 'backdrop/animal_suggestion_state.dart';

const animalHeightNormal = 64.0;
const animalHeightEdit = 460.0;
const animalTop = 128.0;
const animalBottom = 64.0;

const animalHeightSuggestion = 64.0;

class AnimalSliverBoxProperties extends BoxItemProperties {
  AnimalPanels panel;
  AnimalPanels? toPanel;
  AnimalBoxItem value;
  bool aliveOutsideView;
  bool collapseAfterEditing;

  AnimalSliverBoxProperties(
      {super.transitionStatus = BoxItemTransitionState.visible,
      required super.id,
      required super.size,
      required this.panel,
      this.toPanel,
      super.single = false,
      required this.value,
      this.aliveOutsideView = false,
      this.collapseAfterEditing = false});

  fixPanel() {
    final to = toPanel;
    if (to == null) {
      return;
    }
    toPanel = null;
    panel = to;
    innerTransition = false;
    if (panel == AnimalPanels.normal) {
      size = animalHeightNormal;
    } else {
      size = animalHeightEdit;
    }
  }

  setToPanel(AnimalPanels? panel) {
    toPanel = panel;

    if (panel == null) {
      innerTransition = false;
    } else {
      innerTransition = true;
    }
  }

  String idKey() {
    return 'animal_${id}_$panel';
  }

  @override
  void garbageCollected() {
    if (aliveOutsideView) return;

    panel = AnimalPanels.normal;
    toPanel = null;
    innerTransition = false;
    size = animalHeightNormal;
  }
}

class AnimalSuggestionSliverBoxProperties extends BoxItemProperties {
  AnimalSuggestionItem value;

  AnimalSuggestionSliverBoxProperties({
    super.transitionStatus = BoxItemTransitionState.visible,
    required super.id,
    required super.size,
    required this.value,
  });
}
