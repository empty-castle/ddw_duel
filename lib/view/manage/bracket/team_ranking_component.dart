import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamRankingComponent extends StatefulWidget {
  const TeamRankingComponent({super.key});

  @override
  State<TeamRankingComponent> createState() => _TeamRankingComponentState();
}

class _TeamRankingComponentState extends State<TeamRankingComponent> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RankProvider>(
      builder: (context, rankProvider, child) {
        return ListView.builder(
          itemCount: rankProvider.rankedTeams.length,
          itemBuilder: (context, index) {
            final team = rankProvider.rankedTeams[index].team;
            final rank = rankProvider.rankedTeams[index].rank;
            return teamContainer(team, rank);
          },
        );
      },
    );
  }

  Widget teamContainer(Team team, int rank) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white38, width: 1))),
      child: Row(
        children: [
          Container(
              decoration: const BoxDecoration(
                color: Color(0x3DEFB7FF),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(width: 36, child: Text('#$rank')),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${team.point} pts'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(team.name),
          ),
        ],
      ),
    );
  }
}
