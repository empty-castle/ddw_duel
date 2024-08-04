import 'package:ddw_duel/base/player_helper.dart';
import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/type/duel_status.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
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
  final DuelRepository duelRepository = DuelRepository();

  final List<DuelScoreModel> _scores = [
    DuelScoreModel(
        label: '2:0',
        duelStatus: DuelStatus.normal,
        player1Wins: 2,
        player2Wins: 0),
    DuelScoreModel(
        label: '2:1',
        duelStatus: DuelStatus.normal,
        player1Wins: 2,
        player2Wins: 1),
    DuelScoreModel(
        label: '1:2',
        duelStatus: DuelStatus.normal,
        player1Wins: 1,
        player2Wins: 2),
    DuelScoreModel(
        label: '0:2',
        duelStatus: DuelStatus.normal,
        player1Wins: 0,
        player2Wins: 2)
  ];

  Duel? _duelA;
  DuelScoreModel? _duelAScore;

  Duel? _duelB;
  DuelScoreModel? _duelBScore;

  @override
  void initState() {
    super.initState();
    if (widget.entryA == null || widget.entryB == null) {
      _processWalkover();
    } else {
      _processNormal();
    }
  }

  void _processWalkover() {
    if (widget.gameModel.duels.isNotEmpty) {
      return;
    }
    _saveWalkoverDuel(widget.entryA, widget.entryB, 1);
    _saveWalkoverDuel(widget.entryA, widget.entryB, 2);
  }

  void _saveWalkoverDuel(EntryModel? entryA, EntryModel? entryB, int position) async {
    Duel newDuel = Duel(
        gameId: widget.gameModel.game.gameId!,
        position: position,
        status: DuelStatus.walkover,
        player1Id: entryA != null
            ? PlayerHelper.getPlayerByPosition(
                    widget.entryA!.players, position)!
                .playerId!
            : 0,
        player1Point: entryA != null ? 2 : 0,
        player2Id: entryB != null
            ? PlayerHelper.getPlayerByPosition(
                    widget.entryA!.players, position)!
                .playerId!
            : 0,
        player2Point: entryB != null ? 2 : 0);
    int duelId = await duelRepository.saveDuel(newDuel);
    newDuel.duelId = duelId;
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
                decoration: const BoxDecoration(color: Color(0xFF8A61DB)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.entryA?.team.name ?? '부전승'),
                    const Text(' vs '),
                    Text(widget.entryB?.team.name ?? '부전승'),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.entryA?.players[0].name ?? '부전승'),
                  duelAScoreDropDownButton(),
                  Text(widget.entryB?.players[0].name ?? '부전승'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.entryA?.players[1].name ?? '부전승'),
                  duelBScoreDropDownButton(),
                  Text(widget.entryB?.players[1].name ?? '부전승'),
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

  Widget scoreDropDownButton(
      DuelScoreModel? currentScore, ValueChanged<DuelScoreModel?> onChanged) {
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
        onChanged: onChanged,
      ),
    );
  }

  Widget duelAScoreDropDownButton() {
    if (widget.entryA == null || widget.entryB == null) {
      return const SizedBox(
        width: 120,
        height: 48,
      );
    }
    return scoreDropDownButton(_duelAScore, (DuelScoreModel? value) async {
      Duel savedDuel = await _saveDuel(_duelA, value!, 1);
      setState(() {
        _duelA = savedDuel;
        _duelAScore = value;
      });
    });
  }

  Widget duelBScoreDropDownButton() {
    if (widget.entryA == null || widget.entryB == null) {
      return const SizedBox(
        width: 120,
        height: 48,
      );
    }
    return scoreDropDownButton(_duelBScore, (DuelScoreModel? value) async {
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
      duelStatus: duel.status,
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
          status: duelScore.duelStatus,
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
}
