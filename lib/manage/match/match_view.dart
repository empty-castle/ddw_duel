import 'package:ddw_duel/manage/match/match_bracket_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MatchView extends StatefulWidget {
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.white24, width: 1))),
                  child: const Center(
                    child: Text("라운드 & 버튼"),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        MatchBracketComponent(),
                        MatchBracketComponent(),
                        MatchBracketComponent()
                      ],
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      left: BorderSide(color: Colors.white24, width: 1))),
              child: const Center(
                child: Text("팀 순위"),
              ),
            ))
      ],
    );
  }
}
