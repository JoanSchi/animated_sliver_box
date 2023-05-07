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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../animal_box_state.dart';
import 'animal_suggestion_state.dart';
import 'backdrop_state.dart';

class BackDropAppbar extends ConsumerStatefulWidget {
  const BackDropAppbar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<BackDropAppbar> {
  @override
  Widget build(BuildContext context) {
    bool down = ref.watch(dropBackdropProvider);

    return Stack(
      children: [
        Center(
          child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 200,
              ),
              child: down
                  ? const Text(
                      key: Key('insert'),
                      'Insert',
                      style: TextStyle(
                        fontSize: 24.0,
                      ))
                  : const Text(
                      key: Key('rsb'),
                      'A. SliverBox',
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    )),
        ),
        Positioned(
          left: 8.0,
          top: 8.0,
          bottom: 8.0,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                onPressed: () {
                  final drop = ref.read(dropBackdropProvider.notifier).state;
                  if (drop) {
                    ref
                        .read(animalSuggestionProvider.notifier)
                        .invertSelected();
                  } else {
                    ref.read(animalBoxProvider.notifier).invertSelected();
                  }
                },
                icon: const Icon(
                  Icons.published_with_changes,
                )),
            if (!down)
              IconButton(
                  onPressed: () {
                    ref.read(animalBoxProvider.notifier).switchVisible();
                  },
                  icon: const Icon(
                    Icons.visibility,
                  ))
          ]),
        ),
        Positioned(
          right: 8.0,
          top: 8.0,
          bottom: 8.0,
          child: down
              ? IconButton(
                  onPressed: () {
                    ref.read(dropBackdropProvider.notifier).state = false;
                  },
                  icon: const Icon(
                    Icons.close,
                  ))
              : Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          ref.read(dropBackdropProvider.notifier).state = true;
                        },
                        icon: const Icon(
                          Icons.add,
                        )),
                    IconButton(
                        onPressed: () {
                          List<String> removed = ref
                              .read(animalBoxProvider.notifier)
                              .selectedToRemove();

                          ref.read(animalSuggestionProvider.notifier).insert(
                                names: removed,
                              );
                        },
                        icon: const Icon(
                          Icons.delete,
                        ))
                  ],
                ),
        ),
      ],
    );
  }
}
