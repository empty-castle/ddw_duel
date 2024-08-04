import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/view/manage/round/bracket_game_component.dart';
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
    return Consumer<RoundProvider>(builder: (context, provider, child) {
      RoundModel roundModel = provider.round!;
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: roundModel.gameModels.map((gameModel) {
            return BracketGameComponent(
              gameModel: gameModel,
              entryA: roundModel.entryMap[gameModel.game.team1Id],
              entryB: roundModel.entryMap[gameModel.game.team2Id],
            );
          }).toList(),
        ),
      );
    });
  }
}
