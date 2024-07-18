import 'package:flutter/material.dart';

import '../../domain/event/domain/event.dart';

class EventListComponent extends StatefulWidget {
  final List<Event> events;
  final Function(int eventId) onSelectEvent;

  const EventListComponent(
      {super.key, required this.onSelectEvent, required this.events});

  @override
  State<EventListComponent> createState() => _EventListComponentState();
}

class _EventListComponentState extends State<EventListComponent> {
  int? _selectedEventId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
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
              rows: widget.events.map((event) {
                return DataRow(
                  selected: _selectedEventId == event.eventId,
                  onSelectChanged: (_) {
                    setState(() {
                      _selectedEventId = event.eventId;
                      widget.onSelectEvent(event.eventId!);
                    });
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
        );
      },
    );
  }
}
