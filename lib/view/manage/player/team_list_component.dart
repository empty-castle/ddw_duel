import 'package:ddw_duel/base/SnackbarHelper.dart';
import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/domain/team/repository/team_repository.dart';
import 'package:ddw_duel/provider/event_provider.dart';
import 'package:ddw_duel/provider/player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamListComponent extends StatefulWidget {
  const TeamListComponent({super.key});

  @override
  State<TeamListComponent> createState() => _TeamListComponentState();
}

class _TeamListComponentState extends State<TeamListComponent> {
  final TeamRepository teamRepo = TeamRepository();

  void _onPressedNewTeam() async {
    int eventId = Provider.of<EventProvider>(context, listen: false).eventId!;
    List<Team> teams = await teamRepo.findTeams(eventId);

    Team team = Team(
      eventId: eventId,
      name: '${teams.length + 1}팀',
    );
    teamRepo.saveTeam(team);

    if (mounted) {
      Provider.of<PlayerProvider>(context, listen: false).fetchTeams(eventId);
      SnackbarHelper.showInfoSnackbar(context, "${team.name} 팀 저장이 완료되었습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child:
        Consumer<PlayerProvider>(builder: (context, playerProvider, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: _onPressedNewTeam,
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
                      rows: playerProvider.teams.map((team) {
                        return DataRow(
                            selected:
                                playerProvider.selectedTeamId == team.teamId,
                            onSelectChanged: (_) {
                              playerProvider.setSelectedTeamId(team.teamId!);
                            },
                            cells: [
                              DataCell(SizedBox(
                                width: constraints.maxWidth * 0.8,
                                child: Text(
                                  team.name,
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
