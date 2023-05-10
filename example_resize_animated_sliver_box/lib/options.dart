import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'resizable_items_state.dart';

class Options extends ConsumerStatefulWidget {
  const Options({
    super.key,
  });

  @override
  ConsumerState<Options> createState() => _AdjustItemSizeState();
}

class _AdjustItemSizeState extends ConsumerState<Options> {
  final TextEditingController _tecIndex = TextEditingController(text: '0');
  final TextEditingController _tecSize = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tecIndex.dispose();
    _tecSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resizableItemProvider);

    bool showUseSwipeOption = defaultTargetPlatform != TargetPlatform.android ||
        defaultTargetPlatform != TargetPlatform.iOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Color palette', textAlign: TextAlign.center),
        SizedBox(
          height: 72.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final selected = index == state.indexColorPanel;
                return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: selected
                        ? const CircleBorder()
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                    color: state.panelsList[index][0].value.colorName.color,
                    child: SizedBox(
                      height: 72.0,
                      width: 72.0,
                      child: InkWell(
                        onTap: selected
                            ? null
                            : () {
                                ref
                                    .read(resizableItemProvider.notifier)
                                    .replaceColorPanel(index);
                              },
                      ),
                    ));
              },
              itemCount: state.panelsList.length),
        ),
        Row(children: [
          const SizedBox(
            width: 16.0,
          ),
          // if (showUseSwipeOption)
          //   Checkbox(
          //       value: state.useSwipe,
          //       onChanged: (bool? value) {
          //         ref
          //             .read(resizableItemProvider.notifier)
          //             .changeUseSwipe(value ?? false);
          //       }),
          // if (showUseSwipeOption)
          //   const Text('Use swipe/fling instead of scrollbars'),
          // if (showUseSwipeOption)
          //   const SizedBox(
          //     width: 16.0,
          //   ),
          SizedBox(
              width: 100.0,
              child: TextField(
                controller: _tecIndex,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  label: Text('Index'),
                ),
              )),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(
              child: TextField(
            controller: _tecSize,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              label: Text('Size'),
            ),
          )),
          const SizedBox(
            width: 8.0,
          ),
          TextButton(onPressed: apply, child: const Text('Apply')),
          const SizedBox(
            width: 8.0,
          ),
        ]),
      ],
    );
  }

  void apply() {
    String feedback = ref.read(resizableItemProvider.notifier).changeHeight(
        index: int.tryParse(_tecIndex.text) ?? 0,
        size: double.tryParse(_tecSize.text) ?? 0.0);

    if (feedback.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(feedback)));
    }
  }
}
