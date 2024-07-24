import 'package:ddw_duel/domain/team/repository/team_repository.dart';
import 'package:ddw_duel/provider/event_provider.dart';
import 'package:ddw_duel/provider/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/base/SnackbarHelper.dart';
import '/domain/team/domain/team.dart';

class TeamMangeComponent extends StatefulWidget {
  const TeamMangeComponent({super.key});

  @override
  State<TeamMangeComponent> createState() => _TeamMangeComponentState();
}

class _TeamMangeComponentState extends State<TeamMangeComponent> {
  final TeamRepository teamRepo = TeamRepository();

  final TextEditingController _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Team? _selectedTeam;

  String _teamName = '';

  void _onPressed() async {
    if (_selectedTeam == null) {
      SnackbarHelper.showErrorSnackbar(context, "팀 선택이 되어 있지 않습니다.");
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int eventId = Provider.of<EventProvider>(context, listen: false).eventId!;

      _selectedTeam!.name = _teamName;
      await teamRepo.updateTeam(_selectedTeam!);

      if (mounted) {
        Provider.of<PlayerProvider>(context, listen: false).fetchTeams(eventId);
        SnackbarHelper.showInfoSnackbar(context, "$_teamName 저장이 완료되었습니다.");
      }
      _formKey.currentState!.reset();
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    int? selectedTeamId = Provider.of<PlayerProvider>(context).selectedTeamId;
    if (selectedTeamId == null) {
      return;
    }

    Team? selectedTeam = await teamRepo.findTeam(selectedTeamId);
    if (selectedTeam == null) {
      return;
    }

    setState(() {
      _selectedTeam = selectedTeam;
    });
    _teamNameController.text = selectedTeam.name;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(
                  labelText: '팀 이름',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _teamName = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '팀 이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: _selectedTeam != null ? _onPressed : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 150.0),
                ),
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
