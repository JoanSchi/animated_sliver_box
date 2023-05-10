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

class SliverBoxScaleResizedTransition extends AnimatedWidget {
  /// Creates a scale transition.
  ///
  /// The [scale] argument must not be null. The [alignment] argument defaults
  /// to [Alignment.center].
  const SliverBoxScaleResizedTransition({
    super.key,
    required super.listenable,
    this.alignment = Alignment.center,
    this.child,
  });

  /// The animation that controls the scale of the child.
  ///
  /// If the current value of the scale animation is v, the child will be
  /// painted v times its normal size.
  Animation<double> get scale => listenable as Animation<double>;

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
    final double scaleValue = scale.value;
    final Matrix4 transform = Matrix4.identity()
      ..scale(scaleValue, scaleValue, 1.0);
    return _ScaledSize(
      scale: scaleValue,
      child: Transform(
        transform: transform,
        alignment: alignment,
        child: child,
      ),
    );
  }
}

// class ScaleResized extends StatelessWidget {
//   /// Creates a scale transition.
//   ///
//   /// The [scale] argument must not be null. The [alignment] argument defaults
//   /// to [Alignment.center].
//   const ScaleResized({
//     Key? key,
//     required this.scale,
//     this.alignment = Alignment.center,
//     this.child,
//   }) : super(key: key);

//   /// The animation that controls the scale of the child.
//   ///
//   /// If the current value of the scale animation is v, the child will be
//   /// painted v times its normal size.
//   final double scale;

//   /// The alignment of the origin of the coordinate system in which the scale
//   /// takes place, relative to the size of the box.
//   ///
//   /// For example, to set the origin of the scale to bottom middle, you can use
//   /// an alignment of (0.0, 1.0).
//   final Alignment alignment;

//   /// The widget below this widget in the tree.
//   ///
//   /// {@macro flutter.widgets.ProxyWidget.child}
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     final double scaleValue = scale;
//     final Matrix4 transform = Matrix4.identity()
//       ..scale(scaleValue, scaleValue, 1.0);
//     return ScaledSize(
//       scale: scaleValue,
//       child: Transform(
//         transform: transform,
//         alignment: alignment,
//         child: child,
//       ),
//     );
//   }
// }

class _ScaledSize extends SingleChildRenderObjectWidget {
  const _ScaledSize({
    Key? key,
    Widget? child,
    required this.scale,
  }) : super(key: key, child: child);

  final double scale;

  @override
  ScaleResizedRender createRenderObject(BuildContext context) {
    return ScaleResizedRender(scale: scale);
  }

  @override
  void updateRenderObject(
      BuildContext context, ScaleResizedRender renderObject) {
    renderObject.scale = scale;
  }
}

class ScaleResizedRender extends RenderShiftedBox {
  ScaleResizedRender({
    RenderBox? child,
    required double scale,
  })  : _scale = scale,
        super(child);

  double _scale;

  double get scale => _scale;

  set scale(double value) {
    if (_scale == value) return;
    _scale = value;
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

  // @override
  // double computeMaxIntrinsicWidth(double height) {
  //   return super.computeMaxIntrinsicWidth(height);
  // }

  // @override
  // double computeMinIntrinsicHeight(double width) {
  //   return super.computeMinIntrinsicHeight(width);
  // }

  // @override
  // double computeMaxIntrinsicHeight(double width) {
  //   return super.computeMaxIntrinsicHeight(width);
  // }

  @override
  void performLayout() {
    // final BoxConstraints constraints = this.constraints;
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);

      Size originalSize = child!.size;

      final BoxParentData parentData = child!.parentData as BoxParentData;

      // parentData.offset = Offset(
      //     (originalSize.width * scale - originalSize.width) / 2.0,
      //     (originalSize.height * scale - originalSize.height) / 2.0);

      final scaledSize =
          Size(originalSize.width * scale, originalSize.height * scale);

      size = constraints.constrain(scaledSize);

      parentData.offset = center(Offset(
          size.width - originalSize.width, size.height - originalSize.height));
    } else {
      size = Size.zero;
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
    properties.add(DiagnosticsProperty<double>('scale', scale));
  }
}
