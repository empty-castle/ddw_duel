import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/event_provider.dart';
import '/domain/event/domain/event.dart';
import '/domain/event/repository/event_repository.dart';
import '../manage/manage_page.dart';

class EventDetailComponent extends StatefulWidget {
  const EventDetailComponent({super.key});

  @override
  State<EventDetailComponent> createState() => _EventDetailComponentState();
}

class _EventDetailComponentState extends State<EventDetailComponent> {
  final EventRepository eventRepo = EventRepository();

  Event? _event;

  void _onPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ManagePage(
                event: _event!,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: _onPressed,
              child: const Text(
                '관리',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('제목:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(_event!.name,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('설명:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            _event!.description ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('참가자 명단:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    int? eventId = Provider.of<EventProvider>(context).eventId;
    if (eventId != null) {
      Event? event = await eventRepo.findEventsById(eventId);
      setState(() {
        _event = event;
      });
    }
  }
}
