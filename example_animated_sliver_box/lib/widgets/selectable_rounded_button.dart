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

class SelectableButton<T> extends StatelessWidget {
  final bool selected;
  final T value;
  final T groupValue;
  final Color? primaryColor;
  final Color? onPrimaryColor;
  final String text;
  final ValueChanged<T> onChange;
  final OutlinedBorder outlinedBorder;

  const SelectableButton({
    super.key,
    required this.selected,
    required this.value,
    required this.groupValue,
    this.primaryColor,
    this.onPrimaryColor,
    required this.text,
    required this.onChange,
    this.outlinedBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0))),
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    final theme = Theme.of(context);

    final primaryColor = this.primaryColor ?? theme.colorScheme.primary;
    final onPrimaryColor =
        this.onPrimaryColor ?? theme.colorScheme.onPrimaryContainer;

    final backgroundColor = selected ? primaryColor : null;

    final textColor = selected ? onPrimaryColor : primaryColor;

    return Padding(
      padding: EdgeInsets.zero,
      child: OutlinedButton(
        style: ButtonStyle(
          visualDensity: const VisualDensity(horizontal: 1, vertical: 1),
          // padding: MaterialStateProperty.all<EdgeInsets>(
          //     const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0)),

          minimumSize: MaterialStateProperty.all<Size>(const Size(42.0, 42.0)),
          shape: MaterialStateProperty.all<OutlinedBorder>(outlinedBorder),
          backgroundColor: MaterialStateProperty.all<Color?>(backgroundColor),
          side: MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
            final Color color = states.contains(MaterialState.pressed)
                ? primaryColor
                : primaryColor;

            return BorderSide(color: color, width: 1.0);
          }),
        ),
        onPressed: () => onChange(value),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
