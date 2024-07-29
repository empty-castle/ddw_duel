import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/entry_model_provider.dart';
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
  // todo 저장 이후에 팀 이름이 안 바뀜
  final TeamRepository teamRepo = TeamRepository();

  final TextEditingController _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
          .selectedEvent!
          .eventId!;

      SelectedEntryProvider selectedEntryProvider =
          Provider.of<SelectedEntryProvider>(context, listen: false);
      Team selectedTeam = selectedEntryProvider.selectedEntryModel!.team;

      selectedTeam.name = _teamNameController.text;
      await teamRepo.updateTeam(selectedTeam);

      if (mounted) {
        await Provider.of<EntryModelProvider>(context, listen: false)
            .fetchEntryModels(eventId);
      }
      if (mounted) {
        selectedEntryProvider.notify();
        SnackbarHelper.showInfoSnackbar(
            context, "${_teamNameController.text} 저장이 완료되었습니다.");
      }
      _formKey.currentState!.reset();
    }
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
        _teamNameController.text = provider.selectedEntryModel?.team.name ?? '';
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
                    onPressed: _onPressed,
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
      },
    );
  }
}
