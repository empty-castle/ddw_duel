import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/event/event_form_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/domain/event/domain/event.dart';
import '/domain/event/repository/event_repository.dart';
import '../../provider/event_provider.dart';

class EventListComponent extends StatefulWidget {
  const EventListComponent({super.key});

  @override
  State<EventListComponent> createState() => _EventListComponentState();
}

class _EventListComponentState extends State<EventListComponent> {
  final EventRepository eventRepo = EventRepository();

  int? _selectedEventId;

  void _onSelectEvent(Event event) {
    setState(() {
      _selectedEventId = event.eventId;
    });
    Provider.of<SelectedEventProvider>(context, listen: false).setSelectedEvent(event);
  }

  void _onPressed() async {
    bool? needRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EventFormPage()),
    );

    if (needRefresh != null && needRefresh && mounted) {
      Provider.of<EventProvider>(context, listen: false).fetchEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      onPressed: _onPressed,
                      child: const Text(
                        '등록',
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
                            DataColumn(
                                label: Text('설명',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
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
      )
    );
  }
}
