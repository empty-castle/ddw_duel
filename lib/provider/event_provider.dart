import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  int? _eventId;

  int? get eventId => _eventId;

  void setEventId(int eventId) {
    _eventId = eventId;
    notifyListeners();
  }
}