import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:ddw_duel/domain/team/team_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Team implements TableAbstract {
  final int? teamId;
  final String name;
  final int eventId;
  final int point = 0;

  Team({this.teamId, required this.eventId, required this.name});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'eventId': eventId,
      'point': point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${TeamEnum.tableName.label}(
        ${TeamEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TeamEnum.name.label} TEXT,
        ${TeamEnum.eventId.label} INTEGER,
        ${TeamEnum.point.label} INTEGER
      )
    ''');
  }
}
