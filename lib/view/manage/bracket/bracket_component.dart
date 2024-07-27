import 'package:ddw_duel/provider/round_provider.dart';
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
    return Consumer<RoundProvider>(
        builder: (context, provider, child) {
          return Column(
            children: provider.games.map((game) {
              return BracketGameComponent(game: game,);
            }).toList(),
          );
        }
    );
  }
}
