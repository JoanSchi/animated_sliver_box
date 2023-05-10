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
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:animated_sliver_box/sliver_box_controller.dart';
import 'animal_sliver_properties.dart';

class AnimalSliverBoxModel extends AnimatedSliverBoxModel<String> {
  AnimalSliverBoxModel(
      {required super.sliverBoxContext,
      required this.topBox,
      required this.animalBoxList,
      required this.bottomBox,
      required super.axis,
      required super.duration});
  SingleBoxModel<String, BoxItemProperties> topBox;
  List<SingleBoxModel<String, AnimalSliverBoxProperties>> animalBoxList;
  SingleBoxModel<String, BoxItemProperties> bottomBox;

  @override
  Iterable<SingleBoxModel> iterator() sync* {
    yield topBox;
    for (SingleBoxModel singleBoxModel in animalBoxList) {
      yield singleBoxModel;
    }
    yield bottomBox;
  }

  List<AnimalSliverBoxProperties> animalListItems() {
    int count = 0;
    SingleBoxModel<String, AnimalSliverBoxProperties>? singleBoxModel;

    for (SingleBoxModel<String, AnimalSliverBoxProperties> single
        in animalBoxList) {
      if (single.sliverBoxAction != SliverBoxAction.dispose) {
        count++;
        singleBoxModel = single;
      }
    }
    assert(count < 2, 'There are more singleModels which are not disposed!');

    return singleBoxModel?.items ?? [];
  }

  SliverBoxRequestFeedBack changeAnimal(
      {required Function(List<AnimalSliverBoxProperties>) change,
      sliverBoxAction = SliverBoxAction.animate}) {
    final list = animalBoxList
        .where((single) => single.sliverBoxAction != SliverBoxAction.dispose);

    if (list.length == 1) {
      return changeGroups(changeSingleBoxModels: [
        ChangeSingleModel<String, AnimalSliverBoxProperties>(
            list.first, change, sliverBoxAction)
      ], checkAllGroups: false);
    }
    return SliverBoxRequestFeedBack.error;
  }

  SliverBoxRequestFeedBack changeIndividualAnimal(
      {required Function(List<BoxItemProperties>) change,
      required bool evaluateVisibleItems}) {
    final list = animalBoxList
        .where((single) => single.sliverBoxAction != SliverBoxAction.dispose);

    if (list.length == 1) {
      return changeIndividual(
          singleBoxModel: list.first,
          change: change,
          evaluateVisibleItems: evaluateVisibleItems);
    }
    return SliverBoxRequestFeedBack.error;
  }

  @override
  void disposeSingleModel(SingleBoxModel singleBoxModel) {
    animalBoxList.remove(singleBoxModel);
  }

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    // final length =
    //     animalBoxList.fold(0, (value, element) => value + element.items.length);
    // // int count = 0;

    // if(length < 20){
    //   count++;
    // }else{
    //   if(lastIndex < 1){

    //   }else if(animalBoxList.fold(0.0, (0.0, element) => element.items.length));
    // }
    return trailingScrollOffset + (length - lastIndex - 1) * animalHeightNormal;
  }
}

class SuggestedAnimalSliverBoxModel extends AnimatedSliverBoxModel<String> {
  SuggestedAnimalSliverBoxModel({
    required super.sliverBoxContext,
    required this.suggestedAnimalBox,
    required super.axis,
    required super.duration,
  });

  SingleBoxModel<String, AnimalSuggestionSliverBoxProperties>
      suggestedAnimalBox;

  @override
  Iterable<SingleBoxModel> iterator() sync* {
    yield suggestedAnimalBox;
  }

  SliverBoxRequestFeedBack changeAnimal(
      {required Function(List<AnimalSuggestionSliverBoxProperties>) change,
      sliverBoxAction = SliverBoxAction.animate}) {
    return changeGroups(changeSingleBoxModels: [
      ChangeSingleModel<String, AnimalSuggestionSliverBoxProperties>(
          suggestedAnimalBox, change, sliverBoxAction)
    ], checkAllGroups: false);
  }

  SliverBoxRequestFeedBack changeIndividualAnimal(
      {required Function(List<BoxItemProperties>) change,
      required bool evaluateVisibleItems}) {
    return changeIndividual(
        singleBoxModel: suggestedAnimalBox,
        change: change,
        evaluateVisibleItems: evaluateVisibleItems);
  }

  @override
  void disposeSingleModel(SingleBoxModel singleBoxModel) {}

  @override
  BoxItemProperties getProperties(int index) {
    return suggestedAnimalBox.visibleItems[index];
  }

  @override
  int get length => suggestedAnimalBox.visibleItems.length;
}
