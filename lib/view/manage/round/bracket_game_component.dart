import 'package:ddw_duel/base/dialog_helper.dart';
import 'package:ddw_duel/base/player_helper.dart';
import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/domain/type/game_status.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/round_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/manage/round/model/duel_score_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BracketGameComponent extends StatefulWidget {
  final GameModel gameModel;
  final EntryModel? entryA;
  final EntryModel? entryB;

  const BracketGameComponent(
      {super.key,
      required this.gameModel,
      required this.entryA,
      required this.entryB});

  @override
  State<BracketGameComponent> createState() => _BracketGameComponentState();
}

class _BracketGameComponentState extends State<BracketGameComponent> {
  final GameRepository gameRepository = GameRepository();
  final DuelRepository duelRepository = DuelRepository();
  final TeamRepository teamRepository = TeamRepository();

  final List<DuelScoreModel> _scores = [
    DuelScoreModel(label: '2:0', player1Wins: 2, player2Wins: 0),
    DuelScoreModel(label: '2:1', player1Wins: 2, player2Wins: 1),
    DuelScoreModel(label: '1:2', player1Wins: 1, player2Wins: 2),
    DuelScoreModel(label: '0:2', player1Wins: 0, player2Wins: 2)
  ];

  Duel? _duelA;
  DuelScoreModel? _duelAScore;

  Duel? _duelB;
  DuelScoreModel? _duelBScore;

  @override
  void initState() {
    super.initState();
    _processNormal();
  }

  void _saveDuelForfeit(
      EntryModel entryA, EntryModel entryB, int position, int forfeitTeamId) {
    Duel newDuel = Duel(
        gameId: widget.gameModel.game.gameId!,
        position: position,
        player1Id:
            PlayerHelper.getPlayerByPosition(widget.entryA!.players, position)!
                .playerId!,
        player1Point: entryA.team.teamId != forfeitTeamId ? 2 : 0,
        player2Id:
            PlayerHelper.getPlayerByPosition(widget.entryB!.players, position)!
                .playerId!,
        player2Point: entryB.team.teamId != forfeitTeamId ? 2 : 0);
    duelRepository.saveDuel(newDuel);
  }

  void _processNormal() {
    _duelA = _getDuelByPosition(widget.gameModel.duels, 1);
    if (_duelA != null) {
      _duelAScore = _convertDuelToScore(_duelA!, 1);
    }
    _duelB = _getDuelByPosition(widget.gameModel.duels, 2);
    if (_duelB != null) {
      _duelBScore = _convertDuelToScore(_duelB!, 2);
    }
  }

  Duel? _getDuelByPosition(List<Duel> duels, int position) {
    for (var duel in duels) {
      if (duel.position == position) {
        return duel;
      }
    }
    return null;
  }

  void _onPressedForfeit(EntryModel entry) {
    Future<void> onPressed(EntryModel entry) async {
      _handleForfeitDuel(entry);

      widget.gameModel.game.status = _determineGameStatus();
      await gameRepository.saveGame(widget.gameModel.game);

      Team team = entry.team;
      team.isForfeited = 1;
      await teamRepository.saveTeam(team);

      setState(() {});

      if (!mounted) return;
      Event selectedEvent =
          Provider.of<SelectedEventProvider>(context, listen: false)
              .selectedEvent!;
      Provider.of<RoundProvider>(context, listen: false)
          .fetchRound(selectedEvent.eventId!, selectedEvent.currentRound);
    }

    DialogHelper.show(
        context: context,
        title: '기권 확인',
        content: '정말로 기권하시겠습니까?',
        onPressedFunc: () => onPressed(entry));
  }

  void _handleForfeitDuel(EntryModel entry) {
    duelRepository.deleteDuel(widget.gameModel.game.gameId!);

    if (widget.entryA == null || widget.entryB == null) {
      return;
    }

    if (widget.entryA!.team.isForfeited == 1 ||
        widget.entryB!.team.isForfeited == 1) {
      return;
    }

    if (widget.entryA != null && widget.entryB != null) {
      _saveDuelForfeit(widget.entryA!, widget.entryB!, 1, entry.team.teamId!);
      _saveDuelForfeit(widget.entryA!, widget.entryB!, 2, entry.team.teamId!);
    }
  }

  GameStatus _determineGameStatus() {
    if (widget.entryA == null || widget.entryB == null || widget.entryA!.team.isForfeited == 1 || widget.entryB!.team.isForfeited == 1) {
      return GameStatus.cancelled;
    }
    return GameStatus.forfeit;
  }

  List<Widget> _makeTeamText() {
    List<Widget> buildTeamText(EntryModel entry) {
      List<Widget> widgets = [];
      widgets.add(Text(entry.team.name));
      if (widget.gameModel.game.status != GameStatus.normal &&
          entry.team.isForfeited == 1) {
        widgets.add(const Text('(기권)'));
      }
      return widgets;
    }

    if (widget.entryA == null) {
      List<Widget> result = buildTeamText(widget.entryB!);
      result.add(const Text(' 부전승'));
      return result;
    }

    if (widget.entryB == null) {
      List<Widget> result = buildTeamText(widget.entryA!);
      result.add(const Text(' 부전승'));
      return result;
    }

    List<Widget> result = buildTeamText(widget.entryA!);
    result.add(const Text(' vs '));
    result.addAll(buildTeamText(widget.entryB!));

    return result;
  }

  Widget _makeForfeitButton(EntryModel? entry) {
    int endRound = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .endRound;
    if (widget.gameModel.game.round <= endRound) {
      return const SizedBox.shrink();
    }
    if (entry == null || entry.team.isForfeited == 1) {
      return const SizedBox.shrink();
    }
    return TextButton(
      onPressed: () => _onPressedForfeit(entry),
      child: const Text(
        '기권',
      ),
    );
  }

  Widget _scoreDropDownButton(
      DuelScoreModel? currentScore, ValueChanged<DuelScoreModel?> onChanged) {
    if (widget.entryA == null ||
        widget.entryB == null ||
        widget.gameModel.game.status != GameStatus.normal) {
      return const SizedBox(
        width: 120,
        height: 48,
      );
    }

    bool isEndRound = false;
    int endRound = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .endRound;
    if (widget.gameModel.game.round <= endRound) {
      isEndRound = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: DropdownButton<DuelScoreModel>(
        value: currentScore,
        items: _scores.map<DropdownMenuItem<DuelScoreModel>>((score) {
          return DropdownMenuItem<DuelScoreModel>(
            value: score,
            child: Text(score.label),
          );
        }).toList(),
        onChanged: isEndRound ? null : onChanged,
      ),
    );
  }

  Widget _duelAScoreDropDownButton() {
    return _scoreDropDownButton(_duelAScore, (DuelScoreModel? value) async {
      Duel savedDuel = await _saveDuel(_duelA, value!, 1);
      setState(() {
        _duelA = savedDuel;
        _duelAScore = value;
      });
    });
  }

  Widget _duelBScoreDropDownButton() {
    return _scoreDropDownButton(_duelBScore, (DuelScoreModel? value) async {
      Duel savedDuel = await _saveDuel(_duelB, value!, 2);
      setState(() {
        _duelB = savedDuel;
        _duelBScore = value;
      });
    });
  }

  DuelScoreModel _convertDuelToScore(Duel duel, int position) {
    int player1Wins = _convertPointsToWins(duel.player1Point, position);
    int player2Wins = _convertPointsToWins(duel.player2Point, position);
    return DuelScoreModel(
      label: '$player1Wins:$player2Wins',
      player1Wins: player1Wins,
      player2Wins: player2Wins,
    );
  }

  int _convertPointsToWins(double points, int position) {
    int round = widget.gameModel.game.round;
    int wins = 0;
    if (round % 2 != 0) {
      if (position == 1) {
        wins = (points / 1.5).round();
      } else if (position == 2) {
        wins = (points / 1.0).round();
      }
    } else {
      if (position == 1) {
        wins = (points / 1.0).round();
      } else if (position == 2) {
        wins = (points / 1.5).round();
      }
    }
    return wins;
  }

  double _convertWinsToPoints(int wins, int position) {
    int round = widget.gameModel.game.round;
    double points = 0;
    if (round % 2 != 0) {
      if (position == 1) {
        points = wins * 1.5;
      } else if (position == 2) {
        points = wins * 1.0;
      }
    } else {
      if (position == 1) {
        points = wins * 1.0;
      } else if (position == 2) {
        points = wins * 1.5;
      }
    }
    return points;
  }

  Future<Duel> _saveDuel(
      Duel? duel, DuelScoreModel duelScore, int position) async {
    if (duel != null) {
      duel.player1Point = _convertWinsToPoints(duelScore.player1Wins, position);
      duel.player2Point = _convertWinsToPoints(duelScore.player2Wins, position);
      duelRepository.saveDuel(duel);
      return duel;
    } else {
      Duel newDuel = Duel(
          gameId: widget.gameModel.game.gameId!,
          position: position,
          player1Id: PlayerHelper.getPlayerByPosition(
                  widget.entryA!.players, position)!
              .playerId!,
          player1Point: _convertWinsToPoints(duelScore.player1Wins, position),
          player2Id: PlayerHelper.getPlayerByPosition(
                  widget.entryB!.players, position)!
              .playerId!,
          player2Point: _convertWinsToPoints(duelScore.player2Wins, position));
      int newDuelId = await duelRepository.saveDuel(newDuel);
      newDuel.duelId = newDuelId;
      return newDuel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1)),
          child: Column(
            children: [
              Container(
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFF8A61DB)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _makeForfeitButton(widget.entryA),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _makeTeamText(),
                    ),
                    _makeForfeitButton(widget.entryB)
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.entryA?.players[0].name ?? ''),
                  _duelAScoreDropDownButton(),
                  Text(widget.entryB?.players[0].name ?? ''),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.entryA?.players[1].name ?? ''),
                  _duelBScoreDropDownButton(),
                  Text(widget.entryB?.players[1].name ?? ''),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
