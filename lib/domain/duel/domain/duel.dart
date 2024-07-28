import 'package:ddw_duel/domain/duel/duel_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Duel implements TableAbstract {
  final int? duelId;
  final int gameId;
  final int duelPosition;
  final int player1Id;
  final int player1Point;
  final int player2Id;
  final int player2Point;

  Duel(
      {this.duelId,
      required this.gameId,
      required this.duelPosition,
      required this.player1Id,
      this.player1Point = 0,
      required this.player2Id,
      this.player2Point = 0});

  @override
  Map<String, dynamic> toMap() {
    return {
      DuelEnum.gameId.label: gameId,
      DuelEnum.duelPosition.label: duelPosition,
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
        ${DuelEnum.duelPosition.label} INTEGER,
        ${DuelEnum.player1Id.label} INTEGER,
        ${DuelEnum.player1Point.label} INTEGER,
        ${DuelEnum.player2Id.label} INTEGER,
        ${DuelEnum.player2Point.label} INTEGER
      )
    ''');
  }
}
