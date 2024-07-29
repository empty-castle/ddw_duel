import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/provider/game_provider.dart';
import 'package:ddw_duel/provider/model/rank_team.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/provider/team_provider.dart';
import 'package:ddw_duel/view/manage/round/team_ranking_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bracket_component.dart';

class RoundView extends StatefulWidget {
  const RoundView({super.key});

  @override
  State<RoundView> createState() => _RoundViewState();
}

class _RoundViewState extends State<RoundView> {
  final EventRepository eventRepo = EventRepository();
  final GameRepository gameRepo = GameRepository();
  final DuelRepository duelRepo = DuelRepository();

  void _onPressedNewRound() {
    Event selectedEvent = Provider.of<SelectedEventProvider>(context, listen: false).selectedEvent!;
    _createNewRound(selectedEvent);
    _createBracket(selectedEvent);
  }

  void _createNewRound(Event selectedEvent) {
    selectedEvent.currentRound = selectedEvent.currentRound + 1;
    eventRepo.updateEvent(selectedEvent);
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(selectedEvent);
  }

  void _createBracket(Event selectedEvent) {
    List<RankTeam> rankedTeams =
        Provider.of<RankProvider>(context, listen: false).rankedTeams;
    List<Game> games = [];
    for (int i = 0; i < rankedTeams.length; i += 2) {
      if (i + 1 < rankedTeams.length) {
        Team team1 = rankedTeams[i].team;
        Team team2 = rankedTeams[i + 1].team;
        games.add(Game(
          eventId: selectedEvent.eventId!,
          round: selectedEvent.currentRound,
          team1Id: team1.teamId!,
          team2Id: team2.teamId!,
        ));
      }
    }
    // todo games 저장한 다음에 id 가 부여되니까 다시 games 를 받아와야 한다
    gameRepo.saveAllGame(games);
    Provider.of<GameProvider>(context, listen: false).setGames(games);
  }

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
                              ElevatedButton(
                                onPressed: _onPressedNewRound,
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
                    child: BracketComponent(),
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
                child: TeamRankingComponent(),
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

    Event selectedEvent = Provider.of<SelectedEventProvider>(context, listen: false).selectedEvent!;
    Provider.of<GameProvider>(context, listen: false).fetchGames(selectedEvent);
  }
}
