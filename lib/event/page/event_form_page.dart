import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/domain/event/repository/event_repository.dart';
import 'package:flutter/material.dart';

import '../../base/SnackbarHelper.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final EventRepository eventRepo = EventRepository();

  final _formKey = GlobalKey<FormState>();

  bool hasUpdated = false;

  String _eventName = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, hasUpdated);
        }
        return;
      },
      child: Scaffold(
        appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            centerTitle: true,
            title: const Text('이벤트 등록')),
        body: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextButton(
                          onPressed: _onPressed,
                          style: TextButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.blue)),
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
                          ),
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await eventRepo
          .saveEvent(Event(name: _eventName, description: _description));
      hasUpdated = true;
      if (mounted) {
        SnackbarHelper.showSnackbar(context, "$_eventName 이벤트 저장이 완료되었습니다.");
      }
      _formKey.currentState!.reset();
    }
  }
}
