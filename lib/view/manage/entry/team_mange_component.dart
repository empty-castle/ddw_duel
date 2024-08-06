import 'package:ddw_duel/base/dialog_helper.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/entry_provider.dart';
import 'package:ddw_duel/provider/selected_entry_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/base/snackbar_helper.dart';

class TeamMangeComponent extends StatefulWidget {
  const TeamMangeComponent({super.key});

  @override
  State<TeamMangeComponent> createState() => _TeamMangeComponentState();
}

class _TeamMangeComponentState extends State<TeamMangeComponent> {
  final TeamRepository teamRepo = TeamRepository();
  final PlayerRepository playerRepository = PlayerRepository();

  final TextEditingController _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isInProgress = false;
  bool _isEndRound = false;

  void _onPressedSaveTeam() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;

      SelectedEntryProvider selectedEntryProvider =
          Provider.of<SelectedEntryProvider>(context, listen: false);
      Team selectedTeam = selectedEntryProvider.selectedEntryModel!.team;

      selectedTeam.name = _teamNameController.text;
      await teamRepo.saveTeam(selectedTeam);

      if (!mounted) return;
      await Provider.of<EntryProvider>(context, listen: false)
          .fetchEntries(eventId);

      if (!mounted) return;
      selectedEntryProvider.notify();
      SnackbarHelper.showInfoSnackbar(
          context, "${_teamNameController.text} 저장이 완료되었습니다.");

      _formKey.currentState!.reset();
    }
  }

  void _onPressedDeleteTeam(Team team) {
    Future<void> onPressed(Team team) async {
      await playerRepository.deletePlayer(team.teamId!);
      await teamRepo.deleteTeam(team.teamId!);

      if (!mounted) return;
      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;
      await Provider.of<EntryProvider>(context, listen: false)
          .fetchEntries(eventId);

      if (!mounted) return;
      SnackbarHelper.showInfoSnackbar(context, "${team.name} 팀 삭제가 완료되었습니다.");
    }

    DialogHelper.show(
        context: context,
        title: '팀 삭제 확인',
        content: '정말로 삭제하시겠습니까?',
        onPressedFunc: () => onPressed(team));
  }

  void _onPressedForfeitTeam(Team team) {
    Future<void> onPressed(Team team) async {
      team.isForfeited = 1;
      await teamRepo.saveTeam(team);
      setState(() {});
    }

    DialogHelper.show(
        context: context,
        title: '기권 확인',
        content: '정말로 기권 처리하시겠습니까?',
        onPressedFunc: () => onPressed(team));
  }

  bool _isEnabledForfeitButton(Team team) {
    return _isEndRound && team.isForfeited == 0;
  }

  @override
  void initState() {
    super.initState();

    Event selectedEvent =
        Provider.of<SelectedEventProvider>(context, listen: false)
            .selectedEvent!;

    _isInProgress = selectedEvent.currentRound != 0;
    _isEndRound = selectedEvent.currentRound == selectedEvent.endRound;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedEntryProvider>(
      builder: (context, provider, child) {
        if (provider.selectedEntryModel == null) {
          return const Center(
              child: Center(
            child: Text('팀을 선택해주세요.'),
          ));
        }
        _teamNameController.text = provider.selectedEntryModel!.team.name;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: _isEnabledForfeitButton(
                                provider.selectedEntryModel!.team)
                            ? () => _onPressedForfeitTeam(
                                provider.selectedEntryModel!.team)
                            : null,
                        child: const Text(
                          '기권',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isInProgress
                          ? null
                          : () => _onPressedDeleteTeam(
                              provider.selectedEntryModel!.team),
                      child: const Text(
                        '팀 삭제',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(
                      labelText: '팀 이름',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '팀 이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _onPressedSaveTeam,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 150.0),
                  ),
                  child: const Text('저장'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
