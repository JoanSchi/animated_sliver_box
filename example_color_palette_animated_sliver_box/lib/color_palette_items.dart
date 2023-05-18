import 'package:animated_sliver_box/animated_sliver_box.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_resize_switcher.dart';
import 'package:animated_sliver_box/animated_sliver_box_goodies/sliver_box_transfer_widget.dart';
import 'package:animated_sliver_box/animated_sliver_box_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'box_properties.dart';
import 'color_palette_items_model.dart';
import 'color_palette_items_state.dart';

class ResizableItemsList extends ConsumerStatefulWidget {
  final Axis axis;
  const ResizableItemsList({super.key, required this.axis});

  @override
  ConsumerState<ResizableItemsList> createState() => _ResisableItemsListState();
}

class _ResisableItemsListState extends ConsumerState<ResizableItemsList> {
  @override
  Widget build(BuildContext context) {
    ColorPaletteListState colorPaletteListState =
        ref.watch(colorPaletteProvider);

    return AnimatedSliverBox<ColorPaletteSliverBoxModel>(
      axis: colorPaletteListState.axis,
      controllerSliverRowBox: colorPaletteListState.sliverBoxController,
      createSliverRowBoxModel:
          (AnimatedSliverBoxState<ColorPaletteSliverBoxModel> sliverBoxContext,
              Axis axis) {
        return ColorPaletteSliverBoxModel(
            duration: const Duration(milliseconds: 500),
            axis: axis,
            sliverBoxContext: sliverBoxContext,
            singleModel:
                SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>(
                    tag: 'test',
                    items: colorPaletteListState.colorList,
                    buildStateItem: _build));
      },
      updateSliverRowBoxModel: ((model, Axis axis) {
        model.axis = axis;

        for (SingleBoxModel<String, ColorPaletteItemSliverBoxProperties> single
            in model.singleModels) {
          single.buildStateItem = _build;
        }
      }),
    );
  }

  Widget _build(
      {required BuildContext buildContext,
      Animation<double>? animation,
      required AnimatedSliverBoxModel<String> model,
      required ColorPaletteItemSliverBoxProperties properties,
      required SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>
          singleBoxModel,
      required int index}) {
    Widget child;

    if (properties.toPanel != null) {
      child = Transfer(
        actionCallBack: (action) => actionEdit(
            action: action, single: singleBoxModel, properties: properties),
        key: Key(properties.id),
        properties: properties,
        axis: widget.axis,
      );
    } else {
      properties.innerTransition = false;
      switch (properties.panel) {
        case PanelSimpleItem.normal:
          child = Normal(
            key: Key(properties.id),
            axis: widget.axis,
            properties: properties,
            change: () {
              setState(() {
                properties.setToPanel(
                  PanelSimpleItem.edit,
                );
              });
            },
          );
          break;
        case PanelSimpleItem.edit:
          child = Edit(
            actionCallBack: (action) => actionEdit(
                action: action, single: singleBoxModel, properties: properties),
            key: Key(properties.id),
            axis: widget.axis,
            properties: properties,
            change: () {
              setState(() {
                properties.setToPanel(
                  PanelSimpleItem.normal,
                );
              });
            },
          );
          break;
      }
    }

    return SliverBoxTransferWidget(
        animation: animation,
        model: model,
        boxItemProperties: properties,
        key: Key(properties.id),
        singleBoxModel: singleBoxModel,
        child: child);
  }

  void actionEdit(
      {required ActionEdit action,
      required SingleBoxModel<String, ColorPaletteItemSliverBoxProperties>
          single,
      required ColorPaletteItemSliverBoxProperties properties}) {
    switch (action) {
      case ActionEdit.add:
        ref.read(colorPaletteProvider.notifier).add(properties: properties);
        break;
      case ActionEdit.remove:
        ref
            .read(colorPaletteProvider.notifier)
            .remove(single: single, properties: properties);
        break;
      case ActionEdit.close:
        setState(() {
          properties.setToPanel(PanelSimpleItem.normal);
        });

        break;
    }
  }
}

class Normal extends StatelessWidget {
  final VoidCallback change;
  final ColorPaletteItemSliverBoxProperties properties;
  final Axis axis;

  const Normal({
    super.key,
    required this.properties,
    required this.change,
    required this.axis,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: change,
      child: SizedBox(
        width: axis == Axis.horizontal ? properties.normalWidth : null,
        height:
            axis == Axis.vertical ? properties.normalHeight : horizontalHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: properties.value.colorName.color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      '${properties.value.index}: ${properties.value.colorName.name}',
                      style: const TextStyle(fontSize: 20.0)),
                ],
              )),
        ),
      ),
    );
  }
}

class Transfer extends StatefulWidget {
  final ColorPaletteItemSliverBoxProperties properties;
  final Axis axis;
  final Function(ActionEdit action) actionCallBack;
  const Transfer(
      {super.key,
      required this.properties,
      required this.axis,
      required this.actionCallBack});

  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    crossFadeState = widget.properties.toPanel == PanelSimpleItem.normal
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Transfer oldWidget) {
    crossFadeState = widget.properties.toPanel == PanelSimpleItem.normal
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.properties.innerTransition = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverBoxResizeAbSwitcher(
      first: Normal(
        axis: widget.axis,
        properties: widget.properties,
        change: () => changeState(PanelSimpleItem.edit, widget.axis),
      ),
      second: Edit(
        actionCallBack: widget.actionCallBack,
        change: () => changeState(
          PanelSimpleItem.normal,
          widget.axis,
        ),
        axis: widget.axis,
        properties: widget.properties,
      ),
      stateChange: () {
        widget.properties.fixPanel();
      },
      crossFadeState: crossFadeState,
    );
  }

  void changeState(PanelSimpleItem panel, Axis axis) {
    setState(() {
      widget.properties.setToPanel(
        panel,
      );

      crossFadeState = crossFadeState == CrossFadeState.showFirst
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst;
    });
  }
}

enum ActionEdit {
  add,
  remove,
  close,
}

class Edit extends StatefulWidget {
  final VoidCallback change;
  final Axis axis;
  final ColorPaletteItemSliverBoxProperties properties;
  final Function(ActionEdit action) actionCallBack;

  const Edit(
      {super.key,
      required this.change,
      required this.axis,
      required this.properties,
      required this.actionCallBack});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  late final TextEditingController _textEditingController;
  late Map<ColorSwatch<Object>, String> heavyColorSwap;

  @override
  void initState() {
    heavyColorSwap = {
      ColorTools.createPrimarySwatch(widget.properties.value.colorName.color):
          'heavy'
    };
    _textEditingController =
        TextEditingController(text: widget.properties.value.colorName.name);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget colorPicker = ColorPicker(
        enableShadesSelection: true,
        color: widget.properties.value.colorName.color,
        pickersEnabled: <ColorPickerType, bool>{
          ColorPickerType.wheel: widget.axis == Axis.vertical,
          ColorPickerType.custom: true,
          ColorPickerType.primary: true,
        },
        customColorSwatchesAndNames: heavyColorSwap,
        onColorChanged: (Color color) {
          setState(() {
            widget.properties.value.colorName.color = color;
          });
        });

    if (widget.axis == Axis.vertical) {
      colorPicker = AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 500),
          child: colorPicker);
    }

    final delete = IconButton(
        onPressed: () => widget.actionCallBack(ActionEdit.remove),
        icon: const Icon(Icons.delete));

    final add = IconButton(
        onPressed: () => widget.actionCallBack(ActionEdit.add),
        icon: const Icon(Icons.add));

    final close = IconButton(
        onPressed: () => widget.actionCallBack(ActionEdit.close),
        icon: const Icon(Icons.close));

    final textField = TextField(
      controller: _textEditingController,
      onSubmitted: (String? value) {
        widget.properties.value.colorName.name = value ?? '';
      },
    );

    Widget keepAlive = IconButton(
        onPressed: () {
          setState(() {
            widget.properties.aliveOutsideView =
                !widget.properties.aliveOutsideView;
          });
        },
        isSelected: widget.properties.aliveOutsideView,
        selectedIcon: const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        icon: const Icon(Icons.favorite_border_outlined));

    keepAlive = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        keepAlive,
        const Text(
          'Keep Alive',
          style: TextStyle(fontSize: 8.0),
        )
      ],
    );
    // Row(
    //   children: [
    //     Checkbox(
    //         value: widget.properties.aliveOutsideView,
    //         onChanged: (bool? value) {
    //           setState(() {
    //             widget.properties.aliveOutsideView = value ?? false;
    //           });
    //         }),
    //     const Text('Keep alive'),
    //   ],
    // );

    final body = widget.axis == Axis.vertical
        ? Column(
            children: [
              const SizedBox(
                height: 8.0,
              ),
              Row(
                children: [
                  delete,
                  const Expanded(
                    child: SizedBox(),
                  ),
                  add,
                  close
                ],
              ),
              colorPicker,
              Row(
                children: [
                  const SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: textField,
                  ),
                  keepAlive,
                  const SizedBox(
                    width: 8.0,
                  ),
                ],
              ),
              const SizedBox(
                height: 12.0,
              ),
            ],
          )
        : Row(
            children: [
              Column(
                children: [
                  close,
                  add,
                  const Expanded(child: SizedBox()),
                  delete
                ],
              ),
              Expanded(
                  child: Column(
                children: [
                  Expanded(child: colorPicker),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, right: 16.0),
                    child: Row(
                      children: [Expanded(child: textField), keepAlive],
                    ),
                  ),
                ],
              ))
            ],
          );

    return SizedBox(
        width: widget.axis == Axis.horizontal ? itemEditWidth : null,
        // height: widget.axis == Axis.vertical ? itemEditHeight : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Material(
            color: widget.properties.value.colorName.color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.0)),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: body),
          ),
        ));
  }
}
