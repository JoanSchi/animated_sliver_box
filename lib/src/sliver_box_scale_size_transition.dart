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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../animated_sliver_box.dart';

class SliverBoxScaleResized extends StatelessWidget {
  /// Creates a scale transition.
  ///
  /// The [scale] argument must not be null. The [alignment] argument defaults
  /// to [Alignment.center].
  const SliverBoxScaleResized({
    Key? key,
    required this.sliverBoxItemProperties,
    required this.forwardValue,
    this.alignment = Alignment.center,
    this.child,
  }) : super(key: key);

  /// The animation that controls the scale of the child.
  ///
  /// If the current value of the scale animation is v, the child will be
  /// painted v times its normal size.
  final BoxItemProperties sliverBoxItemProperties;
  final double forwardValue;

  /// The alignment of the origin of the coordinate system in which the scale
  /// takes place, relative to the size of the box.
  ///
  /// For example, to set the origin of the scale to bottom middle, you can use
  /// an alignment of (0.0, 1.0).
  final Alignment alignment;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    double scale;

    switch (sliverBoxItemProperties.transitionStatus) {
      case BoxItemTransitionState.insert:
      case BoxItemTransitionState.appear:
      case BoxItemTransitionState.insertFront:
        {
          scale = forwardValue;
          break;
        }

      case BoxItemTransitionState.remove:
      case BoxItemTransitionState.disappear:
        {
          scale = 1.0 - forwardValue;
          break;
        }
      case BoxItemTransitionState.visible:
        {
          scale = 1.0;
          break;
        }
      case BoxItemTransitionState.insertLater:
      case BoxItemTransitionState.invisible:
        {
          scale = 0.0;
          break;
        }
    }

    final Matrix4 transform = Matrix4.identity()..scale(scale, scale, 1.0);
    return _ResizeToScale(
      scaleX: scale,
      scaleY: scale,
      child: Transform(
        transform: transform,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

class SliverBoxScaleAndResize extends StatelessWidget {
  /// Creates a scale transition.
  ///
  /// The [scale] argument must not be null. The [alignment] argument defaults
  /// to [Alignment.center].
  const SliverBoxScaleAndResize({
    Key? key,
    required this.value,
    this.alignment = Alignment.center,
    required this.child,
  }) : super(key: key);

  final double value;
  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()..scale(value, value, 1.0);
    return _ResizeToScale(
      scaleX: value,
      scaleY: value,
      child: Transform(
        transform: transform,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

class _ResizeToScale extends SingleChildRenderObjectWidget {
  const _ResizeToScale({
    Key? key,
    Widget? child,
    required this.scaleX,
    required this.scaleY,
  }) : super(key: key, child: child);

  final double scaleX;
  final double scaleY;

  @override
  ScaleResizedRender createRenderObject(BuildContext context) {
    return ScaleResizedRender(
      scaleX: scaleX,
      scaleY: scaleY,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, ScaleResizedRender renderObject) {
    renderObject
      ..scaleX = scaleX
      ..scaleY = scaleY;
  }
}

class ScaleResizedRender extends RenderShiftedBox {
  ScaleResizedRender({
    RenderBox? child,
    required double scaleX,
    required double scaleY,
  })  : _scaleX = scaleX,
        _scaleY = scaleY,
        super(child);

  double _scaleX;
  double _scaleY;

  double get scaleX => _scaleX;

  set scaleX(double value) {
    if (_scaleX == value) return;
    _scaleX = value;
    markNeedsLayout();
  }

  double get scaleY => _scaleY;

  set scaleY(double value) {
    if (_scaleY == value) return;
    _scaleY = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  // @override
  // double computeMinIntrinsicWidth(double height) {
  //   return super.computeMinIntrinsicWidth(height);
  // }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return super.computeMaxIntrinsicWidth(height) * _scaleX;
  }

  // @override
  // double computeMinIntrinsicHeight(double width) {
  //   return super.computeMinIntrinsicHeight(width);
  // }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return super.computeMaxIntrinsicHeight(width) * _scaleX;
  }

  @override
  void performLayout() {
    Size originalSize;
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);

      if (constraints.hasBoundedWidth) {
        originalSize = Size(constraints.maxWidth, child!.size.height);
      } else if (constraints.hasBoundedHeight) {
        originalSize = Size(child!.size.width, constraints.maxHeight);
      } else {
        throw Exception(
            'ScaleResizedRender: Width and height are infinite, either the heigth or the widht needs a bounded size.!');
      }

      final scaledSize =
          Size(originalSize.width * scaleX, originalSize.height * scaleY);

      size = constraints.constrain(scaledSize);

      final BoxParentData parentData = child!.parentData as BoxParentData;

      parentData.offset = center(Offset(
          size.width - originalSize.width, size.height - originalSize.height));
    } else {
      originalSize = Size.zero;
    }
  }

  Offset center(Offset other) {
    final double centerX = other.dx / 2.0;
    final double centerY = other.dy / 2.0;
    return Offset(centerX, centerY);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      return child!.getDryLayout(constraints);
    } else {
      return Size.zero;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('scaleX', scaleX));
    properties.add(DiagnosticsProperty<double>('scaleY', scaleY));
  }
}
