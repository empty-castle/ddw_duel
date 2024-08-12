import 'package:ddw_duel/db/enum/player_enum.dart';
import 'package:ddw_duel/db/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Player implements TableAbstract {
  final int? playerId;
  String name;
  final int teamId;
  final int position;

  Player(
      {this.playerId,
      required this.name,
      required this.teamId,
      required this.position});

  @override
  Map<String, dynamic> toMap() {
    return {
      PlayerEnum.name.label: name,
      PlayerEnum.teamId.label: teamId,
      PlayerEnum.position.label: position
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${PlayerEnum.tableName.label}(
        ${PlayerEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PlayerEnum.name.label} TEXT,
        ${PlayerEnum.teamId.label} INTEGER,
        ${PlayerEnum.position.label} INTEGER
      )
    ''');
  }

  static Future<void> upgradeTable(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

    }
  }
}
