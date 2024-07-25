import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/provider/team_provider.dart';
import 'package:ddw_duel/view/manage/match/match_round_component.dart';
import 'package:ddw_duel/view/manage/match/match_team_ranking_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Consumer<SelectedEventProvider>(
                              builder: (context, provider, child) {
                                List<Widget> roundButtons =
                                    _makeRoundButtons(provider);
                                return Row(
                                  children: roundButtons,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    '집계',
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text(
                                  '라운드 생성',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MatchRoundComponent(),
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
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: MatchTeamRankingComponent(),
              ),
            ))
      ],
    );
  }

  List<Widget> _makeRoundButtons(SelectedEventProvider provider) {
    List<Widget> roundButtons = [];
    for (int i = 1; i <= provider.selectedEvent!.currentRound; i++) {
      roundButtons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: OutlinedButton(
            onPressed: () {
              // todo
            },
            child: Text(
              i == provider.selectedEvent!.currentRound
                  ? '$i라운드(진행 중)'
                  : '$i라운드',
            ),
          ),
        ),
      );
    }
    return roundButtons;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    List<Team> teams = Provider.of<TeamProvider>(context).teams;
    Provider.of<RankProvider>(context, listen: false).makeRankedTeams(teams, 0);
  }
}
