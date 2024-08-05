import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/entry_provider.dart';
import 'package:ddw_duel/provider/selected_entry_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamListComponent extends StatefulWidget {
  const TeamListComponent({super.key});

  @override
  State<TeamListComponent> createState() => _TeamListComponentState();
}

class _TeamListComponentState extends State<TeamListComponent> {
  final TeamRepository teamRepo = TeamRepository();

  Team? _selectedTeam;

  bool _isInProgress = false;

  void _onSelectChanged(EntryModel entryModel) {
    setState(() {
      _selectedTeam = entryModel.team;
    });
    Provider.of<SelectedEntryProvider>(context, listen: false)
        .setSelectedEntry(entryModel);
  }

  void _onPressedNewTeam() async {
    int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .eventId!;
    List<Team> teams = await teamRepo.findTeams(eventId);

    // todo 팀 이름 순번
    Team team = Team(
      eventId: eventId,
      name: '${teams.length + 1}팀',
    );
    await teamRepo.saveTeam(team);

    if (!mounted) return;
    await Provider.of<EntryProvider>(context, listen: false)
        .fetchEntries(eventId);

    if (!mounted) return;
    SnackbarHelper.showInfoSnackbar(context, "${team.name} 팀 저장이 완료되었습니다.");
  }

  @override
  void initState() {
    super.initState();
    _isInProgress = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .currentRound !=
        0;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Consumer<EntryProvider>(builder: (context, provider, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _isInProgress ? null : _onPressedNewTeam,
                  child: const Text(
                    '팀 추가',
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(
                            label: Text('이름',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: provider.entries.map((entryModel) {
                        return DataRow(
                            selected:
                                _selectedTeam?.teamId == entryModel.team.teamId,
                            onSelectChanged: (_) {
                              _onSelectChanged(entryModel);
                            },
                            cells: [
                              DataCell(SizedBox(
                                width: constraints.maxWidth * 0.8,
                                child: Text(
                                  entryModel.team.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ))
                            ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }));
  }
}
