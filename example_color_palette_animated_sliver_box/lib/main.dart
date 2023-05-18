import 'package:example_color_palette_animated_sliver_box/color_palette_items.dart';
import 'package:example_color_palette_animated_sliver_box/color_palette_items_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'box_properties.dart';
import 'options.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Color Palette A. SliverBox'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final options = ref.watch(colorPaletteProvider);
    final center = options.center;

    Widget scrollView = CustomScrollView(shrinkWrap: center, slivers: [
      options.axis == Axis.vertical
          ? ResizableItemsList(axis: options.axis)
          : horizontalScrollView(options.axis, center)
    ]);

    if (center) {
      scrollView = Center(
        child: scrollView,
      );
    }

    return ScrollConfiguration(
      behavior: const MyMaterialScrollBehavior(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ref.read(colorPaletteProvider.notifier).changeVisibility();
              },
              icon: options.visible
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off)),
          actions: [
            IconButton(
                onPressed: () {
                  ref.read(colorPaletteProvider.notifier).changedAxis();
                },
                icon: const Icon(Icons.screen_rotation_alt_sharp)),
          ],
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: scrollView,

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref.read(colorPaletteProvider.notifier).add();
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: const Options(),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  Widget horizontalScrollView(Axis axis, bool center) {
    Widget scrollView = CustomScrollView(
        shrinkWrap: center,
        scrollDirection: Axis.horizontal,
        slivers: [ResizableItemsList(axis: axis)]);

    if (center) {
      scrollView = Center(
        child: scrollView,
      );
    }

    return SliverToBoxAdapter(
        child: SizedBox(height: horizontalHeight, child: scrollView));
  }
}

class MyMaterialScrollBehavior extends ScrollBehavior {
  final bool useSwipe;

  const MyMaterialScrollBehavior({this.useSwipe = false});

  @override
  TargetPlatform getPlatform(BuildContext context) {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return platform;
      default:
        return useSwipe ? TargetPlatform.android : platform;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // When modifying this function, consider modifying the implementation in
    // the base class ScrollBehavior as well.
    switch (axisDirectionToAxis(details.direction)) {
      case Axis.horizontal:
      //Heel raar geen scrollbar
      // return child;
      case Axis.vertical:
        switch (getPlatform(context)) {
          case TargetPlatform.linux:
          case TargetPlatform.macOS:
          case TargetPlatform.windows:
            return Scrollbar(
              controller: details.controller,
              child: child,
            );
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.iOS:
            return child;
        }
    }
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // When modifying this function, consider modifying the implementation in
    // the base class ScrollBehavior as well.
    late final AndroidOverscrollIndicator indicator;
    if (Theme.of(context).useMaterial3) {
      indicator = AndroidOverscrollIndicator.stretch;
    } else {
      indicator = AndroidOverscrollIndicator.glow;
    }
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
        switch (indicator) {
          case AndroidOverscrollIndicator.stretch:
            return StretchingOverscrollIndicator(
              axisDirection: details.direction,
              clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
              child: child,
            );
          case AndroidOverscrollIndicator.glow:
            continue glow;
        }
      glow:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.secondary,
          child: child,
        );
    }
  }
}
