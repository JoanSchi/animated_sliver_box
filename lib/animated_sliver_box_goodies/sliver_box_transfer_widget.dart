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

import 'package:flutter/widgets.dart';
import '../animated_sliver_box.dart';
import '../sliver_row_box_model.dart';
import '../src/sliver_box_scale_size_transition.dart';

class SliverBoxTransferWidget extends StatelessWidget {
  final Animation? animation;
  final Widget child;
  final BoxItemProperties boxItemProperties;
  final SingleBoxModel singleBoxModel;
  final AnimatedSliverBoxModel model;

  const SliverBoxTransferWidget({
    required Key key,
    required this.singleBoxModel,
    required this.model,
    required this.boxItemProperties,
    required this.child,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final a = animation;

    if (boxItemProperties.single) {
      return SingleAnimatedItem(
        singleBoxModel: singleBoxModel,
        model: model,
        properties: boxItemProperties,
        child: child,
      );
    } else if ((boxItemProperties.transitionStatus ==
                BoxItemTransitionState.disappear ||
            boxItemProperties.transitionStatus ==
                BoxItemTransitionState.insert ||
            boxItemProperties.transitionStatus ==
                BoxItemTransitionState.remove) &&
        a != null) {
      return AnimatedBuilder(
          animation: a,
          child: child,
          builder: (BuildContext context, Widget? child) {
            return SliverBoxScaleResized(
                sliverBoxItemProperties: boxItemProperties,
                forwardValue: a.value,
                child: child);
          });
    } else if (boxItemProperties.transitionStatus ==
        BoxItemTransitionState.invisible) {
      return const SizedBox.shrink();
    } else {
      return child;
    }
  }
}

// class MultiSliverItemRowAnimation extends AnimatedWidget {
//   final Widget child;

//   const MultiSliverItemRowAnimation({
//     super.key,
//     required super.listenable,
//     required this.child,
//   });

//   Animation<double> get _progress => listenable as Animation<double>;

//   @override
//   Widget build(BuildContext context) {
//     return ScaleResized(sliverBoxItemProperties: sta,forwardAnimation: _progress.value, child: child);
//   }
// }

class SingleAnimatedItem extends StatefulWidget {
  final BoxItemProperties properties;
  final Widget child;
  final SingleBoxModel singleBoxModel;
  final AnimatedSliverBoxModel model;

  const SingleAnimatedItem({
    Key? key,
    required this.properties,
    required this.child,
    required this.model,
    required this.singleBoxModel,
  }) : super(key: key);

  @override
  State<SingleAnimatedItem> createState() => _SingleAnimatedItemState();
}

class _SingleAnimatedItemState extends State<SingleAnimatedItem>
    with SingleTickerProviderStateMixin {
  bool _transition = false;
  late AnimationController controller = AnimationController(
      value: widget.properties.transitionStatus == BoxItemTransitionState.insert
          ? 0.0
          : 1.0,
      vsync: this,
      duration: const Duration(milliseconds: 200))
    ..addListener(() {
      if (animation.value == 0.0) {
      } else {
        setState(() {});
      }
    });

  late Animation animation =
      controller.drive(CurveTween(curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    checkAnimation();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SingleAnimatedItem oldWidget) {
    checkAnimation();
    super.didUpdateWidget(oldWidget);
  }

  checkAnimation() {
    switch (widget.properties.transitionStatus) {
      case BoxItemTransitionState.insert:
        changeTransition(true);
        if (controller.status != AnimationStatus.forward) {
          controller.forward().then((value) {
            changeTransition(false);
            widget.properties
              ..transitionStatus = BoxItemTransitionState.visible
              ..single = false;
          });
        }
        break;
      case BoxItemTransitionState.disappear:
        if (controller.status != AnimationStatus.reverse) {
          changeTransition(true);
          controller.reverse().then((value) {
            changeTransition(false);
            widget.properties
              ..transitionStatus = BoxItemTransitionState.invisible
              ..single = false;
          });
        }
        break;
      case BoxItemTransitionState.remove:
        changeTransition(true);
        if (controller.status != AnimationStatus.reverse) {
          controller.reverse().then((value) {
            changeTransition(false);
            widget.model
                .individualRemoval(widget.singleBoxModel, widget.properties);
          });
        }
        break;
      default:
        {}
    }
  }

  @override
  void dispose() {
    changeTransition(false);
    controller.dispose();
    super.dispose();
  }

  void changeTransition(bool transition) {
    if (transition && !_transition) {
      _transition = true;
      widget.singleBoxModel.individualTransition++;
    } else if (!transition && _transition) {
      _transition = false;
      widget.singleBoxModel.individualTransition--;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleResized(value: controller.value, child: widget.child);
  }
}
