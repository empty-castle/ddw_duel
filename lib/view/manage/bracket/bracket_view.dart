import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/domain/event/repository/event_repository.dart';
import 'package:ddw_duel/domain/game/domain/game.dart';
import 'package:ddw_duel/domain/game/repository/game_repository.dart';
import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/provider/model/RankTeam.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/provider/team_provider.dart';
import 'package:ddw_duel/view/manage/bracket/bracket_component.dart';
import 'package:ddw_duel/view/manage/bracket/team_ranking_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BracketView extends StatefulWidget {
  const BracketView({super.key});

  @override
  State<BracketView> createState() => _BracketViewState();
}

class _BracketViewState extends State<BracketView> {
  final EventRepository eventRepo = EventRepository();
  final GameRepository gameRepo = GameRepository();

  void _onPressedNewRound() {
    Event selectedEvent = Provider.of<SelectedEventProvider>(context, listen: false).selectedEvent!;
    _createNewRound(selectedEvent);
    _createBracket(selectedEvent);
    // todo 라운드 대진표 만드는 함수 돌리고 round_provider 에 set 하고 그걸 match_bracket_component 에서 빌드하고
    // todo team 에 히스토리를 만들어 넣어야 함. match 대진표에 따라서
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
    for (var game in games) {
      gameRepo.saveGame(game);
    }
    Provider.of<RoundProvider>(context, listen: false).setGames(games);
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
  }
}
