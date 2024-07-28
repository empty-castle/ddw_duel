import 'package:ddw_duel/provider/game_provider.dart';
import 'package:ddw_duel/view/manage/bracket/bracket_game_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BracketComponent extends StatefulWidget {
  const BracketComponent({super.key});

  @override
  State<BracketComponent> createState() => _BracketComponentState();
}

class _BracketComponentState extends State<BracketComponent> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
        builder: (context, provider, child) {
          return Column(
            children: provider.gameMap.values.map((game) {
              return BracketGameComponent(game: game,);
            }).toList(),
          );
        }
    );
  }
}
