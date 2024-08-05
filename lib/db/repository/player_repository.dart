import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/enum/player_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database_helper.dart';

class PlayerRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<int> savePlayer(Player player) async {
    Database db = await dbHelper.database;
    if (player.playerId != null) {
      await db.update(
        PlayerEnum.tableName.label,
        player.toMap(),
        where: "${PlayerEnum.id.label} = ?",
        whereArgs: [player.playerId],
      );
      return player.playerId!;
    } else {
      return await db.insert(
        PlayerEnum.tableName.label,
        player.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Player>> findPlayers(int teamId) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
        PlayerEnum.tableName.label,
        where: '${PlayerEnum.teamId.label} = ?',
        whereArgs: [teamId],
        orderBy: '${PlayerEnum.position.label} ASC');
    return List.generate(maps.length, (i) {
      return _makePlayer(maps[i]);
    });
  }

  Future<void> deletePlayer(int teamId) async {
    Database db = await dbHelper.database;
    await db.delete(
      PlayerEnum.tableName.label,
      where: "${PlayerEnum.teamId.label} = ?",
      whereArgs: [teamId],
    );
  }

  Player _makePlayer(Map<String, dynamic> map) {
    return Player(
        playerId: map[PlayerEnum.id.label],
        name: map[PlayerEnum.name.label],
        teamId: map[PlayerEnum.teamId.label],
        position: map[PlayerEnum.position.label]);
  }
}
