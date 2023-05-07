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

import 'sliver_box_scale_size_transition.dart';

typedef SliverBoxAbSwitcherBuilder = Widget Function({
  required BuildContext context,
  required Widget firstWidget,
  required Widget secondWidget,
  required Animation<double> firstAnimation,
  required Animation<double> secondAnimation,
});

Widget defaultSliverBoxAbResizeSwitcherBuilder({
  required BuildContext context,
  required Widget firstWidget,
  required Widget secondWidget,
  required Animation<double> firstAnimation,
  required Animation<double> secondAnimation,
}) {
  Widget first;
  Widget second;

  switch (firstAnimation.status) {
    case AnimationStatus.dismissed:
      {
        second = const SizedBox.shrink();
        first = firstWidget;
        break;
      }
    case AnimationStatus.reverse:
      {
        second = SliverBoxScaleResizedTransition(
            key: const Key('second'),
            listenable: secondAnimation,
            child: secondWidget);
        first = SliverBoxScaleResizedTransition(
            key: const Key('first'),
            listenable: firstAnimation,
            child: firstWidget);
        break;
      }
    case AnimationStatus.forward:
      {
        second = SliverBoxScaleResizedTransition(
            key: const Key('first'),
            listenable: firstAnimation,
            child: firstWidget);
        first = SliverBoxScaleResizedTransition(
            key: const Key('second'),
            listenable: secondAnimation,
            child: secondWidget);
        break;
      }
    case AnimationStatus.completed:
      {
        second = secondWidget;
        first = const SizedBox.shrink();
        break;
      }
  }

  return Stack(
    children: [first, second],
  );
}

class SliverBoxResizeAbSwitcher extends StatefulWidget {
  final Duration duration;
  final Widget first;
  final Widget second;
  final VoidCallback stateChange;
  final CrossFadeState crossFadeState;
  final Tween<double>? firstTween;
  final Tween<double>? secondTween;
  final SliverBoxAbSwitcherBuilder sliverBoxAbSwitcherBuilder;

  const SliverBoxResizeAbSwitcher({
    super.key,
    required this.first,
    required this.second,
    required this.crossFadeState,
    this.sliverBoxAbSwitcherBuilder = defaultSliverBoxAbResizeSwitcherBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.firstTween,
    this.secondTween,
    required this.stateChange,
  });

  @override
  State<SliverBoxResizeAbSwitcher> createState() =>
      _SliverBoxResizeAbSwitcherState();
}

class _SliverBoxResizeAbSwitcherState extends State<SliverBoxResizeAbSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> firstAnimation;
  late final Animation<double> secondAnimation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
        value: widget.crossFadeState == CrossFadeState.showFirst ? 1.0 : 0.0)
      ..addStatusListener(_handleStateChange)
      ..addListener(_handleChange);

    if (widget.crossFadeState == CrossFadeState.showFirst) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    firstAnimation = widget.firstTween?.animate(_controller) ??
        _initAnimation(Curves.easeInOut, true);
    secondAnimation = widget.secondTween?.animate(_controller) ??
        _initAnimation(Curves.easeInOut, false);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SliverBoxResizeAbSwitcher oldWidget) {
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    if (widget.firstTween != oldWidget.firstTween) {
      firstAnimation = widget.firstTween?.animate(_controller) ??
          _initAnimation(Curves.easeInOut, true);
    }

    if (widget.secondTween != oldWidget.secondTween) {
      firstAnimation = widget.secondTween?.animate(_controller) ??
          _initAnimation(Curves.easeInOut, false);
    }

    if (widget.crossFadeState != oldWidget.crossFadeState) {
      if (widget.crossFadeState == CrossFadeState.showFirst) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleStateChange)
      ..removeListener(_handleChange)
      ..dispose();
    super.dispose();
  }

  Animation<double> _initAnimation(Curve curve, bool inverted) {
    Animation<double> result = _controller.drive(CurveTween(curve: curve));
    if (inverted) {
      result = result.drive(Tween<double>(begin: 1.0, end: 0.0));
    }
    return result;
  }

  void _handleStateChange(AnimationStatus status) {
    if (status == AnimationStatus.dismissed ||
        status == AnimationStatus.completed) {
      widget.stateChange();
    }
  }

  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.sliverBoxAbSwitcherBuilder(
        context: context,
        firstWidget: widget.first,
        secondWidget: widget.second,
        firstAnimation: firstAnimation,
        secondAnimation: secondAnimation);
  }
}
