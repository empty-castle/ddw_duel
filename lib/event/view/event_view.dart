import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/domain/event/repository/event_repository.dart';
import 'package:ddw_duel/event/component/event_detail_component.dart';
import 'package:ddw_duel/event/component/event_form_component.dart';
import 'package:flutter/material.dart';

import '../component/event_list_component.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final EventRepository eventRepo = EventRepository();

  List<Event> _events = [];

  int? _eventId;

  void _onSelectEvent(int eventId) {
    setState(() {
      _eventId = eventId;
    });
  }

  void _onSaveEvent() {
    refreshEvent();
  }

  void refreshEvent() async {
    var events = await eventRepo.findEvents();
    setState(() {
      _events = events;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white24, width: 0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '이벤트 생성',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        Expanded(
                            child: EventFormComponent(onSave: _onSaveEvent)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
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
                        events: _events,
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.white24, width: 0.3)),
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
