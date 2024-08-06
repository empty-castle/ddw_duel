import 'package:ddw_duel/db/domain/event.dart';
import 'package:flutter/cupertino.dart';

class SelectedEventProvider with ChangeNotifier {
  Event? _selectedEvent;

  Event? get selectedEvent => _selectedEvent;

  void notify() {
    notifyListeners();
  }

  void setSelectedEvent(Event selectedEvent) {
    _selectedEvent = selectedEvent;
    notifyListeners();
  }
}