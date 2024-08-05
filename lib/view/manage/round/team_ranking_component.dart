import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/view/manage/round/model/rank_team_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamRankingComponent extends StatefulWidget {
  const TeamRankingComponent({super.key});

  @override
  State<TeamRankingComponent> createState() => _TeamRankingComponentState();
}

class _TeamRankingComponentState extends State<TeamRankingComponent> {
  List<List<EntryModel>> _filteredEntryModel(Map<int, EntryModel> entryMap) {
    List<EntryModel> activeEntries = [];
    List<EntryModel> forfeitedEntries = [];

    for (var entry in entryMap.values) {
      if (entry.team.isForfeited == 1) {
        forfeitedEntries.add(entry);
      } else {
        activeEntries.add(entry);
      }
    }

    return [activeEntries, forfeitedEntries];
  }

  List<RankTeamModel> _makeRankedTeams(List<EntryModel> activeEntries) {
    List<RankTeamModel> rankedTeams = [];

    List<EntryModel> sortedEntries = activeEntries
      ..sort((a, b) => b.team.point.compareTo(a.team.point));

    int rank = 1;
    for (int i = 0; i < sortedEntries.length; i++) {
      if (i > 0 &&
          sortedEntries[i].team.point < sortedEntries[i - 1].team.point) {
        rank = i + 1;
      }
      rankedTeams.add(RankTeamModel(
        team: sortedEntries[i].team,
        rank: rank,
      ));
    }

    return rankedTeams;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoundProvider>(
      builder: (context, provider, child) {
        List<List<EntryModel>> filteredEntryModel =
            _filteredEntryModel(provider.round!.entryMap);
        List<RankTeamModel> rankedTeams =
            _makeRankedTeams(filteredEntryModel[0]);
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: rankedTeams.length,
                itemBuilder: (context, index) {
                  final team = rankedTeams[index].team;
                  final rank = rankedTeams[index].rank;
                  return teamContainer(team, rank);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('기권 팀', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredEntryModel[1].length,
                itemBuilder: (context, index) {
                  final entryModel = filteredEntryModel[1][index];
                  return teamContainer(entryModel.team, -1); // 기권한 팀
                },
              ),
            ),
          ],
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
                child: SizedBox(width: 32, child: Text('# $rank')),
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
