import 'package:ddw_duel/base/SnackbarHelper.dart';
import 'package:ddw_duel/domain/duel/domain/duel.dart';
import 'package:ddw_duel/domain/game/domain/game.dart';
import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/player/repository/player_repository.dart';
import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/domain/team/repository/team_repository.dart';
import 'package:ddw_duel/provider/duel_provider.dart';
import 'package:ddw_duel/view/manage/bracket/model/duel_score.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  List<Player>? _team1Players;
  List<Player>? _team2Players;

  DuelScore? _dualATeam1Score;
  DuelScore? _dualBTeam1Score;

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
                        Text('${_team1?.name}'),
                        const Text(' vs '),
                        Text('${_team2?.name}'),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_team1Players?[0].name}'),
                      dualAScoreDropDownButton(),
                      Text('${_team2Players?[0].name}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${_team1Players?[1].name}'),
                      dualBScoreDropDownButton(),
                      Text('${_team2Players?[1].name}'),
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

    _team1Players = team1Players;
    _team2Players = team2Players;
  }

  Widget scoreDropDownButton(DuelScore? currentScore, ValueChanged<DuelScore?> onChanged) {
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
    return scoreDropDownButton(_dualATeam1Score, (DuelScore? value) {
      _putDuel(0);
      setState(() {
        _dualATeam1Score = value;
      });
    });
  }

  Widget dualBScoreDropDownButton() {
    return scoreDropDownButton(_dualBTeam1Score, (DuelScore? value) {
      _putDuel(1);
      setState(() {
        _dualBTeam1Score = value;
      });
    });
  }

  void _convertWinsToPoints(int wins) {
    int round = widget.game.round;
  }

  void _putDuel(int duelOrder) {
    Provider.of<DuelProvider>(context, listen: false).putDuel(Duel(
        gameId: widget.game.gameId!,
        duelPosition: duelOrder,
        player1Id: _team1Players![duelOrder].playerId!,
        player1Point: 0,
        player2Id: _team2Players![duelOrder].playerId!,
        player2Point: 0));
  }
}
