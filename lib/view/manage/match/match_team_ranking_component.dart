import 'package:flutter/material.dart';

class MatchTeamRankingComponent extends StatefulWidget {
  const MatchTeamRankingComponent({super.key});

  @override
  State<MatchTeamRankingComponent> createState() =>
      _MatchTeamRankingComponentState();
}

class _MatchTeamRankingComponentState extends State<MatchTeamRankingComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        teamContainer(),
        teamContainer(),
        teamContainer(),
        teamContainer()
      ],
    );
  }

  Widget teamContainer() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white38, width: 1))),
      child: Row(
        children: [
          Container(
              decoration: const BoxDecoration(
                color: Color(0x3DEFB7FF),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('#1'),
              )),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('55 point'),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('팀A'),
          ),
        ],
      ),
    );
  }
}
