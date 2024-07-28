import 'package:ddw_duel/base/SnackbarHelper.dart';
import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/player/repository/player_repository.dart';
import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/provider/player_provider.dart';
import 'package:ddw_duel/provider/selected_team_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerFormComponent extends StatefulWidget {
  final int position;

  const PlayerFormComponent({super.key, required this.position});

  @override
  State<PlayerFormComponent> createState() => _PlayerFormComponentState();
}

class _PlayerFormComponentState extends State<PlayerFormComponent> {
  final PlayerRepository playerRepo = PlayerRepository();

  final TextEditingController _playerNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Player? _player;
  String _playerName = '';

  void _onPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Team? selectedTeam =
          Provider.of<SelectedTeamProvider>(context, listen: false)
              .selectedTeam;
      if (selectedTeam == null) {
        SnackbarHelper.showErrorSnackbar(context, "팀 선택이 되어 있지 않습니다.");
        return;
      }

      if (_player == null) {
        Player player = Player(
          name: _playerName,
          teamId: selectedTeam.teamId!,
          position: widget.position,
        );
        await playerRepo.savePlayer(player);
      } else {
        _player!.name = _playerName;
        await playerRepo.updatePlayer(_player!);
      }

      if (mounted) {
        Provider.of<PlayerProvider>(context, listen: false)
            .fetchPlayers(selectedTeam.teamId!);
        SnackbarHelper.showInfoSnackbar(
            context, "$_playerName 선수 저장이 완료되었습니다.");
      }
      _formKey.currentState!.reset();
    }
  }

  Player? getFirstPlayerByPosition(List<Player> players, int position) {
    for (Player player in players) {
      if (player.position == position) {
        return player;
      }
    }
    return null;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    List<Player> players = Provider.of<PlayerProvider>(context).players;
    Player? player = players[widget.position];

    if (player == null) {
      _player = null;
      _playerNameController.text = '';
      return;
    }

    _player = player;
    _playerNameController.text = player.name;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                labelText: '선수 이름',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                _playerName = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '선수 이름을 입력해주세요.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: _onPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 150.0),
              ),
              child: const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}
