import 'package:ddw_duel/db/domain/type/duel_status.dart';
import 'package:ddw_duel/db/enum/duel_enum.dart';
import 'package:ddw_duel/db/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Duel implements TableAbstract {
  int? duelId;
  final int gameId;
  final int position;
  final DuelStatus status;
  final int player1Id;
  double player1Point;
  final int player2Id;
  double player2Point;

  Duel(
      {this.duelId,
      required this.gameId,
      required this.position,
      required this.status,
      required this.player1Id,
      this.player1Point = 0.0,
      required this.player2Id,
      this.player2Point = 0.0});

  @override
  Map<String, dynamic> toMap() {
    return {
      DuelEnum.gameId.label: gameId,
      DuelEnum.position.label: position,
      DuelEnum.status.label: status.name,
      DuelEnum.player1Id.label: player1Id,
      DuelEnum.player1Point.label: player1Point,
      DuelEnum.player2Id.label: player2Id,
      DuelEnum.player2Point.label: player2Point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${DuelEnum.tableName.label}(
        ${DuelEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DuelEnum.gameId.label} INTEGER,
        ${DuelEnum.position.label} INTEGER,
        ${DuelEnum.status.label} TEXT,
        ${DuelEnum.player1Id.label} INTEGER,
        ${DuelEnum.player1Point.label} REAL,
        ${DuelEnum.player2Id.label} INTEGER,
        ${DuelEnum.player2Point.label} REAL
      )
    ''');
  }
}
