import 'package:ddw_duel/view/manage/match/match_bracket_component.dart';
import 'package:flutter/material.dart';

class MatchRoundComponent extends StatefulWidget {
  const MatchRoundComponent({super.key});

  @override
  State<MatchRoundComponent> createState() => _MatchRoundComponentState();
}

class _MatchRoundComponentState extends State<MatchRoundComponent> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MatchBracketComponent(),
        MatchBracketComponent(),
        MatchBracketComponent()
      ],
    );
  }
}
