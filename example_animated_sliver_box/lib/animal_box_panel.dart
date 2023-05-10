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
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_background.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_resize_switcher.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_transfer_widget.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'animal_box_state.dart';
import 'animal_sliver_properties.dart';
import 'animal_sliver_box_model.dart';
import 'backdrop/animal_suggestion_state.dart';

class AnimalsAtoZ extends ConsumerStatefulWidget {
  const AnimalsAtoZ({super.key});

  @override
  ConsumerState<AnimalsAtoZ> createState() => _AnimalsAtoZState();
}

class _AnimalsAtoZState extends ConsumerState<AnimalsAtoZ> {
  int newAnimal = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final animalBox = ref.watch(animalBoxProvider);

    return AnimatedSliverBox<AnimalSliverBoxModel>(
        controllerSliverRowBox: animalBox.controllerSliverBox,
        createSliverRowBoxModel: createModel(animalBox),
        updateSliverRowBoxModel: (AnimalSliverBoxModel model, Axis axis) {
          model
            ..topBox.buildStateItem = _buildTop
            ..bottomBox.buildStateItem = _buildBottom
            ..axis = axis;

          for (var element in model.animalBoxList) {
            element.buildStateItem = _buildAnimal;
          }
        });
  }

  CreateSliverRowBoxModel<AnimalSliverBoxModel> createModel(
          AnimalBox animalBox) =>
      (AnimatedSliverBoxState<AnimalSliverBoxModel> sliverBoxContext,
              Axis axis) =>
          AnimalSliverBoxModel(
              duration: const Duration(milliseconds: 500),
              sliverBoxContext: sliverBoxContext,
              topBox: SingleBoxModel<String, BoxItemProperties>(
                  tag: 'top',
                  items: animalBox.topBox,
                  buildStateItem: _buildTop),
              bottomBox: SingleBoxModel<String, BoxItemProperties>(
                tag: 'bottom',
                items: animalBox.bottomBox,
                buildStateItem: _buildBottom,
              ),
              animalBoxList: [
                SingleBoxModel<String, AnimalSliverBoxProperties>(
                    duration: const Duration(milliseconds: 500),
                    tag: animalBox.selectedZoo.contains('Emmen')
                        ? 'Emmen'
                        : 'Ouwehands',
                    items: animalBox.selectedZoo.contains('Emmen')
                        ? animalBox.animalBoxOne
                        : animalBox.animalBoxTwo,
                    buildStateItem: _buildAnimal)
              ],
              axis: axis);

  Widget _buildTop(
      {required BuildContext buildContext,
      Animation<double>? animation,
      required AnimatedSliverBoxModel model,
      required BoxItemProperties properties,
      required SingleBoxModel<String, BoxItemProperties> singleBoxModel,
      required int index}) {
    return SliverBoxBackground(
        key: Key(properties.id),
        radialTop: 36.0,
        backgroundColor: const Color.fromARGB(255, 247, 250, 241),
        child: SliverBoxTransferWidget(
            key: Key(properties.id),
            animation: animation,
            boxItemProperties: properties,
            model: model,
            singleBoxModel: singleBoxModel,
            child: SizedBox(
                height: animalTop,
                child: Column(children: [
                  const SizedBox(height: 8.0),
                  const Text(
                    'Zoo',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  const SizedBox(height: 8.0),
                  SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                          value: 'Emmen',
                          label: Text('Emmen'),
                          icon: Icon(Icons.place)),
                      ButtonSegment<String>(
                          value: 'Ouwehands',
                          label: Text('Ouwehands'),
                          icon: Icon(Icons.place)),
                    ],
                    selected: ref.read(animalBoxProvider).selectedZoo,
                    onSelectionChanged: (Set<String> newSelection) {
                      ref
                          .read(animalBoxProvider.notifier)
                          .changeZoo(newSelection);
                    },
                  )
                ]))));
  }

  Widget _buildBottom(
      {required BuildContext buildContext,
      Animation<double>? animation,
      required AnimatedSliverBoxModel<String> model,
      required BoxItemProperties properties,
      required SingleBoxModel<String, BoxItemProperties> singleBoxModel,
      required int index}) {
    return SliverBoxBackground(
        key: Key(properties.id),
        radialbottom: 36.0,
        backgroundColor: const Color.fromARGB(255, 247, 250, 241),
        child: SliverBoxTransferWidget(
            key: Key(properties.id),
            animation: animation,
            boxItemProperties: properties,
            model: model,
            singleBoxModel: singleBoxModel,
            child: SizedBox(
              height: animalBottom,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Material(
                    color: const Color.fromARGB(255, 103, 134, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0)),
                    child: InkWell(
                      onTap: add,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Add',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }

  Widget _buildAnimal(
      {required BuildContext buildContext,
      Animation<double>? animation,
      required AnimatedSliverBoxModel<String> model,
      required AnimalSliverBoxProperties properties,
      required SingleBoxModel<String, AnimalSliverBoxProperties> singleBoxModel,
      required int index}) {
    Widget child;
    //
    //
    //
    //

    if (properties.toPanel != null) {
      child = SliverBoxResizeAbSwitcher(
        first: Animal(
          properties: properties,
          changeSelection: (value) {
            setState(() {
              properties.value.selected = value!;
            });
          },
          changePanel: () {
            setState(() {
              properties.toPanel = AnimalPanels.edit;
            });
          },
        ),
        // first: EditAnimal(properties: properties),
        second: EditAnimal(
          properties: properties,
          actionCallBack: (ActionEdit action) =>
              _action(action, index, properties),
        ),
        stateChange: () {
          properties.fixPanel();
        },

        crossFadeState: properties.toPanel! == AnimalPanels.normal
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      );
    } else if (properties.panel == AnimalPanels.normal) {
      child = Animal(
          properties: properties,
          changeSelection: (value) {
            setState(() {
              properties.value.selected = value!;
            });
          },
          changePanel: () {
            setState(() {
              properties.setToPanel(AnimalPanels.edit);
            });
          });
    } else {
      child = EditAnimal(
        properties: properties,
        actionCallBack: (ActionEdit action) =>
            _action(action, index, properties),
      );
    }

    return SliverBoxBackground(
      key: Key(properties.id),
      backgroundColor: const Color.fromARGB(255, 247, 250, 241),
      child: SliverBoxTransferWidget(
        key: Key('item_${properties.id}'),
        model: model,
        boxItemProperties: properties,
        animation: animation,
        singleBoxModel: singleBoxModel,
        child: child,
      ),
    );
  }

  void _action(
      ActionEdit action, int index, AnimalSliverBoxProperties properties) {
    switch (action) {
      case ActionEdit.add:
        add(index: index);
        break;
      case ActionEdit.remove:
        remove(properties);
        break;
      case ActionEdit.close:
        setState(() {
          properties.setToPanel(AnimalPanels.normal);
        });
        break;
    }
  }

  void add({int index = -1}) {
    ref.read(animalBoxProvider.notifier).insert(
        AnimalSliverBoxProperties(
          id: 'newAnimal_${newAnimal++}',
          panel: AnimalPanels.normal,
          toPanel: AnimalPanels.edit,
          single: false,
          transitionStatus: BoxItemTransitionState.insert,
          value: AnimalBoxItem(
              name: '',
              color: index == -1
                  ? const Color(0xFFE3C770)
                  : const Color(0xFFFFE1E1)),
        ),
        index: index);
  }

  void remove(AnimalSliverBoxProperties properties) {
    ref.read(animalBoxProvider.notifier).remove(properties
      ..single = true
      ..transitionStatus = BoxItemTransitionState.remove);

    ref
        .read(animalSuggestionProvider.notifier)
        .insert(names: [properties.value.name]);
  }
}

enum ActionEdit {
  add,
  remove,
  close,
}

class Animal extends StatelessWidget {
  final AnimalSliverBoxProperties properties;
  final VoidCallback changePanel;
  final ValueChanged<bool?> changeSelection;
  const Animal(
      {super.key,
      required this.changePanel,
      required this.properties,
      required this.changeSelection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = properties.value.name.isEmpty;
    return SizedBox(
        height: animalHeightNormal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 8.0,
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                    color: properties.value.color,
                    shape: const CircleBorder(),
                    child: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.black;
                        }
                        return Colors.white;
                      }),
                      checkColor: properties.value.color,
                      shape: const CircleBorder(),
                      value: properties.value.selected,
                      onChanged: changeSelection,
                    ))),
            Expanded(
                child: Text(
              empty ? 'Empty' : properties.value.name,
              style: TextStyle(
                  fontSize: 18.0,
                  color: empty ? theme.colorScheme.error : null),
            )),
            IconButton(
                onPressed: changePanel, icon: const Icon(Icons.expand_more))
          ],
        ));
  }
}

class EditAnimal extends ConsumerStatefulWidget {
  final AnimalSliverBoxProperties properties;
  final Function(ActionEdit action) actionCallBack;

  const EditAnimal({
    super.key,
    required this.properties,
    required this.actionCallBack,
  });

  @override
  ConsumerState<EditAnimal> createState() => _EditAnimalState();
}

class _EditAnimalState extends ConsumerState<EditAnimal> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.properties.value.name);

  @override
  void dispose() {
    widget.properties.value.name = _textEditingController.text;
    _textEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: animalHeightEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Material(
          color: const Color.fromARGB(255, 162, 191, 103),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(36.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () =>
                            widget.actionCallBack(ActionEdit.remove),
                        icon: const Icon(Icons.delete)),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    IconButton(
                        onPressed: () => widget.actionCallBack(ActionEdit.add),
                        icon: const Icon(Icons.add)),
                    IconButton(
                        onPressed: () =>
                            widget.actionCallBack(ActionEdit.close),
                        icon: const Icon(Icons.close))
                  ],
                ),
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0))),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Material(
                                    color: widget.properties.value.color,
                                    shape: const CircleBorder(),
                                    child: Checkbox(
                                      fillColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors.black;
                                        }
                                        return Colors.white;
                                      }),
                                      checkColor: widget.properties.value.color,
                                      shape: const CircleBorder(),
                                      value: widget.properties.value.selected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          widget.properties.value.selected =
                                              value ?? false;
                                        });
                                      },
                                    )),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Image.asset('graphics/vis.png')),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Material(
                                          color: widget.properties.value.color,
                                          shape: const CircleBorder(),
                                          child: const SizedBox(
                                            height: 24.0,
                                            width: 24.0,
                                          )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ))),
                Row(
                  children: [
                    const SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        onSubmitted: (String? value) {
                          if (widget.properties.collapseAfterEditing) {
                            widget.properties.setToPanel(AnimalPanels.normal);
                          }
                          widget.properties.value.name = value ?? '';
                          ref.read(animalBoxProvider.notifier).update();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                            value: widget.properties.aliveOutsideView,
                            onChanged: (bool? value) {
                              setState(() {
                                widget.properties.aliveOutsideView =
                                    value ?? false;
                              });
                            }),
                        const Text('Keep alive'),
                        Checkbox(
                            value: widget.properties.collapseAfterEditing,
                            onChanged: (bool? value) {
                              setState(() {
                                widget.properties.collapseAfterEditing =
                                    value ?? false;
                              });
                            }),
                        const Text('Collapse after editing'),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
