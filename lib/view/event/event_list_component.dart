import 'package:ddw_duel/base/dialog_helper.dart';
import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/event_provider.dart';

class EventListComponent extends StatefulWidget {
  const EventListComponent({super.key});

  @override
  State<EventListComponent> createState() => _EventListComponentState();
}

class _EventListComponentState extends State<EventListComponent> {
  final EventRepository eventRepo = EventRepository();
  final TeamRepository teamRepository = TeamRepository();
  final PlayerRepository playerRepository = PlayerRepository();
  final GameRepository gameRepository = GameRepository();
  final DuelRepository duelRepository = DuelRepository();

  int? _selectedEventId;

  void _onSelectEvent(Event event) {
    setState(() {
      _selectedEventId = event.eventId;
    });
    Provider.of<SelectedEventProvider>(context, listen: false)
        .setSelectedEvent(event);
  }

  void _onPressedNewEvent() async {
    int eventLength =
        Provider.of<EventProvider>(context, listen: false).events.length;
    final now = DateTime.now();

    String eventName = 'event#${eventLength + 1}';
    Event newEvent = Event(
      name: eventName,
      description: '날짜: ${now.year}/${now.month}/${now.day}',
    );
    eventRepo.saveEvent(newEvent);

    await Provider.of<EventProvider>(context, listen: false).fetchEvent();

    if (!mounted) return;
    SnackbarHelper.showInfoSnackbar(context, "$eventName 저장이 완료되었습니다.");
  }

  void _onPressedDeleteEvent() async {
    Future<void> onPressed() async {
      List<Team> teams = await teamRepository.findTeams(_selectedEventId!);
      for (Team team in teams) {
        playerRepository.deletePlayer(team.teamId!);
      }
      teamRepository.deleteTeamByEventId(_selectedEventId!);

      List<Game> games = await gameRepository.findGames(_selectedEventId!);
      for (Game game in games) {
        duelRepository.deleteDuel(game.gameId!);
      }
      gameRepository.deleteGame(_selectedEventId!);

      await eventRepo.deleteEvent(_selectedEventId!);

      if (!mounted) return;
      await Provider.of<EventProvider>(context, listen: false).fetchEvent();

      if (!mounted) return;
      Provider.of<SelectedEventProvider>(context, listen: false).setSelectedEvent(null);
      SnackbarHelper.showInfoSnackbar(context, "삭제가 완료되었습니다.");
    }

    DialogHelper.show(
        context: context,
        title: '이벤트 삭제 확인',
        content: '정말로 삭제하시겠습니까?',
        onPressedFunc: () => onPressed());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Consumer<EventProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _onPressedNewEvent,
                        child: const Text(
                          '이벤트 추가',
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        onPressed: _selectedEventId != null ? _onPressedDeleteEvent : null,
                        child: const Text(
                          '이벤트 삭제',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(
                              label: Text('이름',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('설명',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: provider.events.map((event) {
                          return DataRow(
                            selected: _selectedEventId == event.eventId,
                            onSelectChanged: (_) {
                              _onSelectEvent(event);
                            },
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: constraints.maxWidth * 0.4,
                                  child: Text(
                                    event.name,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: constraints.maxWidth * 0.5,
                                  child: Text(
                                    event.description ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ));
  }
}
