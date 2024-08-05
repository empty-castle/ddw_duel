import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/event_provider.dart';
import '../manage/manage_page.dart';

class EventDetailComponent extends StatefulWidget {
  const EventDetailComponent({super.key});

  @override
  State<EventDetailComponent> createState() => _EventDetailComponentState();
}

class _EventDetailComponentState extends State<EventDetailComponent> {
  final EventRepository eventRepo = EventRepository();

  void _onPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<SelectedEventProvider>(
        builder: (context, provider, child) {
          if (provider.selectedEvent == null) {
            return const SizedBox.shrink();
          }

          return Column(
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(provider.selectedEvent!.name,
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
                                provider.selectedEvent!.description ?? '',
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }
}
