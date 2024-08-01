import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/game_provider.dart';
import 'package:ddw_duel/provider/rank_provider.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/manage/round/model/rank_team_model.dart';
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
  final TeamRepository teamRepo = TeamRepository();

  int? _currentRound;

  late Future<void> _future;

  void _onPressedScoring() {
    RoundModel roundModel =
        Provider.of<RoundProvider>(context, listen: false).round!;
    if (!_validateDuelsInGameModels(roundModel.gameModels)) {
      SnackbarHelper.showErrorSnackbar(context, '모든 경기의 결과를 입력해주세요.');
      return;
    }
    aggregatePoints(roundModel.entryMap, roundModel.gameModels);

    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;
    selectedEvent.endRound = _currentRound!;
    eventRepo.saveEvent(selectedEvent);

    setState(() {
      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;
      _future = _fetchData(eventId, _currentRound!);
    });
  }

  void aggregatePoints(
      Map<int, EntryModel> entryMap, List<GameModel> gameModels) {
    for (var gameModel in gameModels) {
      double team1TotalPoints = 0.0;
      double team2TotalPoints = 0.0;

      for (var duel in gameModel.duels) {
        team1TotalPoints += duel.player1Point;
        team2TotalPoints += duel.player2Point;
      }

      gameModel.game.team1Point = team1TotalPoints;
      gameModel.game.team2Point = team2TotalPoints;

      gameRepo.saveGame(gameModel.game);

      Team team1 = entryMap[gameModel.game.team1Id]!.team;
      Team team2 = entryMap[gameModel.game.team2Id]!.team;

      team1.point = team1.point + team1TotalPoints;
      team2.point = team2.point + team2TotalPoints;

      teamRepo.saveTeam(team1);
      teamRepo.saveTeam(team2);
    }
  }

  bool _validateDuelsInGameModels(List<GameModel> gameModels) {
    for (var gameModel in gameModels) {
      if (gameModel.duels.length != 2) {
        return false;
      }
    }
    return true;
  }

  void _onPressedNewRound() {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;
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
    List<RankTeamModel> rankedTeams =
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

  Future<void> _fetchData(int eventId, int currentRound) async {
    await Provider.of<RoundProvider>(context, listen: false)
        .fetchRound(eventId, currentRound);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Row(
          children: [
            Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.white24, width: 1))),
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
                                      onPressed: _onPressedScoring,
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
      },
    );
  }

  List<Widget> _makeRoundButtons(SelectedEventProvider provider) {
    List<Widget> roundButtons = [];
    for (int i = 1; i <= provider.selectedEvent!.currentRound; i++) {
      roundButtons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: i == _currentRound
              ? FilledButton(
                  onPressed: () => _onPressedChangeRound(i),
                  child: _makeRoundButtonText(i, provider.selectedEvent!),
                )
              : OutlinedButton(
                  onPressed: () => _onPressedChangeRound(i),
                  child: _makeRoundButtonText(i, provider.selectedEvent!),
                ),
        ),
      );
    }
    return roundButtons;
  }

  Text _makeRoundButtonText(int i, Event event) {
    return Text(i <= event.endRound ? '$i라운드(완료)' : '$i라운드(진행 중)');
  }

  void _onPressedChangeRound(int round) {
    setState(() {
      _currentRound = round;
      Event event = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!;
      _future = _fetchData(event.eventId!, round);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Event event = Provider.of<SelectedEventProvider>(context).selectedEvent!;
    _currentRound = event.currentRound;
    _future = _fetchData(event.eventId!, event.currentRound);
  }
}
