import 'package:ddw_duel/domain/event/domain/event_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';
import '../domain/event.dart';

class EventRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveEvent(Event event) async {
    Database db = await dbHelper.database;
    await db.insert(
      EventEnum.tableName.label,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Event>> findEvents() async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(EventEnum.tableName.label);
    return _makeEventList(maps);
  }

  Future<Event?> findEventsById(int eventId) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
    await db.query(EventEnum.tableName.label, where: '${EventEnum.id.label} = ?', whereArgs: [eventId]);
    if (maps.isNotEmpty) {
      return _makeEvent(maps.first);
    } else {
      return null; // 결과가 없으면 null 반환
    }
  }

  Future<void> updateEvent(Event event) async {
    Database db = await dbHelper.database;
    await db.update(
      EventEnum.tableName.label,
      event.toMap(),
      where: "${EventEnum.id.label} = ?",
      whereArgs: [event.id],
    );
  }

  Future<void> deleteEvent(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      EventEnum.tableName.label,
      where: "${EventEnum.id.label} = ?",
      whereArgs: [id],
    );
  }

  List<Event> _makeEventList(List<Map<String, dynamic>> maps) {
    return List.generate(maps.length, (i) {
      return _makeEvent(maps[i]);
    });
  }

  Event _makeEvent(Map<String, dynamic> map) {
    return Event(
      id: map[EventEnum.id.label],
      name: map[EventEnum.name.label],
      description: map[EventEnum.description.label],
    );
  }
}
