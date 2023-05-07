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

class SliverBoxBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double radialTop;
  final double radialbottom;
  final double overlap;

  const SliverBoxBackground({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.radialTop = 0.0,
    this.radialbottom = 0.0,
    this.overlap = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = Material(
      type: MaterialType.transparency,
      child: child,
    );

    final bgc = backgroundColor;
    return bgc == null
        ? w
        : CustomPaint(
            painter: DrawSliverBackground(
                overlap: overlap,
                color: bgc,
                radialTop: radialTop,
                radialBottom: radialbottom),
            child: w);
  }
}

class DrawSliverBackground extends CustomPainter {
  final Color color;
  final double radialTop;
  final double radialBottom;
  final double overlap;

  DrawSliverBackground({
    required this.color,
    required this.radialTop,
    required this.radialBottom,
    required this.overlap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height == 0.0) {
      return;
    }
    final paint = Paint()..color = color;

    if (radialTop == 0.0 && radialBottom == 0.0) {
      canvas.drawRect(
          Offset(0.0, -overlap) & size + Offset(0.0, overlap), paint);
    } else {
      double radialTopMax;
      double radialBottomMax;

      if (size.height < radialTop + radialBottom) {
        radialTopMax = size.height / (radialTop + radialBottom) * radialTop;
        radialBottomMax =
            size.height / (radialTop + radialBottom) * radialBottom;
      } else {
        radialTopMax = radialTop;
        radialBottomMax = radialBottom;
      }

      Rect rect = radialBottom == 0.0
          ? Offset.zero & size
          : Offset(0.0, -overlap) & size + Offset(0.0, overlap);

      canvas.drawRRect(
          RRect.fromRectAndCorners(rect,
              topLeft: Radius.circular(radialTopMax),
              topRight: Radius.circular(radialTopMax),
              bottomLeft: Radius.circular(radialBottomMax),
              bottomRight: Radius.circular(radialBottomMax)),
          paint);
    }
  }

  @override
  bool shouldRepaint(DrawSliverBackground oldDelegate) {
    return color != oldDelegate.color ||
        radialTop != oldDelegate.radialTop ||
        radialBottom != oldDelegate.radialBottom ||
        overlap != oldDelegate.overlap;
  }
}
