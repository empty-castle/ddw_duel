import 'package:ddw_duel/db/enum/game_enum.dart';
import 'package:ddw_duel/db/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'type/game_status.dart';

class Game implements TableAbstract {
  final int? gameId;
  final int eventId;
  final int round;
  GameStatus status;
  int team1Id;
  double team1Point;
  int team2Id;
  double team2Point;

  Game(
      {this.gameId,
      this.team1Point = 0.0,
      this.team2Point = 0.0,
      required this.eventId,
      required this.round,
      required this.status,
      required this.team1Id,
      required this.team2Id});

  @override
  Map<String, dynamic> toMap() {
    return {
      GameEnum.eventId.label: eventId,
      GameEnum.round.label: round,
      GameEnum.status.label: status.name,
      GameEnum.team1Id.label: team1Id,
      GameEnum.team1Point.label: team1Point,
      GameEnum.team2Id.label: team2Id,
      GameEnum.team2Point.label: team2Point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${GameEnum.tableName.label}(
        ${GameEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${GameEnum.eventId.label} INTEGER,
        ${GameEnum.round.label} INTEGER,
        ${GameEnum.status.label} TEXT,
        ${GameEnum.team1Id.label} INTEGER,
        ${GameEnum.team1Point.label} REAL,
        ${GameEnum.team2Id.label} INTEGER,
        ${GameEnum.team2Point.label} REAL
      )
    ''');
  }
}
