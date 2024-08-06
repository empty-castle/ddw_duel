import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/event.dart';
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();

  void _onPressedSaveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Event selectedEvent =
          Provider.of<SelectedEventProvider>(context, listen: false)
              .selectedEvent!;

      selectedEvent.name = _eventNameController.text;
      selectedEvent.description = _eventDescriptionController.text;

      await eventRepo.saveEvent(selectedEvent);

      if (!mounted) return;
      Provider.of<SelectedEventProvider>(context, listen: false).notify();
      await Provider.of<EventProvider>(context, listen: false).fetchEvent();

      if (!mounted) return;
      SnackbarHelper.showInfoSnackbar(
          context, "${_eventNameController.text} 저장이 완료되었습니다.");

      _formKey.currentState!.reset();
    }
  }

  void _onPressedManage() async {
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

          _eventNameController.text = provider.selectedEvent!.name;
          _eventDescriptionController.text =
              provider.selectedEvent!.description ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _onPressedManage,
                    child: const Text(
                      '관리',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 1,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: _eventNameController,
                          decoration: const InputDecoration(
                            labelText: '이벤트 이름',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이벤트 이름을 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: _eventDescriptionController,
                          decoration: const InputDecoration(
                            labelText: '이벤트 설명',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ElevatedButton(
                          onPressed: _onPressedSaveEvent,
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 150.0),
                          ),
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
