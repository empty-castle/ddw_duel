import 'package:ddw_duel/domain/duel/domain/duel.dart';
import 'package:ddw_duel/domain/duel/duel_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';

class DuelRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveDuel(Duel duel) async {
    Database db = await dbHelper.database;
    await db.insert(
      DuelEnum.tableName.label,
      duel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDuel(Duel duel) async {
    Database db = await dbHelper.database;
    await db.update(
      DuelEnum.tableName.label,
      duel.toMap(),
      where: "${DuelEnum.id.label} = ?",
      whereArgs: [duel.duelId],
    );
  }

  Future<void> deleteDuel(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      DuelEnum.tableName.label,
      where: "${DuelEnum.id.label} = ?",
      whereArgs: [id],
    );
  }
}