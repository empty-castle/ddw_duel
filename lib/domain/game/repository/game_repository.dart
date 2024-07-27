import 'package:ddw_duel/domain/game/domain/game.dart';
import 'package:ddw_duel/domain/game/game_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';

class GameRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveGame(Game game) async {
    Database db = await dbHelper.database;
    await db.insert(
      GameEnum.tableName.label,
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGame(Game game) async {
    Database db = await dbHelper.database;
    await db.update(
      GameEnum.tableName.label,
      game.toMap(),
      where: "${GameEnum.id.label} = ?",
      whereArgs: [game.gameId],
    );
  }

  Future<void> deleteGame(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      GameEnum.tableName.label,
      where: "${GameEnum.id.label} = ?",
      whereArgs: [id],
    );
  }
}
