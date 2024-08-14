import 'dart:collection';

import 'package:ddw_duel/base/dialog_helper.dart';
import 'package:ddw_duel/base/player_helper.dart';
import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/domain/type/game_status.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
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
  final EventRepository eventRepository = EventRepository();
  final GameRepository gameRepository = GameRepository();
  final TeamRepository teamRepository = TeamRepository();
  final DuelRepository duelRepository = DuelRepository();
  final PlayerRepository playerRepository = PlayerRepository();

  int? _selectedRound;

  late Future<void> _future;

  void _onPressedReturn() {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    if (selectedEvent.currentRound < 1) {
      DialogHelper.error(
          context: context, title: '되돌리기 에러', content: '되돌릴 진행 사항이 없습니다.');
      return;
    }

    Future<void> Function() func;
    String content = '';
    if (selectedEvent.currentRound > selectedEvent.endRound) {
      func = _returnRound;
      content = '현재 진행 중인 ${selectedEvent.currentRound}라운드를 되돌리겠습니까?';
    } else {
      func = _returnScoring;
      content = '${selectedEvent.endRound}라운드의 집계를 취소하시겠습니까?';
    }

    DialogHelper.show(
        context: context,
        title: '되돌리기 확인',
        content: content,
        onPressedFunc: () => func());
  }

  Future<void> _returnRound() async {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    List<Game> games = await gameRepository.findCurrentRoundGames(
        selectedEvent.eventId!, selectedEvent.currentRound);
    for (Game game in games) {
      duelRepository.deleteDuel(game.gameId!);
    }
    gameRepository.deleteCurrentRoundGame(
        selectedEvent.eventId!, selectedEvent.currentRound);

    List<Team> forfeitTeams = await teamRepository.findCurrentRoundForfeitTeams(
        selectedEvent.eventId!, selectedEvent.currentRound);
    for (Team team in forfeitTeams) {
      team.forfeitRound = 0;
      team.isForfeited = 0;
      teamRepository.saveTeam(team);
    }

    selectedEvent.currentRound = selectedEvent.currentRound - 1;
    await eventRepository.saveEvent(selectedEvent);

    if (!mounted) return;
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(selectedEvent);
  }

  Future<void> _returnScoring() async {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    List<Game> games = await gameRepository.findCurrentRoundGames(
        selectedEvent.eventId!, selectedEvent.currentRound);
    for (Game game in games) {
      Team? team1 = await teamRepository.findTeam(game.team1Id);
      if (team1 != null) {
        team1.point = team1.point - game.team1Point;
        teamRepository.saveTeam(team1);
      }
      Team? team2 = await teamRepository.findTeam(game.team2Id);
      if (team2 != null) {
        team2.point = team2.point - game.team2Point;
        teamRepository.saveTeam(team2);
      }

      game.team1Point = 0.0;
      game.team2Point = 0.0;
      gameRepository.saveGame(game);
    }

    selectedEvent.endRound = selectedEvent.endRound - 1;
    await eventRepository.saveEvent(selectedEvent);

    if (!mounted) return;
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(selectedEvent);
  }

  void _onPressedScoring() async {
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    String errorTitle = '집계 에러';
    if (_selectedRound == null || _selectedRound! <= selectedEvent.endRound) {
      DialogHelper.error(
          context: context,
          title: errorTitle,
          content: '현재 진행 중인 라운드를 선택해주세요.');
      return;
    }

    await Provider.of<RoundProvider>(context, listen: false)
        .fetchRound(selectedEvent.eventId!, _selectedRound!);

    if (!mounted) return;

    RoundModel roundModel =
        Provider.of<RoundProvider>(context, listen: false).round!;
    if (!_validateDuelsInGameModels(roundModel.gameModels)) {
      DialogHelper.error(
          context: context, title: errorTitle, content: '모든 경기의 결과를 입력해주세요.');
      return;
    }
    _aggregatePoints(roundModel.entryMap, roundModel.gameModels);

    selectedEvent.endRound = _selectedRound!;
    eventRepository.saveEvent(selectedEvent);

    setState(() {
      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;
      _future = _fetchData(eventId, _selectedRound!);
    });
  }

  void _aggregatePoints(
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

      gameRepository.saveGame(gameModel.game);

      Team? team1 = entryMap[gameModel.game.team1Id]?.team;
      Team? team2 = entryMap[gameModel.game.team2Id]?.team;

      if (team1 != null) {
        team1.point = team1.point + team1TotalPoints;
        teamRepository.saveTeam(team1);
      }

      if (team2 != null) {
        team2.point = team2.point + team2TotalPoints;
        teamRepository.saveTeam(team2);
      }
    }
  }

  bool _validateDuelsInGameModels(List<GameModel> gameModels) {
    for (var gameModel in gameModels) {
      if (gameModel.game.status == GameStatus.cancelled) {
        continue;
      }
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
    if (selectedEvent.currentRound != selectedEvent.endRound) {
      DialogHelper.error(
          context: context,
          title: '라운드 생성 에러',
          content: '집계가 완료되어야 라운드 생성이 가능합니다.');
      return;
    }
    Map<int, EntryModel> entryMap =
        Provider.of<RoundProvider>(context, listen: false).round!.entryMap;

    if (entryMap.length < 2) {
      SnackbarHelper.showErrorSnackbar(context, '최소 2개의 팀을 등록해 주세요.');
      return;
    }

    if (selectedEvent.currentRound == 0) {
      List<String> incompleteTeams = _checkIncompleteTeams(entryMap);
      if (incompleteTeams.isNotEmpty) {
        String message = '[${incompleteTeams.join(', ')}] 팀 선수 입력이 완료되지 않았습니다.';
        SnackbarHelper.showErrorSnackbar(context, message);
        return;
      }
    }

    if (selectedEvent.endRound < selectedEvent.currentRound) {
      SnackbarHelper.showErrorSnackbar(context, '집계가 완료 되지 않았습니다.');
      return;
    }

    _createBracket(entryMap, selectedEvent);
    _createNewRound(selectedEvent);

    setState(() {
      _future = _fetchData(selectedEvent.eventId!, selectedEvent.currentRound);
    });
  }

  List<String> _checkIncompleteTeams(Map<int, EntryModel> entryMap) {
    List<String> results = [];
    for (var entry in entryMap.values) {
      if (entry.players.length != 2) {
        results.add(entry.team.name);
      }
    }
    return results;
  }

  void _createNewRound(Event selectedEvent) {
    selectedEvent.currentRound = selectedEvent.currentRound + 1;
    eventRepository.updateEvent(selectedEvent);
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(selectedEvent);
  }

  void _createBracket(
      Map<int, EntryModel> entryMap, Event selectedEvent) async {
    List<EntryModel> activeEntries = _filteringForfeitTeams(entryMap);

    List<List<int>> rankedTeamIdList = _makeRankedTeamIdList(activeEntries);

    Map<int, Set<int>> teamMatchHistory = await roundRepositoryCustom
        .findTeamMatchHistory(selectedEvent.eventId!);

    Queue<int> remainTeamIdQueue = Queue();
    List<Game> games = [];

    _processWalkoverTeam(activeEntries.length, rankedTeamIdList, selectedEvent);

    for (List<int> rankGroup in rankedTeamIdList) {
      _processRankGroup(
          rankGroup, remainTeamIdQueue, games, selectedEvent, teamMatchHistory);
    }

    _processRemainingTeams(
        remainTeamIdQueue, games, selectedEvent, teamMatchHistory);

    for (var game in games) {
      gameRepository.saveGame(game);
    }
  }

  List<EntryModel> _filteringForfeitTeams(Map<int, EntryModel> entryMap) {
    List<EntryModel> activeEntries = [];
    for (var entry in entryMap.values) {
      if (entry.team.isForfeited != 1) {
        activeEntries.add(entry);
      }
    }
    return activeEntries;
  }

  void _processWalkoverTeam(int entryLength, List<List<int>> rankedTeamIdList,
      Event selectedEvent) async {
    if (entryLength % 2 == 0) {
      return;
    }
    List<int> lastRankedTeamIdList = rankedTeamIdList.removeLast();
    lastRankedTeamIdList.shuffle();

    int lastRankedTeamId = lastRankedTeamIdList.removeLast();
    if (lastRankedTeamIdList.isNotEmpty) {
      rankedTeamIdList.add(lastRankedTeamIdList);
    }

    int gameId = await gameRepository.saveGame(
        _makeGame(selectedEvent, lastRankedTeamId, null, GameStatus.walkover));
    List<Player> players = await playerRepository.findPlayers(lastRankedTeamId);
    _saveDuelWalkover(
        gameId, PlayerHelper.getPlayerByPosition(players, 1)!.playerId!, 1);
    _saveDuelWalkover(
        gameId, PlayerHelper.getPlayerByPosition(players, 2)!.playerId!, 2);
  }

  void _saveDuelWalkover(int gameId, int playerId, int position) {
    Duel newDuel = Duel(
        gameId: gameId,
        position: position,
        player1Id: playerId,
        player1Point: 2,
        player2Id: 0,
        player2Point: 0);
    duelRepository.saveDuel(newDuel);
  }

  void _processRankGroup(
      List<int> rankGroup,
      Queue<int> remainTeamIdQueue,
      List<Game> games,
      Event selectedEvent,
      Map<int, Set<int>> teamMatchHistory) {
    List<int> shuffledTeamIds = List.from(rankGroup)..shuffle();

    while (remainTeamIdQueue.isNotEmpty) {
      int team1Id = remainTeamIdQueue.removeFirst();
      int? team2Id =
          _findMatchingTeam(team1Id, shuffledTeamIds, teamMatchHistory);

      if (team2Id != null) {
        games
            .add(_makeGame(selectedEvent, team1Id, team2Id, GameStatus.normal));
      } else {
        remainTeamIdQueue.add(team1Id);
        break;
      }
    }

    while (shuffledTeamIds.length > 1) {
      int team1Id = shuffledTeamIds.removeLast();
      int? team2Id =
          _findMatchingTeam(team1Id, shuffledTeamIds, teamMatchHistory);

      if (team2Id != null) {
        games
            .add(_makeGame(selectedEvent, team1Id, team2Id, GameStatus.normal));
      } else {
        remainTeamIdQueue.add(team1Id);
        break;
      }
    }

    if (shuffledTeamIds.isNotEmpty) {
      remainTeamIdQueue.add(shuffledTeamIds.removeLast());
    }
  }

  void _processRemainingTeams(Queue<int> remainTeamIdQueue, List<Game> games,
      Event selectedEvent, Map<int, Set<int>> teamMatchHistory) {
    if (remainTeamIdQueue.length > 1) {
      List<int> remainTeamIdList = remainTeamIdQueue.toList();
      List<Game> rematchingGames = _rematchRemainingTeams(
          remainTeamIdList, games, selectedEvent, teamMatchHistory);

      games.addAll(rematchingGames);

      _matchFinalRemainingTeams(remainTeamIdList, games, selectedEvent);
    }
  }

  void _matchFinalRemainingTeams(
      List<int> remainTeamIdList, List<Game> games, Event selectedEvent) {
    for (int i = 0; i < remainTeamIdList.length; i += 2) {
      if (i + 1 < remainTeamIdList.length) {
        int team1Id = remainTeamIdList[i];
        int team2Id = remainTeamIdList[i + 1];
        games
            .add(_makeGame(selectedEvent, team1Id, team2Id, GameStatus.normal));
      } else {
        int lastTeamId = remainTeamIdList[i];
        games.add(
            _makeGame(selectedEvent, lastTeamId, null, GameStatus.walkover));
      }
    }
  }

  List<Game> _rematchRemainingTeams(
      List<int> remainTeamIdList,
      List<Game> games,
      Event selectedEvent,
      Map<int, Set<int>> teamMatchHistory) {
    List<Game> rematchingGames = [];

    while (remainTeamIdList.isNotEmpty && games.isNotEmpty) {
      Game game = games.removeLast();
      int? matchingTeamIdByTeam1 =
          _findMatchingTeam(game.team1Id, remainTeamIdList, teamMatchHistory);
      int? matchingTeamIdByTeam2 =
          _findMatchingTeam(game.team2Id, remainTeamIdList, teamMatchHistory);

      if (matchingTeamIdByTeam1 != null) {
        rematchingGames.add(_makeGame(selectedEvent, game.team1Id,
            matchingTeamIdByTeam1, GameStatus.normal));
      } else {
        remainTeamIdList.add(game.team1Id);
      }

      if (matchingTeamIdByTeam2 != null) {
        rematchingGames.add(_makeGame(selectedEvent, game.team2Id,
            matchingTeamIdByTeam2, GameStatus.normal));
      } else {
        remainTeamIdList.add(game.team2Id);
      }
    }

    return rematchingGames;
  }

  Game _makeGame(
      Event selectedEvent, int team1Id, int? team2Id, GameStatus gameStatus) {
    return Game(
      eventId: selectedEvent.eventId!,
      round: selectedEvent.currentRound,
      status: gameStatus,
      team1Id: team1Id,
      team2Id: team2Id ?? 0,
    );
  }

  int? _findMatchingTeam(
      int teamId, List<int> candidates, Map<int, Set<int>> teamMatchHistory) {
    for (int i = 0; i < candidates.length; i++) {
      Set<int>? matchHistory = teamMatchHistory[teamId];
      if (matchHistory == null || !matchHistory.contains(candidates[i])) {
        return candidates.removeAt(i);
      }
    }
    return null;
  }

  List<List<int>> _makeRankedTeamIdList(List<EntryModel> activeEntries) {
    List<List<int>> rankedTeamsList = [];

    List<EntryModel> sortedEntries = activeEntries
      ..sort((a, b) => b.team.point.compareTo(a.team.point));

    List<int> currentRankTeams = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      if (i > 0 &&
          sortedEntries[i].team.point < sortedEntries[i - 1].team.point) {
        rankedTeamsList.add(currentRankTeams);
        currentRankTeams = [];
      }
      currentRankTeams.add(sortedEntries[i].team.teamId!);
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
    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context).selectedEvent!;
    _selectedRound = selectedEvent.currentRound;
    _future = _fetchData(selectedEvent.eventId!, selectedEvent.currentRound);
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
                                      onPressed: _onPressedReturn,
                                      child: const Text(
                                        '되돌리기',
                                      ),
                                    ),
                                  ),
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
}
