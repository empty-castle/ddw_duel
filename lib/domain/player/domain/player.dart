import 'package:ddw_duel/domain/player/player_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Player implements TableAbstract {
  final int? playerId;
  final String name;
  final int teamId;
  final int playerOrder;
  final int point = 0;

  Player(
      {this.playerId,
      required this.name,
      required this.teamId,
      required this.playerOrder});

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teamId': teamId,
      'playerOrder': playerOrder,
      'point': point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${PlayerEnum.tableName.label}(
        ${PlayerEnum.id.label}id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${PlayerEnum.name.label} TEXT,
        ${PlayerEnum.teamId.label} INTEGER,
        ${PlayerEnum.playerOrder.label} INTEGER,
        ${PlayerEnum.point.label} INTEGER
      )
    ''');
  }
}
