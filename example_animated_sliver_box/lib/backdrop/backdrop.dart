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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backdrop_state.dart';

class Backdrop extends ConsumerStatefulWidget {
  final Widget body;
  final Widget appBar;
  final Widget back;

  const Backdrop(
      {super.key,
      required this.body,
      required this.appBar,
      required this.back});

  @override
  ConsumerState<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends ConsumerState<Backdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _easyInOutAnimation;

  bool backVisible = false;
  bool tapBackEnabled = false;

  @override
  void initState() {
    bool drop = ref.read(dropBackdropProvider);
    _animationController = AnimationController(
        value: drop ? 1.0 : 0.0,
        vsync: this,
        duration: const Duration(milliseconds: 200))
      ..addStatusListener((status) {
        bool oldBackVisible = backVisible;
        bool oldTapBack = tapBackEnabled;
        if (status == AnimationStatus.dismissed) {
          backVisible = false;
          tapBackEnabled = false;
        } else if (status == AnimationStatus.completed) {
          backVisible = true;
          tapBackEnabled = true;
        } else {
          backVisible = true;
          tapBackEnabled = false;
        }
        if (oldBackVisible != backVisible || oldTapBack != tapBackEnabled) {
          setState(() {});
        }
      });
    super.initState();

    _easyInOutAnimation =
        CurveTween(curve: Curves.easeInOut).animate(_animationController.view);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dropBackdropProvider, (previous, next) {
      setState(() {
        if (next) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints contraints) {
        final layerHeight = contraints.maxHeight;
        const appBarSize = 56.0;

        Animation<RelativeRect> layerAnimation = RelativeRectTween(
          begin: const RelativeRect.fromLTRB(0.0, appBarSize, 0.0, 0.0),
          end: RelativeRect.fromLTRB(0.0, layerHeight - appBarSize, 0.0, 0.0),
        ).animate(_animationController.view);

        return Stack(
          children: [
            Positioned(
                key: const Key('appbar'),
                left: 0.0,
                top: 0.0,
                right: 0.0,
                height: appBarSize,
                child: widget.appBar),
            if (backVisible)
              Positioned(
                key: const Key('back'),
                left: 0.0,
                top: appBarSize,
                right: 0.0,
                bottom: appBarSize,
                child: AnimatedBuilder(
                    animation: _easyInOutAnimation,
                    builder: ((context, child) => Opacity(
                        opacity: _easyInOutAnimation.value, child: child)),
                    child: widget.back),
              ),
            PositionedTransition(
              key: const Key('body'),
              rect: layerAnimation,
              child: widget.body,
            ),
            if (tapBackEnabled)
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  height: appBarSize,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint('geiig ${_animationController.value}');
                      ref.read(dropBackdropProvider.notifier).state = false;
                    },
                  ))
          ],
        );
      },
    );
  }
}
