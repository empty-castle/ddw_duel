import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/domain/event/repository/event_repository.dart';
import 'package:flutter/material.dart';

class EventFormComponent extends StatefulWidget {
  final Function() onSave;

  const EventFormComponent({super.key, required this.onSave});

  @override
  State<EventFormComponent> createState() => _EventFormComponentState();
}

class _EventFormComponentState extends State<EventFormComponent> {
  final EventRepository eventRepo = EventRepository();

  final _formKey = GlobalKey<FormState>();

  String _eventName = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '이벤트 이름',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                _eventName = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이벤트 이름을 입력해주세요.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: '설명',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) {
                _description = value ?? '';
              },
              validator: (value) {
                return null;
              },
              maxLines: 3,
            ),
          ),
          ElevatedButton(
            onPressed: _onPressed,
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  void _onPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await eventRepo
          .saveEvent(Event(name: _eventName, description: _description));
      widget.onSave();
      _formKey.currentState!.reset();
    }
  }
}
