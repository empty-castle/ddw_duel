import 'dart:collection';

import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/round_repository_custom.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
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
  final RoundRepositoryCustom roundRepositoryCustom = RoundRepositoryCustom();
  final EventRepository eventRepo = EventRepository();
  final GameRepository gameRepo = GameRepository();
  final TeamRepository teamRepo = TeamRepository();

  int? _selectedRound;

  late Future<void> _future;

  void _onPressedScoring() async {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    await Provider.of<RoundProvider>(context, listen: false)
        .fetchRound(selectedEvent.eventId!, _selectedRound!);

    if (!mounted) return;

    RoundModel roundModel =
        Provider.of<RoundProvider>(context, listen: false).round!;
    if (!_validateDuelsInGameModels(roundModel.gameModels)) {
      SnackbarHelper.showErrorSnackbar(context, '모든 경기의 결과를 입력해주세요.');
      return;
    }
    aggregatePoints(roundModel.entryMap, roundModel.gameModels);

    selectedEvent.endRound = _selectedRound!;
    eventRepo.saveEvent(selectedEvent);

    setState(() {
      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;
      _future = _fetchData(eventId, _selectedRound!);
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

      Team? team1 = entryMap[gameModel.game.team1Id]?.team;
      Team? team2 = entryMap[gameModel.game.team2Id]?.team;

      if (team1 != null) {
        team1.point = team1.point + team1TotalPoints;
        teamRepo.saveTeam(team1);
      }

      if (team2 != null) {
        team2.point = team2.point + team2TotalPoints;
        teamRepo.saveTeam(team2);
      }
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
    List<String> incompleteTeams = _checkIncompleteTeams();
    if (incompleteTeams.isNotEmpty) {
      String message = '[${incompleteTeams.join(', ')}] 팀 선수 입력이 완료되지 않았습니다.';
      SnackbarHelper.showErrorSnackbar(context, message);
      return;
    }

    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;
    if (selectedEvent.endRound < selectedEvent.currentRound) {
      SnackbarHelper.showErrorSnackbar(context, '집계가 완료 되지 않았습니다.');
      return;
    }

    _createNewRound(selectedEvent);
    _createBracket(selectedEvent);

    setState(() {
      _future = _fetchData(selectedEvent.eventId!, selectedEvent.currentRound);
    });
  }

  List<String> _checkIncompleteTeams() {
    List<String> results = [];
    Map<int, EntryModel> entryMap =
        Provider.of<RoundProvider>(context, listen: false).round!.entryMap;
    for (var entry in entryMap.values) {
      if (entry.players.length != 2) {
        results.add(entry.team.name);
      }
    }
    return results;
  }

  void _createNewRound(Event selectedEvent) {
    selectedEvent.currentRound = selectedEvent.currentRound + 1;
    eventRepo.updateEvent(selectedEvent);
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(selectedEvent);
  }

  void _createBracket(Event selectedEvent) async {
    Map<int, EntryModel> entryMap =
        Provider.of<RoundProvider>(context, listen: false).round!.entryMap;
    List<List<Team>> rankedTeamsList = _makeRankedTeamsList(entryMap);
    Map<int, Set<int>> teamMatchHistory = await roundRepositoryCustom
        .findTeamMatchHistory(selectedEvent.eventId!);

    Queue<Team> remainTeams = Queue();

    List<Game> games = [];
    for (List<Team> rankGroup in rankedTeamsList) {
      List<Team> shuffledTeams = List.from(rankGroup)..shuffle();

      while (remainTeams.isNotEmpty) {
        Team team1 = remainTeams.removeFirst();
        Team? team2 = _findMatchingTeam(team1, shuffledTeams, teamMatchHistory);

        if (team2 != null) {
          games.add(_makeGame(selectedEvent, team1, team2));
        } else {
          remainTeams.add(team1);
          break;
        }
      }

      while (shuffledTeams.length > 1) {
        Team team1 = shuffledTeams.removeLast();
        Team? team2 = _findMatchingTeam(team1, shuffledTeams, teamMatchHistory);

        if (team2 != null) {
          games.add(_makeGame(selectedEvent, team1, team2));
        } else {
          remainTeams.add(team1);
          break;
        }
      }

      if (shuffledTeams.isNotEmpty) {
        remainTeams.add(shuffledTeams.removeLast());
      }
    }

    if (remainTeams.isNotEmpty) {
      Team team = remainTeams.removeFirst();
      games.add(_makeGame(selectedEvent, team, null));
    }

    for (var game in games) {
      gameRepo.saveGame(game);
    }
  }

  Game _makeGame(Event selectedEvent, Team team1, Team? team2) {
    return Game(
      eventId: selectedEvent.eventId!,
      round: selectedEvent.currentRound,
      team1Id: team1.teamId!,
      team2Id: team2?.teamId! ?? 0,
    );
  }

  Team? _findMatchingTeam(
      Team team, List<Team> candidates, Map<int, Set<int>> teamMatchHistory) {
    for (int i = 0; i < candidates.length; i++) {
      Set<int>? matchHistory = teamMatchHistory[team.teamId];
      if (matchHistory == null ||
          !matchHistory.contains(candidates[i].teamId)) {
        return candidates.removeAt(i);
      }
    }
    return null;
  }

  List<List<Team>> _makeRankedTeamsList(Map<int, EntryModel> entryMap) {
    List<List<Team>> rankedTeamsList = [];

    List<EntryModel> sortedEntries = entryMap.values.toList()
      ..sort((a, b) => b.team.point.compareTo(a.team.point));

    List<Team> currentRankTeams = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      if (i > 0 &&
          sortedEntries[i].team.point < sortedEntries[i - 1].team.point) {
        rankedTeamsList.add(currentRankTeams);
        currentRankTeams = [];
      }
      currentRankTeams.add(sortedEntries[i].team);
    }
    if (currentRankTeams.isNotEmpty) {
      rankedTeamsList.add(currentRankTeams);
    }

    return rankedTeamsList;
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
          child: i == _selectedRound
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
      _selectedRound = round;
      Event event = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!;
      _future = _fetchData(event.eventId!, round);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Event event = Provider.of<SelectedEventProvider>(context).selectedEvent!;
    _selectedRound = event.currentRound;
    _future = _fetchData(event.eventId!, event.currentRound);
  }
}
