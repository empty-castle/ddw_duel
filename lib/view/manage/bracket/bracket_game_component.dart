import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/view/manage/bracket/model/duel_score.dart';
import 'package:flutter/material.dart';

class BracketGameComponent extends StatefulWidget {
  final Game game;

  const BracketGameComponent({super.key, required this.game});

  @override
  State<BracketGameComponent> createState() => _BracketGameComponentState();
}

class _BracketGameComponentState extends State<BracketGameComponent> {
  final TeamRepository teamRepo = TeamRepository();
  final PlayerRepository playerRepo = PlayerRepository();

  final List<DuelScore> _scores = [
    DuelScore(label: '2:0', player1Wins: 2, player2Wins: 0),
    DuelScore(label: '2:1', player1Wins: 2, player2Wins: 1),
    DuelScore(label: '1:2', player1Wins: 1, player2Wins: 2),
    DuelScore(label: '0:2', player1Wins: 0, player2Wins: 2)
  ];

  late Future<void> _teamFuture;
  Team? _team1;
  Team? _team2;

  Map<int, Player>? _team1PlayersMap;
  Map<int, Player>? _team2PlayersMap;

  DuelScore? _dualAScore;
  DuelScore? _dualBScore;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _teamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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
                        Text(_team1!.name),
                        const Text(' vs '),
                        Text(_team2!.name),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_team1PlayersMap![1]!.name),
                      dualAScoreDropDownButton(),
                      Text(_team2PlayersMap![1]!.name),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_team1PlayersMap![2]!.name),
                      dualBScoreDropDownButton(),
                      Text(_team2PlayersMap![2]!.name),
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _teamFuture = _setTeams();
  }

  Future<void> _setTeams() async {
    Team? team1 = await teamRepo.findTeam(widget.game.team1Id);
    Team? team2 = await teamRepo.findTeam(widget.game.team2Id);

    if (team1 == null || team2 == null) {
      if (mounted) {
        SnackbarHelper.showErrorSnackbar(context, "팀 조회가 정상적으로 이뤄지지 않았습니다.");
      }
      return;
    }

    _team1 = team1;
    _team2 = team2;

    List<Player> team1Players = await playerRepo.findPlayers(team1.teamId!);
    List<Player> team2Players = await playerRepo.findPlayers(team2.teamId!);

    _team1PlayersMap = _playersToMap(team1Players);
    _team2PlayersMap = _playersToMap(team2Players);
    
    
  }

  Map<int, Player> _playersToMap(List<Player> players) {
    Map<int, Player> playerMap = {};
    for (var player in players) {
      playerMap[player.position] = player;
    }
    return playerMap;
  }

  Widget scoreDropDownButton(
      DuelScore? currentScore, ValueChanged<DuelScore?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: DropdownButton<DuelScore>(
        value: currentScore,
        items: _scores.map<DropdownMenuItem<DuelScore>>((score) {
          return DropdownMenuItem<DuelScore>(
            value: score,
            child: Text(score.label),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget dualAScoreDropDownButton() {
    return scoreDropDownButton(_dualAScore, (DuelScore? value) {
      _saveOrUpdateDuel(value!, 1);
      setState(() {
        _dualAScore = value;
      });
    });
  }

  Widget dualBScoreDropDownButton() {
    return scoreDropDownButton(_dualBScore, (DuelScore? value) {
      _saveOrUpdateDuel(value!, 2);
      setState(() {
        _dualBScore = value;
      });
    });
  }

  int _convertPointsToWins(double points, int position) {
    int round = widget.game.round;
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
    int round = widget.game.round;
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

  void _saveOrUpdateDuel(DuelScore dualScore, int position) {
    Duel(
        gameId: widget.game.gameId!,
        position: position,
        player1Id: _team1PlayersMap![position]!.playerId!,
        player1Point: _convertWinsToPoints(dualScore.player1Wins, position),
        player2Id: _team2PlayersMap![position]!.playerId!,
        player2Point: _convertWinsToPoints(dualScore.player2Wins, position));
  }
}
