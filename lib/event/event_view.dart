import 'package:ddw_duel/domain/event/repository/event_repository.dart';
import 'package:ddw_duel/event/event_detail_component.dart';
import 'package:flutter/material.dart';

import 'event_list_component.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final EventRepository eventRepo = EventRepository();

  int? _eventId;

  void _onSelectEvent(int eventId) {
    setState(() {
      _eventId = eventId;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '이벤트 리스트',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Expanded(
                    child: EventListComponent(
                  onSelectEvent: _onSelectEvent,
                )),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.white24, width: 1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '이벤트 상세 정보',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Expanded(child: EventDetailComponent(eventId: _eventId)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
