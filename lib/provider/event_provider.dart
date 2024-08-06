import 'package:ddw_duel/db/domain/event.dart';
import 'package:ddw_duel/db/repository/event_repository.dart';
import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  final EventRepository eventRepo = EventRepository();

  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> fetchEvent() async {
    List<Event> events = await eventRepo.findEvents();
    _events = events;
    notifyListeners();
  }
}