import 'package:ddw_duel/domain/duel/duel_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Duel implements TableAbstract {
  final int? duelId;
  final int matchId;
  final int duelOrder;
  final int player1Id;
  final int player1Point = 0;
  final int player2Id;
  final int player2Point = 0;

  Duel(
      {this.duelId,
      required this.matchId,
      required this.duelOrder,
      required this.player1Id,
      required this.player2Id});

  @override
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'duelOrder': duelOrder,
      'player1Id': player1Id,
      'player1Point': player1Point,
      'player2Id': player2Id,
      'player2Point': player2Point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${DuelEnum.tableName.label}(
        ${DuelEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DuelEnum.matchId.label} INTEGER,
        ${DuelEnum.duelOrder.label} INTEGER,
        ${DuelEnum.player1Id.label} INTEGER,
        ${DuelEnum.player1Point.label} INTEGER,
        ${DuelEnum.player2Id.label} INTEGER,
        ${DuelEnum.player2Point.label} INTEGER
      )
    ''');
  }
}
