import 'dart:io';

import 'package:ddw_duel/provider/duel_provider.dart';
import 'package:ddw_duel/provider/event_provider.dart';
import 'package:ddw_duel/provider/player_provider.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:ddw_duel/provider/game_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/provider/selected_team_provider.dart';
import 'package:ddw_duel/provider/team_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';

import 'view/event/event_view.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1600, 900));
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => SelectedEventProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => PlayerProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => TeamProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => SelectedTeamProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => RankProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => DuelProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DDW duel',
      theme: FlexThemeData.light(
        scheme: FlexScheme.materialHc,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          inputDecoratorIsFilled: false,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          outlinedButtonRadius: 0.0,
          filledButtonRadius: 0.0,
          elevatedButtonRadius: 0.0,
          textButtonRadius: 0.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.materialHc,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          inputDecoratorIsFilled: false,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          outlinedButtonRadius: 0.0,
          filledButtonRadius: 0.0,
          elevatedButtonRadius: 0.0,
          textButtonRadius: 0.0,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'DDW duel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _selectedPage = const EventView();

  void _updateBody(Widget newPage) {
    setState(() {
      _selectedPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(children: [
            Text(widget.title),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _updateBody(const EventView());
                    },
                    child: const Text("이벤트",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          ]),
        ),
        body: _selectedPage);
  }
}
