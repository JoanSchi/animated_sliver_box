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

import 'package:flutter/rendering.dart';
import '../animated_sliver_box.dart';
import 'flex_size_multi_box_adaptor.dart';
import 'flex_size_sliver_list.dart';

class ForwardTracker extends FlexSizeLayoutTracker {
  int length;

  ForwardTracker({
    required super.render,
    required super.renderBox,
    required super.forward,
    required super.scrollOffset,
    required super.visualScrollOffset,
    required super.targetEndScrollOffset,
    super.findIndex = false,
    required super.childConstraints,
    required this.length,
    super.leading,
    super.trailing,
    super.firstVisual,
  });

  void driveFromStart() {
    assert(findIndex, 'FindIndex should be true');
    index = 0;
    drive();
  }

  void driveFromFirstChild({bool skipFirstLayout = false}) {
    final childParent = renderBox!.parentData as FlexSizeSliverParentData;

    index = childParent.index!;

    // Index mag nooit hoger zijn dan index render
    // Als de volgende render zelfde index heeft wordt index twee keer geplaatst.
    //

    start = childParent.layoutOffset!;

    if (!skipFirstLayout) {
      renderBox!.layout(childConstraints, parentUsesSize: true);
    }
    end = start + render.flexSizeChild(renderBox!);

    catchLeading();
    catchTrailing();

    if (firstVisual != null) {
      boxItemProperties = render.model.getProperties(index);
      catchFirstVisual();
    }

    nextIndex();
    renderBox = render.childAfter(renderBox!) ?? renderBox;

    drive();
  }

  @override
  bool hasNext() =>
      (findIndex || start <= targetEndScrollOffset) && index < length;

  @override
  bool skipChild(double flexSize) {
    if (findIndex) {
      return index != length - 1;
    }

    return super.skipChild(flexSize);
  }

  @override
  catchLeading() {
    final edge = leading;

    if (edge == null) return;

    bool match = findIndex
        ? index == length - 1
        : (start <= scrollOffset && edge.isIndexGreater(index));

    if (match) {
      setEdge(edge);
    }
    if (findIndex ? match : !match) {
      leading = null;
    }
  }

  @override
  catchTrailing() {
    final edge = trailing;

    if (edge == null) return;

    assert(!findIndex,
        'FindIndex is not implemented with trailing. FindIndex is only used with Leading to find the first visible with newLength from FirstVisible Object');

    bool match = start <= targetEndScrollOffset && edge.isIndexGreater(index);

    if (match) {
      setEdge(edge);
    }
    if (!match) {
      trailing = null;
    }
  }

  @override
  void catchFirstVisual() {
    final visual = firstVisual;

    if (visual == null) return;

    bool match = start <= visualScrollOffset && visual.isIndexGreater(index);

    if (match) {
      visual
        ..index = index
        ..start = start
        ..end = end
        ..overflow = visualScrollOffset - start
        ..boxItemProperties = boxItemProperties;
    }

    if (!match) {
      firstVisual = null;
    }
  }

  void drive() {
    while (hasNext() && renderBox != null) {
      boxItemProperties = render.model.getProperties(index);

      final FlexSizeSliverParentData renderBoxParentData =
          renderBox!.parentData! as FlexSizeSliverParentData;

      final renderBoxIndex = renderBoxParentData.index!;

      if (renderBoxIndex == index) {
        renderBox = render.layoutBox(renderBox!, boxItemProperties, this);
      } else if (renderBoxIndex > index) {
        //A box is added before next, therefore this next, will be the next next.
        renderBox = render.insertBox(
            before: renderBox,
            boxItemProperties: boxItemProperties,
            layoutBoxTracker: this);
      } else {
        renderBox = render.insertBox(
            after: renderBox,
            boxItemProperties: boxItemProperties,
            layoutBoxTracker: this);
      }

      catchLeading();

      catchTrailing();

      catchFirstVisual();

      nextIndex();
    }
  }
}

class BackwardTracker extends FlexSizeLayoutTracker {
  BackwardTracker({
    required super.render,
    required super.renderBox,
    required super.forward,
    required super.scrollOffset,
    required super.visualScrollOffset,
    required super.targetEndScrollOffset,
    required super.findIndex,
    required super.childConstraints,
    super.leading,
    super.trailing,
    super.firstVisual,
  }) {
    final childParent = renderBox!.parentData as FlexSizeSliverParentData;

    index = childParent.index!;
    start = childParent.layoutOffset!;

    renderBox!.layout(childConstraints, parentUsesSize: true);
    end = start + render.flexSizeChild(renderBox!);

    catchLeading();
    catchTrailing();

    if (firstVisual != null) {
      boxItemProperties = render.model.getProperties(index);
      catchFirstVisual();
    }

    renderBox = render.childBefore(renderBox!) ?? renderBox;
    nextIndex();
    drive();
  }

  @override
  bool hasNext() => (findIndex || end >= scrollOffset) && index >= 0;

  @override
  bool skipChild(double flexSize) {
    if (findIndex) {
      return index != 0;
    }

    return super.skipChild(flexSize);
  }

  @override
  catchLeading() {
    final edge = leading;

    if (edge == null) return;

    bool match = findIndex ? index == 0 : end >= scrollOffset;

    if (match) {
      setEdge(edge);
    }
    if (findIndex ? match : !match) {
      leading = null;
    }
  }

  @override
  catchTrailing() {
    final edge = trailing;

    if (edge == null) return;

    bool match = findIndex
        ? index == 0
        : (end >= targetEndScrollOffset && edge.isIndexSmaller(index));

    if (match) {
      setEdge(edge);
    }
    if (findIndex ? match : !match) {
      trailing = null;
    }
  }

  @override
  void catchFirstVisual() {
    final visual = firstVisual;

    if (visual == null) return;

    bool match = end >= visualScrollOffset && visual.isIndexSmaller(index);

    if (match) {
      visual
        ..index = index
        ..start = start
        ..end = end
        ..overflow = visualScrollOffset - start
        ..boxItemProperties = boxItemProperties;
    }

    if (!match) {
      firstVisual = null;
    }
  }

  void drive() {
    while (hasNext() && renderBox != null) {
      boxItemProperties = render.model.getProperties(index);

      FlexSizeSliverParentData backParentData =
          renderBox!.parentData! as FlexSizeSliverParentData;

      final indexBox = backParentData.index!;

      if (indexBox == index) {
        renderBox = render.layoutBox(renderBox!, boxItemProperties, this);
      } else if (indexBox < index) {
        renderBox = render.insertBox(
          after: renderBox,
          layoutBoxTracker: this,
          boxItemProperties: boxItemProperties,
        );
      } else {
        renderBox = render.insertBox(
            before: renderBox,
            layoutBoxTracker: this,
            boxItemProperties: boxItemProperties);
      }

      catchLeading();

      catchFirstVisual();

      catchTrailing();

      nextIndex();
    }
  }
}

abstract class FlexSizeLayoutTracker {
  FlexSizeRenderSliverList render;
  RenderBox? renderBox;
  double start = 0.0;
  double end = 0.0;
  bool forward;
  int index = -1;
  double scrollOffset;
  double visualScrollOffset;
  double targetEndScrollOffset;
  bool findIndex;
  BoxConstraints childConstraints;
  Edge? leading;
  Edge? trailing;
  FirstVisual? firstVisual;
  late BoxItemProperties boxItemProperties;

  FlexSizeLayoutTracker({
    required this.render,
    required this.renderBox,
    required this.forward,
    required this.scrollOffset,
    required this.visualScrollOffset,
    required this.targetEndScrollOffset,
    required this.findIndex,
    required this.childConstraints,
    this.leading,
    this.trailing,
    this.firstVisual,
  });

  setSize(double flexSize) {
    if (forward) {
      end += flexSize;
    } else {
      start -= flexSize;
    }
  }

  setSizeAndOffset(double flexSize, FlexSizeSliverParentData parentData) {
    setSize(flexSize);
    parentData.layoutOffset = start;
  }

  void nextIndex() {
    index += forward ? 1 : -1;

    if (forward) {
      start = end;
    } else {
      end = start;
    }
  }

  bool containsOffset() {
    return start <= scrollOffset && scrollOffset < end;
  }

  bool hasNext();

  void catchLeading();

  void catchTrailing();

  void catchFirstVisual();

  bool skipChild(double flexSize) {
    double s = start;
    double e = end;

    if (forward) {
      e += flexSize;
    } else {
      s -= flexSize;
    }
    return (e < scrollOffset || s > targetEndScrollOffset);
  }

  void setEdge(Edge leading) {
    leading
      ..index = index
      ..start = start
      ..end = end;
  }
}

class Edge {
  int index;
  double start;
  double end;

  Edge.empty()
      : index = -1,
        start = 0.0,
        end = 0.0;

  Edge({
    required this.index,
    required this.start,
    required this.end,
  });

  bool isIndexSmaller(int i) {
    return index == -1 || i < index;
  }

  bool isIndexGreater(int i) {
    return i > index;
  }
}

class FirstVisual {
  BoxItemProperties? boxItemProperties;
  int index;
  double overflow;
  double start;
  double end;
  int newLengthToVisual = -1;

  FirstVisual.empty()
      : start = 0.0,
        end = 0.0,
        index = -1,
        overflow = 0.0;

  FirstVisual({
    required this.boxItemProperties,
    required this.index,
    required this.start,
    required this.end,
    required this.overflow,
  });

  bool get relayout =>
      newLengthToVisual != -1 && newLengthToVisual - 1 != index;

  bool isIndexSmaller(int i) {
    return index == -1 || i < index;
  }

  bool isIndexGreater(int i) {
    return i > index;
  }

  double get deltaOverlowToEnd => end - start - overflow;
}
