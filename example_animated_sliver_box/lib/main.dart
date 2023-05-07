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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'about.dart';
import 'backdrop/back.dart';
import 'backdrop/backdrop.dart';
import 'backdrop/backdrop_appbar.dart';
import 'animal_box_panel.dart';

// Web:
// CanvasKit threw an exception while laying out the paragraph. The font was "MaterialIcons" #120977
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliverRowBox',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color.fromARGB(255, 17, 85, 114),
            onPrimary: Color(0xFFFFFFFF),
            primaryContainer: Color(0xFFf1f5fd),
            onPrimaryContainer: Color.fromARGB(255, 5, 66, 92),
            secondary: Color(0xFF625B71),
            onSecondary: Color(0xFFFFFFFF),
            secondaryContainer:
                Color.fromARGB(255, 174, 188, 193), //Color(0xFFE8DEF8),
            onSecondaryContainer: Color.fromARGB(255, 5, 66, 92),
            tertiary: Color(0xFF7E5260),
            onTertiary: Color(0xFFFFFFFF),
            tertiaryContainer: Color(0xFFFFD9E3),
            onTertiaryContainer: Color(0xFF31101D),
            error: Color(0xFFBA1A1A),
            errorContainer: Color(0xFFFFDAD6),
            onError: Color(0xFFFFFFFF),
            onErrorContainer: Color(0xFF410002),
            background: Colors.white, // Color(0xFFFFFBFF),
            onBackground: Color(0xFF1C1B1E),
            surface: Color.fromARGB(255, 246, 250, 253),
            //onSurface: Text, icons
            onSurface: Color.fromARGB(255, 3, 50, 71),
            surfaceVariant: Color(0xFFE7E0EB),
            onSurfaceVariant: Color(0xFF49454E),
            outline: Color(0xFF7A757F),
            onInverseSurface: Color(0xFFF4EFF4),
            inverseSurface: Color(0xFF313033),
            inversePrimary: Color(0xFF70b7d3),
            shadow: Color(0xFF000000),
            //surfaceTint: Tint background calendar
            surfaceTint: Color(0xFF70b7d3),
            //outlineVariant: Divider
            outlineVariant: Color(0xFFCAC4CF),
            scrim: Color(0xFF000000),
          )),
      home: const MyHomePage(title: 'SliverRowBox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200));

  bool useSwipe = false;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: MyScrollBehavior(useSwipe),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 247, 250, 241),
          body: SafeArea(
            child: Backdrop(
              appBar: const BackDropAppbar(),
              back: const Center(
                child: SizedBox(
                  width: 900.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Back(),
                  ),
                ),
              ),
              body: Material(
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36.0),
                      topRight: Radius.circular(36.0)),
                ),
                color: const Color.fromARGB(255, 104, 135, 43),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TabBar(
                          labelColor: const Color.fromARGB(255, 247, 250, 241),
                          unselectedLabelColor:
                              const Color.fromARGB(255, 202, 211, 184),
                          indicatorColor:
                              const Color.fromARGB(255, 247, 250, 241),
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Animals A-Z'),
                            Tab(text: 'About')
                          ]),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: SizedBox(
                                width: 900.0,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(36.0)),
                                    child: CustomScrollView(
                                      slivers: [
                                        if (defaultTargetPlatform !=
                                                TargetPlatform.android &&
                                            defaultTargetPlatform !=
                                                TargetPlatform.iOS)
                                          SliverToBoxAdapter(
                                              child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              32.0)),
                                                  child: SizedBox(
                                                      height: 120.0,
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(
                                                            height: 16.0,
                                                          ),
                                                          const Center(
                                                              child: Text(
                                                            'Option',
                                                            style: TextStyle(
                                                                fontSize: 24.0),
                                                          )),
                                                          Row(
                                                            children: [
                                                              Checkbox(
                                                                  value:
                                                                      useSwipe,
                                                                  onChanged:
                                                                      (bool?
                                                                          value) {
                                                                    setState(
                                                                        () {
                                                                      useSwipe =
                                                                          value ??
                                                                              false;
                                                                    });
                                                                  }),
                                                              const Text(
                                                                  'use swipe/swing instead of scrollbar.')
                                                            ],
                                                          )
                                                        ],
                                                      )))),
                                        const SliverToBoxAdapter(
                                            child: SizedBox(
                                          height: 10.0,
                                        )),
                                        const AnimalsAtoZ()
                                      ],
                                    )),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: SizedBox(width: 900.0, child: About())),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {},
          //   tooltip: 'Add items',
          //   child: const Icon(Icons.add),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}

class MyScrollBehavior extends MaterialScrollBehavior {
  final bool useSwipe;

  const MyScrollBehavior(this.useSwipe);

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
}
