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
import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_background.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_transfer_widget.dart';
import 'package:animated_sliver_box/sliver_row_box_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../animal_box_state.dart';
import '../animal_sliver_box_properties.dart';
import '../animal_sliver_row_box_model.dart';
import 'animal_suggestion_state.dart';
import 'backdrop_state.dart';

const simpleColors = [
  Color(0xFFFFE15D),
  Color(0xFFF49D1A),
  Color(0xFFDC3535),
  Color(0xFFB01E68),
  Color(0xFF9EB23B),
  Color(0xFFC7D36F),
  Color(0xFFE0DECA),
  Color(0xFF22577E),
  Color(0xFF6E85B7),
  Color(0xFFB2C8DF),
  Color(0xFFC4D7E0),
  Color(0xFF9E7676),
  Color(0xFF815B5B),
  Color(0xFF594545),
  Color(0xFFE3C770),
  Color(0xFFFECD70),
  Color(0xFFFFAE6D),
  Color(0xFFF3E0B5),
];

class Back extends ConsumerStatefulWidget {
  const Back({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackState();
}

class _BackState extends ConsumerState<Back> {
  Color color = const Color(0xFFE3C770);
  @override
  Widget build(BuildContext context) {
    final a = ref.watch(animalSuggestionProvider);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.0),
                child: CustomScrollView(
                  slivers: [
                    AnimatedSliverBox<SuggestedAnimalSliverBoxModel>(
                      controllerSliverRowBox: a.sliverBoxController,
                      createSliverRowBoxModel: (sliverRowBoxContext) =>
                          SuggestedAnimalSliverBoxModel(
                              sliverBoxContext: sliverRowBoxContext,
                              suggestedAnimalBox: SingleBoxModel(
                                  tag: '',
                                  items: a.suggestedAnimalBox,
                                  buildStateItem: _build)),
                      updateSliverRowBoxModel:
                          (SuggestedAnimalSliverBoxModel model) {
                        model.suggestedAnimalBox.buildStateItem = _build;
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 64.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (Color color in simpleColors)
                      SizedBox(
                        width: 56.0,
                        height: 56.0,
                        child: Center(
                          child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: color,
                              shape: const CircleBorder(),
                              child: InkWell(
                                child: SizedBox(
                                    width: 48.0,
                                    height: 48.0,
                                    child: this.color == color
                                        ? const Icon(Icons.check)
                                        : null),
                                onTap: () {
                                  if (this.color != color) {
                                    setState(() {
                                      this.color = color;
                                    });
                                  }
                                },
                              )),
                        ),
                      )
                  ],
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(
                    child: SizedBox(
                  height: 0.0,
                )),
                const SizedBox(
                  width: 8.0,
                ),
                TextButton(
                  onPressed: () {
                    final removed = ref
                        .read(animalSuggestionProvider.notifier)
                        .selectedToRemove();

                    final backNotifier =
                        ref.read(dropBackdropProvider.notifier);

                    Timer(const Duration(milliseconds: 100), () {
                      backNotifier.state = false;
                    });

                    final animalNotifier = ref.read(animalBoxProvider.notifier);
                    Timer(const Duration(milliseconds: 300), () {
                      animalNotifier.insertList(insert: removed, color: color);
                    });
                  },
                  child: const Text('Insert'),
                )
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ));
  }

  Widget _build(
      {required BuildContext buildContext,
      Animation<double>? animation,
      required AnimatedSliverBoxModel model,
      required AnimalSuggestionSliverBoxProperties properties,
      required SingleBoxModel<String, AnimalSuggestionSliverBoxProperties>
          singleBoxModel,
      required int index}) {
    return SliverBoxBackground(
      key: Key('item_${properties.id}'),
      backgroundColor: const Color.fromARGB(255, 225, 236, 201),
      child: SliverBoxTransferWidget(
          key: Key('item_${properties.id}'),
          model: model,
          singleBoxModel: singleBoxModel,
          animation: animation,
          boxItemProperties: properties,
          child: Row(children: [
            const SizedBox(
              width: 8.0,
            ),
            Checkbox(
                value: properties.value.selected,
                onChanged: (bool? value) {
                  setState(() {
                    properties.value.selected = value!;
                  });
                }),
            const SizedBox(
              width: 8.0,
            ),
            Text(properties.value.name),
          ])),
    );
  }
}
