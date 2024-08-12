import 'package:ddw_duel/db/enum/event_enum.dart';
import 'package:ddw_duel/db/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Event implements TableAbstract {
  final int? eventId;
  String name;
  String? description;
  int currentRound;
  int endRound;

  Event({this.eventId, required this.name, this.description, this.currentRound = 0, this.endRound = 0});

  @override
  Map<String, dynamic> toMap() {
    return {
      EventEnum.name.label: name,
      EventEnum.description.label: description,
      EventEnum.currentRound.label: currentRound,
      EventEnum.endRound.label: endRound,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${EventEnum.tableName.label}(
        ${EventEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${EventEnum.name.label} TEXT,
        ${EventEnum.description.label} TEXT,
        ${EventEnum.currentRound.label} INTEGER DEFAULT 0,
        ${EventEnum.endRound.label} INTEGER DEFAULT 0
      )
    ''');
  }
  
  static Future<void> upgradeTable(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

    }
  }
}
