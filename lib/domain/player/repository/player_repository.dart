import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/player/player_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';

class PlayerRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> savePlayer(Player player) async {
    Database db = await dbHelper.database;
    await db.insert(
      PlayerEnum.tableName.label,
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlayer(Player player) async {
    Database db = await dbHelper.database;
    await db.update(
      PlayerEnum.tableName.label,
      player.toMap(),
      where: "${PlayerEnum.id.label} = ?",
      whereArgs: [player.playerId],
    );
  }

  Future<void> deletePlayer(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      PlayerEnum.tableName.label,
      where: "${PlayerEnum.id.label} = ?",
      whereArgs: [id],
    );
  }
}