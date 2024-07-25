import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:flutter/cupertino.dart';

class SelectedEventProvider with ChangeNotifier {
  Event? _selectedEvent;

  Event? get selectedEvent => _selectedEvent;

  void setSelectedEvent(Event selectedEvent) {
    _selectedEvent = selectedEvent;
    notifyListeners();
  }
}