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

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    const headerSize = 20.0;
    const paragraphSize = 18.0;

    return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 250, 241),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(children: [
              const Center(
                  child: Text('About', style: TextStyle(fontSize: 24.0))),
              const SizedBox(
                height: 12.0,
              ),
              RichText(
                  text: const TextSpan(
                text:
                    'AnimatedSliverBox is used with CustomScrollView and is controlled with a model to insert, remove, appear or disappear the sliver. '
                    'To keep animation smoothly, only the visible items are animated by removing the invisible items, unless otherwise indicated. '
                    'For example the bottom of the "box with rounded corners" is not visible, but will be visible during the appeares and disappeares. '
                    'The position of the first visible child is saved during layout. This makes a correction of the scrolloffset posible if children are removed above the first visible child. '
                    'In this way the user will not be disorientated, to indicate a change the scrollview is sligthy moved. '
                    'To accomplisch this, the performlayout of the SliverList is redesigned and is called FlexSizeSliver and this render use a model, with the following characteristics:\n'
                    '- The offset of the first visible child is saved during the layout.\n'
                    '- If the size is known of the child, the FlexSizeSliver can unlike the SliverList skip the layout. In a webpage with a long list and scrollbars the layout can skip children for a faster layout.\n'
                    '- The model use a property object for each child. the property object is used for holden the size, useSizeOfChild, animateOutside, transitionState, innerTransition, values, panel state, use, animation status or whatever the user like by extending the class.\n'
                    '- If the item is garbage collected the property is notified, depending what the user likes to do it is possible for example to set the item to the default panel if the edit panel is large or a heavy widget.\n'
                    '- If desired SliverRowBox also contains a callback to ignore the pointer during the animation. During the appearence the children below the view, are added later. This is not noticed unless the user scrolls down, denpending on the duration it is not likely that the user is fast enough.\n'
                    '- The model is divided in submodels, for example a top, one or more middle list and a bottom. Also the list can be replace by another, with an animation, if the list is for example date depended or sorted, or you can use it like a alternive for tabbar in slivers.\n'
                    '- The model will give a feedback if an action is prevented by a running animation for example.\n'
                    '- The model can use group and single animations, single animations are not blocked.\n',
                style: TextStyle(fontSize: paragraphSize, color: Colors.black),
                children: [
                  TextSpan(
                      text: '\n\nIntention',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nThe intention is to use only StatelessWidgets to make the scroll as ligthweigted as possible. For an insertion/delete or panel switch a StatefullWidget is inserted. Depending on the widget StateFullWidget is removed by setstate or garbage collecting during the scroll.'),
                  TextSpan(
                      text: '\n\nGoodies',
                      style: TextStyle(
                          fontSize: headerSize, color: Color(0xFF80ba27))),
                  TextSpan(
                      text:
                          '\nThe package contains some goodies. For example to animate the resize for the insert and removal of the widget or to switch from panel. Als a background is included to simulate a box, the background slighty overlaps each other, otherwise sometimes a thin line is sometimes visible.'),
                ],
              )),
            ])));
  }
}
