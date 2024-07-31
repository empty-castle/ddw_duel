import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/enum/duel_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database_helper.dart';

class DuelRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<int> saveDuel(Duel duel) async {
    Database db = await dbHelper.database;
    if (duel.duelId != null) {
      await db.update(
        DuelEnum.tableName.label,
        duel.toMap(),
        where: "${DuelEnum.id.label} = ?",
        whereArgs: [duel.duelId],
      );
      return duel.duelId!;
    } else {
      return await db.insert(
        DuelEnum.tableName.label,
        duel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Duel>> findDuels(int gameId) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
        DuelEnum.tableName.label,
        where: '${DuelEnum.gameId.label} = ?',
        whereArgs: [gameId],
        orderBy: '${DuelEnum.position.label} ASC');
    return List.generate(maps.length, (i) {
      return _makeDuel(maps[i]);
    });
  }

  Future<void> deleteDuel(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      DuelEnum.tableName.label,
      where: "${DuelEnum.id.label} = ?",
      whereArgs: [id],
    );
  }

  _makeDuel(Map<String, dynamic> map) {
    return Duel(
      duelId: map[DuelEnum.id.label],
      gameId: map[DuelEnum.gameId.label],
      position: map[DuelEnum.position.label],
      player1Id: map[DuelEnum.player1Id.label],
      player1Point: map[DuelEnum.player1Point.label],
      player2Id: map[DuelEnum.player2Id.label],
      player2Point: map[DuelEnum.player2Point.label],
    );
  }
}
