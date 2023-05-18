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

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../animated_sliver_box.dart';
import '../animated_sliver_box_model.dart';
import 'flex_size_multi_box_adaptor.dart';
import 'flex_size_sliver.dart';
import 'flex_size_tracker.dart';

class FlexSizeSliverList extends FlexSizeSliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places box children in a linear array.
  const FlexSizeSliverList({
    super.key,
    required super.delegate,
    required this.model,
  });

  final AnimatedSliverBoxModel model;

  @override
  FlexSizeSliverMultiBoxAdaptorElement createElement() =>
      FlexSizeSliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  FlexSizeRenderSliverList createRenderObject(BuildContext context) {
    final FlexSizeSliverMultiBoxAdaptorElement element =
        context as FlexSizeSliverMultiBoxAdaptorElement;
    return FlexSizeRenderSliverList(childManager: element, model: model);
  }
}

class FlexSizeRenderSliverList extends FlexSizeRenderSliverMultiBoxAdaptor {
  /// Creates a sliver that places multiple box children in a linear array along
  /// the main axis.
  ///
  /// The [childManager] argument must not be null.

  AnimatedSliverBoxModel model;
  FirstVisual? firstVisual;

  FlexSizeRenderSliverList({
    required super.childManager,
    required this.model,
  });

  bool get vertical =>
      constraints.axisDirection == AxisDirection.down ||
      constraints.axisDirection == AxisDirection.up;

  double flexSizeChild(RenderBox renderBox) {
    return (constraints.axisDirection == AxisDirection.down ||
            constraints.axisDirection == AxisDirection.up)
        ? renderBox.size.height
        : renderBox.size.width;
  }

  // LayoutBox
  //
  //
  //

  RenderBox? layoutBox(
    RenderBox box,
    BoxItemProperties boxItemProperties,
    FlexSizeLayoutTracker layoutBoxTracker,
  ) {
    box.layout(layoutBoxTracker.childConstraints, parentUsesSize: true);
    double flexSize = flexSizeChild(box);
    boxItemProperties.setMeasuredSize(constraints.axis, flexSize);

    final childParentData = box.parentData! as FlexSizeSliverParentData;

    layoutBoxTracker.setSizeAndOffset(flexSize, childParentData);

    return (layoutBoxTracker.forward
            ? childParentData.nextSibling
            : childParentData.previousSibling) ??
        box;
  }

  RenderBox? insertBox({
    RenderBox? before,
    RenderBox? after,
    required BoxItemProperties boxItemProperties,
    required FlexSizeLayoutTracker layoutBoxTracker,
  }) {
    double? flexSize = boxItemProperties.flexSize(constraints.axis);
    RenderBox? box;

    if (flexSize != null && layoutBoxTracker.skipChild(flexSize)) {
      layoutBoxTracker.setSize(flexSize);
      boxItemProperties.setMeasuredSize(constraints.axis, flexSize);
      box = before ?? after;

      // final childParentData =
      //     box!.parentData! as MySliverMultiBoxAdaptorParentData;

      // return (layoutBoxTracker.forward
      //         ? childParentData.nextSibling
      //         : childParentData.previousSibling) ??
      //     box;
      return box;
    }

    after = (before != null) ? childBefore(before) : after;

    box = insertAndLayoutChild(layoutBoxTracker.childConstraints,
        after: after, index: layoutBoxTracker.index, parentUsesSize: true);

    if (box != null) {
      flexSize = flexSizeChild(box);
      boxItemProperties.setMeasuredSize(constraints.axis, flexSize);

      final childParentData = box.parentData! as FlexSizeSliverParentData;

      layoutBoxTracker.setSizeAndOffset(flexSize, childParentData);

      assert(() {
        double? fl = boxItemProperties.flexSize(constraints.axis);
        return (fl == null || fl == flexSize);
      }(),
          'Index: ${layoutBoxTracker.index}: Size check flexSize is not null, therefore the size ${boxItemProperties.flexSize(constraints.axis)} should be equal to the measured size $flexSize. The direction is ${constraints.axis}, boxItemProperties id: ${boxItemProperties.id})');

      return (layoutBoxTracker.forward
              ? childParentData.nextSibling
              : childParentData.previousSibling) ??
          box;
    } else {
      assert(false, 'InsertBox function: box after insert is null.');
    }
    return box;
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final double visualScrollOffset = constraints.scrollOffset;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;
    final BoxConstraints childConstraints = constraints.asBoxConstraints();

    //
    //
    //
    //

    //No items:
    if (model.length == 0) {
      //collectMyGarbage(removeAll: true);
      assert(firstChild == null,
          'If length == 0, then firstchild should be null after garbage collection!');
      childManager.setDidUnderflow(true);
      firstVisual = null;
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      debugPrint('new: zero firstChild: ${firstChild != null}');
      return;
    }

    // Make sure we have at least one child to start from.

    RenderBox? earliestUsefulChild = firstChild;

    if (earliestUsefulChild != null &&
        childScrollOffset(earliestUsefulChild) == null) {
      int leadingChildrenWithoutLayoutOffset = 0;
      while (earliestUsefulChild != null &&
          childScrollOffset(earliestUsefulChild) == null) {
        earliestUsefulChild = childAfter(earliestUsefulChild);
        leadingChildrenWithoutLayoutOffset += 1;
      }
      // We should be able to destroy children with null layout offset safely,
      // because they are likely outside of viewport
      collectGarbage(leadingChildrenWithoutLayoutOffset, 0);
      // If can not find a valid layout offset, start from the initial child.
    }

    if (firstChild == null) {
      if (!addInitialChild()) {
        // There are no children.
        firstVisual = null;
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        debugPrint('new: zero firstChild: ${firstChild != null}');
        return;
      }
    }

    // If items are added or removed before the first visual, than a relayout is
    // desired to prevent a jump
    //
    //

    if (firstVisual?.relayout ?? false) {
      final leading = Edge.empty();

      assert(firstVisual!.newLengthToVisual <= model.length,
          'Visual length: ${firstVisual!.newLengthToVisual} should never be larger than total length ${model.length}');

      ForwardTracker(
        childConstraints: childConstraints,
        render: this,
        renderBox: firstChild,
        forward: true,
        findIndex: true,
        scrollOffset: scrollOffset,
        visualScrollOffset: visualScrollOffset,
        targetEndScrollOffset: targetEndScrollOffset,
        length: firstVisual!.newLengthToVisual,
        leading: leading,
      ).driveFromStart();

      collectMyGarbage(leadingGarbage: leading.index);

      FlexSizeSliverParentData childParent =
          firstChild!.parentData as FlexSizeSliverParentData;

      assert(indexOf(firstChild!) == leading.index,
          'FirstVisuable index is different leading index ${leading.index} and child ${indexOf(firstChild!)}');

      assert(childParent.layoutOffset != null,
          'FirstVisuable layoutOffset first offset is null');

      assert(childParent.layoutOffset == leading.start,
          'FirstVisuable layoutOffset first offset is ${childParent.layoutOffset} and leading start ${leading.start}');

      final newScrollOffset = leading.start + firstVisual!.overflow;
      debugPrint(
          'leading.start ${leading.start} visualScrollOffset $visualScrollOffset overflow ${firstVisual!.overflow} ${firstVisual!.boxItemProperties!.id}');
      // If the leading index = 0, the check is ignored because this may be a replacement.
      // With a replacement the newLengthToVisual is not counted therefore the newLengthToVisual will be 1 and the index will be 0.
      // This is done, to prevent a swift caused by a delayed animation which cause a measured size bigger than 0.0.
      assert(
          leading.index == 0 ||
              firstVisual!.boxItemProperties ==
                  model.getProperties(leading.index),
          'SliverboxItemProperties komt niet overeen leading index: ${leading.index}, id firstVisual: ${firstVisual?.boxItemProperties?.id} id getProperties: ${model.getProperties(leading.index).id}, '
          'New length FirstVisual: ${firstVisual?.newLengthToVisual},  oldIndex: ${firstVisual?.index}');

      //Break
      firstVisual = null;

      if (newScrollOffset != visualScrollOffset) {
        geometry = SliverGeometry(
            scrollOffsetCorrection: -visualScrollOffset + newScrollOffset);

        model.scheduleAnimationAfterLayout();
        return;
      } else {
        debugPrint('Nothing changed!');
      }
    }

    earliestUsefulChild = firstChild!;

    final leading = Edge.empty();

    final trailing = Edge.empty();

    firstVisual = FirstVisual.empty();

    final backwardTracker = BackwardTracker(
        render: this,
        renderBox: earliestUsefulChild,
        childConstraints: childConstraints,
        scrollOffset: scrollOffset,
        targetEndScrollOffset: targetEndScrollOffset,
        forward: false,
        findIndex: false,
        visualScrollOffset: visualScrollOffset,
        leading: leading,
        trailing: trailing,
        firstVisual: firstVisual);

    // Evaluate if
    //
    // If the scrollOffsetCorrection  is negative value, the scrollOffset wil decrease.
    // If the scrollOffsetCorrection is positive the scrollOffset will increase.

    if (leading.index == 0 && leading.start > precisionErrorTolerance) {
      final childParent = firstChild!.parentData as FlexSizeSliverParentData;
      childParent.layoutOffset = 0.0;
      assert(leading.index == indexOf(firstChild!),
          'leading index ${leading.index} is not equal to firstChild ${indexOf(firstChild!)}');

      // debugPrint(
      //     'Leading.start ${leading.start}, Scrolloffset: $scrollOffset, ScrollOffsetCorrection ${-scrollOffset + (scrollOffset - leading.start)}');
      geometry = SliverGeometry(
          scrollOffsetCorrection:
              -scrollOffset + (scrollOffset - leading.start));
      return;
    } else if (scrollOffset == 0.0 &&
        leading.start < -precisionErrorTolerance) {
      double offset;

      if (leading.index == 0) {
        offset = leading.start;
      } else {
        backwardTracker
          ..findIndex = true
          ..leading = leading
          ..drive();

        assert(leading.index == 0,
            'Going to start: The index is not 0, but ${leading.index}');
        offset = leading.start;
      }

      final childParent = firstChild!.parentData as FlexSizeSliverParentData;
      childParent.layoutOffset = 0.0;
      geometry = SliverGeometry(scrollOffsetCorrection: -offset);
      return;
    }

    ForwardTracker(
      render: this,
      renderBox: earliestUsefulChild,
      childConstraints: childConstraints,
      scrollOffset: scrollOffset,
      targetEndScrollOffset: targetEndScrollOffset,
      forward: true,
      findIndex: false,
      visualScrollOffset: visualScrollOffset,
      length: model.length,
      leading: leading,
      trailing: trailing,
      firstVisual: firstVisual,
    ).driveFromFirstChild(skipFirstLayout: true);

    assert(leading.index != -1, 'Leading index is -1');
    assert(trailing.index != -1, 'Trailing index is -1');
    collectMyGarbage(
        leadingGarbage: leading.index, trailingGarbage: trailing.index);

    assert(() {
      RenderBox? testRender = firstChild;
      while (testRender != null) {
        final parentDataChild =
            testRender.parentData as FlexSizeSliverParentData;
        if (parentDataChild.layoutOffset == null) {
          return false;
        }

        testRender = parentDataChild.nextSibling;
      }
      return true;
    }(),
        'After garbage collection a child with layoutOffset null was found Leading index: ${leading.index}, Trailing index: ${trailing.index}');

    double endScrollOffset = trailing.end;
    double estimatedMaxScrollOffset;

    // if (trailing.end < targetEndScrollOffset) {
    //   geometry = SliverGeometry(
    //     scrollExtent: endScrollOffset,
    //     maxPaintExtent: endScrollOffset,
    //   );
    //   return;
    // }

    if (trailing.index == model.length - 1) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: leading.index,
        lastIndex: trailing.index,
        leadingScrollOffset: leading.start,
        trailingScrollOffset: trailing.end,
      );
      assert(estimatedMaxScrollOffset >=
          endScrollOffset - childScrollOffset(firstChild!)!);
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leading.start,
      to: trailing.end,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leading.start,
      to: trailing.end,
    );

    // debugPrint(
    //     'estimatedMaxScrollOffset $estimatedMaxScrollOffset paintExtent $paintExtent cacheExtent $cacheExtent');

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    final hasVisualOverflow = endScrollOffset > targetEndScrollOffsetForPaint ||
        constraints.scrollOffset > 0.0;

    // debugPrint(
    //     'new: estimatedMaxScrollOffset $estimatedMaxScrollOffset paintExtent: $paintExtent $cacheExtent $estimatedMaxScrollOffset hasVisualOverflow $hasVisualOverflow estimatedMaxScrollOffset == endScrollOffset ${estimatedMaxScrollOffset == endScrollOffset}');

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: hasVisualOverflow,
    );

    //   // We may have started the layout while scrolled to the end, which would not
    //   // expose a new child.
    if (estimatedMaxScrollOffset == endScrollOffset) {
      childManager.setDidUnderflow(true);
    }
    childManager.didFinishLayout();
  }

  @override
  void garbageCollectedIndex(int index) {
    model.getProperties(index).garbageCollected(constraints.axis);
  }

  // void performLayoutOriginal() {
  //   final SliverConstraints constraints = this.constraints;
  //   childManager.didStartLayout();
  //   childManager.setDidUnderflow(false);

  //   final double scrollOffset =
  //       constraints.scrollOffset + constraints.cacheOrigin;
  //   assert(scrollOffset >= 0.0);
  //   final double remainingExtent = constraints.remainingCacheExtent;
  //   assert(remainingExtent >= 0.0);
  //   final double targetEndScrollOffset = scrollOffset + remainingExtent;
  //   final BoxConstraints childConstraints = constraints.asBoxConstraints();
  //   int leadingGarbage = 0;
  //   int trailingGarbage = 0;
  //   bool reachedEnd = false;

  //   // This algorithm in principle is straight-forward: find the first child
  //   // that overlaps the given scrollOffset, creating more children at the top
  //   // of the list if necessary, then walk down the list updating and laying out
  //   // each child and adding more at the end if necessary until we have enough
  //   // children to cover the entire viewport.
  //   //
  //   // It is complicated by one minor issue, which is that any time you update
  //   // or create a child, it's possible that the some of the children that
  //   // haven't yet been laid out will be removed, leaving the list in an
  //   // inconsistent state, and requiring that missing nodes be recreated.
  //   //
  //   // To keep this mess tractable, this algorithm starts from what is currently
  //   // the first child, if any, and then walks up and/or down from there, so
  //   // that the nodes that might get removed are always at the edges of what has
  //   // already been laid out.

  //   // Make sure we have at least one child to start from.
  //   if (firstChild == null) {
  //     if (!addInitialChild()) {
  //       // There are no children.
  //       geometry = SliverGeometry.zero;
  //       debugPrint('original: zero firstChild: ${firstChild != null}');
  //       childManager.didFinishLayout();
  //       return;
  //     }
  //   }

  //   // We have at least one child.

  //   // These variables track the range of children that we have laid out. Within
  //   // this range, the children have consecutive indices. Outside this range,
  //   // it's possible for a child to get removed without notice.
  //   RenderBox? leadingChildWithLayout, trailingChildWithLayout;

  //   RenderBox? earliestUsefulChild = firstChild;

  //   // A firstChild with null layout offset is likely a result of children
  //   // reordering.
  //   //
  //   // We rely on firstChild to have accurate layout offset. In the case of null
  //   // layout offset, we have to find the first child that has valid layout
  //   // offset.
  //   if (childScrollOffset(firstChild!) == null) {
  //     int leadingChildrenWithoutLayoutOffset = 0;
  //     while (earliestUsefulChild != null &&
  //         childScrollOffset(earliestUsefulChild) == null) {
  //       earliestUsefulChild = childAfter(earliestUsefulChild);
  //       leadingChildrenWithoutLayoutOffset += 1;
  //     }
  //     // We should be able to destroy children with null layout offset safely,
  //     // because they are likely outside of viewport
  //     collectGarbage(leadingChildrenWithoutLayoutOffset, 0);
  //     // If can not find a valid layout offset, start from the initial child.
  //     if (firstChild == null) {
  //       if (!addInitialChild()) {
  //         // There are no children.
  //         geometry = SliverGeometry.zero;
  //         debugPrint('original: zero firstChild: ${firstChild != null}');
  //         childManager.didFinishLayout();
  //         return;
  //       }
  //     }
  //   }

  //   // Find the last child that is at or before the scrollOffset.
  //   earliestUsefulChild = firstChild;
  //   for (double earliestScrollOffset = childScrollOffset(earliestUsefulChild!)!;
  //       earliestScrollOffset > scrollOffset;
  //       earliestScrollOffset = childScrollOffset(earliestUsefulChild)!) {
  //     // We have to add children before the earliestUsefulChild.
  //     earliestUsefulChild =
  //         insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
  //     if (earliestUsefulChild == null) {
  //       final MySliverMultiBoxAdaptorParentData childParentData =
  //           firstChild!.parentData! as MySliverMultiBoxAdaptorParentData;
  //       childParentData.layoutOffset = 0.0;

  //       if (scrollOffset == 0.0) {
  //         // insertAndLayoutLeadingChild only lays out the children before
  //         // firstChild. In this case, nothing has been laid out. We have
  //         // to lay out firstChild manually.
  //         firstChild!.layout(childConstraints, parentUsesSize: true);
  //         earliestUsefulChild = firstChild;
  //         leadingChildWithLayout = earliestUsefulChild;
  //         trailingChildWithLayout ??= earliestUsefulChild;
  //         break;
  //       } else {
  //         // We ran out of children before reaching the scroll offset.
  //         // We must inform our parent that this sliver cannot fulfill
  //         // its contract and that we need a scroll offset correction.
  //         geometry = SliverGeometry(
  //           scrollOffsetCorrection: -scrollOffset,
  //         );
  //         return;
  //       }
  //     }

  //     final double firstChildScrollOffset =
  //         earliestScrollOffset - paintExtentOf(firstChild!);
  //     // firstChildScrollOffset may contain double precision error
  //     if (firstChildScrollOffset < -precisionErrorTolerance) {
  //       // Let's assume there is no child before the first child. We will
  //       // correct it on the next layout if it is not.
  //       geometry = SliverGeometry(
  //         scrollOffsetCorrection: -firstChildScrollOffset,
  //       );
  //       final MySliverMultiBoxAdaptorParentData childParentData =
  //           firstChild!.parentData! as MySliverMultiBoxAdaptorParentData;
  //       childParentData.layoutOffset = 0.0;
  //       return;
  //     }

  //     final MySliverMultiBoxAdaptorParentData childParentData =
  //         earliestUsefulChild.parentData! as MySliverMultiBoxAdaptorParentData;
  //     childParentData.layoutOffset = firstChildScrollOffset;
  //     assert(earliestUsefulChild == firstChild);
  //     leadingChildWithLayout = earliestUsefulChild;
  //     trailingChildWithLayout ??= earliestUsefulChild;
  //   }

  //   assert(childScrollOffset(firstChild!)! > -precisionErrorTolerance);

  //   // If the scroll offset is at zero, we should make sure we are
  //   // actually at the beginning of the list.
  //   if (scrollOffset < precisionErrorTolerance) {
  //     // We iterate from the firstChild in case the leading child has a 0 paint
  //     // extent.
  //     while (indexOf(firstChild!) > 0) {
  //       final double earliestScrollOffset = childScrollOffset(firstChild!)!;
  //       // We correct one child at a time. If there are more children before
  //       // the earliestUsefulChild, we will correct it once the scroll offset
  //       // reaches zero again.
  //       earliestUsefulChild =
  //           insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
  //       assert(earliestUsefulChild != null);
  //       final double firstChildScrollOffset =
  //           earliestScrollOffset - paintExtentOf(firstChild!);
  //       final MySliverMultiBoxAdaptorParentData childParentData =
  //           firstChild!.parentData! as MySliverMultiBoxAdaptorParentData;
  //       childParentData.layoutOffset = 0.0;
  //       // We only need to correct if the leading child actually has a
  //       // paint extent.
  //       if (firstChildScrollOffset < -precisionErrorTolerance) {
  //         geometry = SliverGeometry(
  //           scrollOffsetCorrection: -firstChildScrollOffset,
  //         );
  //         return;
  //       }
  //     }
  //   }

  //   // At this point, earliestUsefulChild is the first child, and is a child
  //   // whose scrollOffset is at or before the scrollOffset, and
  //   // leadingChildWithLayout and trailingChildWithLayout are either null or
  //   // cover a range of render boxes that we have laid out with the first being
  //   // the same as earliestUsefulChild and the last being either at or after the
  //   // scroll offset.

  //   assert(earliestUsefulChild == firstChild);
  //   assert(childScrollOffset(earliestUsefulChild!)! <= scrollOffset);

  //   // Make sure we've laid out at least one child.
  //   if (leadingChildWithLayout == null) {
  //     earliestUsefulChild!.layout(childConstraints, parentUsesSize: true);
  //     leadingChildWithLayout = earliestUsefulChild;
  //     trailingChildWithLayout = earliestUsefulChild;
  //   }

  //   // Here, earliestUsefulChild is still the first child, it's got a
  //   // scrollOffset that is at or before our actual scrollOffset, and it has
  //   // been laid out, and is in fact our leadingChildWithLayout. It's possible
  //   // that some children beyond that one have also been laid out.

  //   bool inLayoutRange = true;
  //   RenderBox? child = earliestUsefulChild;
  //   int index = indexOf(child!);
  //   double endScrollOffset = childScrollOffset(child)! + paintExtentOf(child);
  //   bool advance() {
  //     // returns true if we advanced, false if we have no more children
  //     // This function is used in two different places below, to avoid code duplication.
  //     assert(child != null);
  //     if (child == trailingChildWithLayout) {
  //       inLayoutRange = false;
  //     }
  //     child = childAfter(child!);
  //     if (child == null) {
  //       inLayoutRange = false;
  //     }
  //     index += 1;
  //     if (!inLayoutRange) {
  //       if (child == null || indexOf(child!) != index) {
  //         // We are missing a child. Insert it (and lay it out) if possible.
  //         child = insertAndLayoutChildOriginal(
  //           childConstraints,
  //           after: trailingChildWithLayout,
  //           parentUsesSize: true,
  //         );
  //         if (child == null) {
  //           // We have run out of children.
  //           return false;
  //         }
  //       } else {
  //         // Lay out the child.
  //         child!.layout(childConstraints, parentUsesSize: true);
  //       }
  //       trailingChildWithLayout = child;
  //     }
  //     assert(child != null);
  //     final MySliverMultiBoxAdaptorParentData childParentData =
  //         child!.parentData! as MySliverMultiBoxAdaptorParentData;
  //     childParentData.layoutOffset = endScrollOffset;
  //     assert(childParentData.index == index);
  //     endScrollOffset = childScrollOffset(child!)! + paintExtentOf(child!);
  //     return true;
  //   }

  //   // Find the first child that ends after the scroll offset.
  //   while (endScrollOffset < scrollOffset) {
  //     leadingGarbage += 1;
  //     if (!advance()) {
  //       assert(leadingGarbage == childCount);
  //       assert(child == null);
  //       // we want to make sure we keep the last child around so we know the end scroll offset
  //       collectGarbage(leadingGarbage - 1, 0);
  //       assert(firstChild == lastChild);
  //       final double extent =
  //           childScrollOffset(lastChild!)! + paintExtentOf(lastChild!);
  //       debugPrint('original: extent: extent');
  //       geometry = SliverGeometry(
  //         scrollExtent: extent,
  //         maxPaintExtent: extent,
  //       );
  //       return;
  //     }
  //   }

  //   // Now find the first child that ends after our end.
  //   while (endScrollOffset < targetEndScrollOffset) {
  //     if (!advance()) {
  //       reachedEnd = true;
  //       break;
  //     }
  //   }

  //   // Finally count up all the remaining children and label them as garbage.
  //   if (child != null) {
  //     child = childAfter(child!);
  //     while (child != null) {
  //       trailingGarbage += 1;
  //       child = childAfter(child!);
  //     }
  //   }

  //   // At this point everything should be good to go, we just have to clean up
  //   // the garbage and report the geometry.

  //   collectGarbage(leadingGarbage, trailingGarbage);

  //   assert(debugAssertChildListIsNonEmptyAndContiguous());
  //   final double estimatedMaxScrollOffset;
  //   if (reachedEnd) {
  //     estimatedMaxScrollOffset = endScrollOffset;
  //   } else {
  //     estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
  //       constraints,
  //       firstIndex: indexOf(firstChild!),
  //       lastIndex: indexOf(lastChild!),
  //       leadingScrollOffset: childScrollOffset(firstChild!),
  //       trailingScrollOffset: endScrollOffset,
  //     );
  //     assert(estimatedMaxScrollOffset >=
  //         endScrollOffset - childScrollOffset(firstChild!)!);
  //   }
  //   final double paintExtent = calculatePaintOffset(
  //     constraints,
  //     from: childScrollOffset(firstChild!)!,
  //     to: endScrollOffset,
  //   );
  //   final double cacheExtent = calculateCacheOffset(
  //     constraints,
  //     from: childScrollOffset(firstChild!)!,
  //     to: endScrollOffset,
  //   );

  //   final double targetEndScrollOffsetForPaint =
  //       constraints.scrollOffset + constraints.remainingPaintExtent;

  //   final hasVisualOverflow = endScrollOffset > targetEndScrollOffsetForPaint ||
  //       constraints.scrollOffset > 0.0;

  //   geometry = SliverGeometry(
  //     scrollExtent: estimatedMaxScrollOffset,
  //     paintExtent: paintExtent,
  //     cacheExtent: cacheExtent,
  //     maxPaintExtent: estimatedMaxScrollOffset,
  //     // Conservative to avoid flickering away the clip during scroll.
  //     hasVisualOverflow: hasVisualOverflow,
  //   );

  //   debugPrint(
  //       'original estimatedMaxScrollOffset $estimatedMaxScrollOffset paintExtent: $paintExtent $cacheExtent $estimatedMaxScrollOffset hasVisualOverflow $hasVisualOverflow estimatedMaxScrollOffset == endScrollOffset ${estimatedMaxScrollOffset == endScrollOffset}');

  //   // We may have started the layout while scrolled to the end, which would not
  //   // expose a new child.
  //   if (estimatedMaxScrollOffset == endScrollOffset) {
  //     childManager.setDidUnderflow(true);
  //   }
  //   childManager.didFinishLayout();
  // }
}
