<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

 AnimatedSliverBox is used with CustomScrollView and is controlled with a model to insert, remove, appear or disappear the sliver. To keep animation smoothly, only the visible items are animated by removing the invisible items, unless otherwise indicated. For example the bottom of the "box with rounded corners" is not visible, but will be visible during the appeares and disappeares. The position of the first visible child is saved during layout. This makes a correction of the scrolloffset posible if children are removed above the first visible child. In this way the user will not be disorientated, to indicate a change the scrollview is sligthy moved. To accomplisch this, the performlayout of the SliverList is redesigned and is called FlexSizeSliver and this render use a model, with the following characteristics:
 - The offset of the first visible child is saved during the layout.'
 - If the size is known of the child, the FlexSizeSliver can unlike the SliverList skip the layout. In a webpage with a long list and scrollbars the layout can skip children for a faster layout.'
 - The model use a property object for each child. the property object is used for holden the size, useSizeOfChild, animateOutside, transitionState, innerTransition, values, panel state, use, animation status or whatever the user like by extending the class.'
 - If the item is garbage collected the property is notified, depending what the user likes to do it is possible for example to set the item to the default panel if the edit panel is large or a heavy widget.'
- If desired SliverRowBox also contains a callback to ignore the pointer during the animation. During the appearence the children below the view, are added later. This is not noticed unless the user scrolls down, denpending on the duration it is not likely that the user is fast enough.'
 - The model is divided in submodels, for example a top, one or more middle list and a bottom. Also the list can be replace by another, with an animation, if the list is for example date depended or you like a alternive for tabbar in slivers.'
 - The model will give a feedback if an action is prevented by a running animation for example.'
- The model can use group and single animations, single animations are not blocked.',

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
# animated_sliver_box
