import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/enum/game_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database_helper.dart';

class GameRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveGame(Game game) async {
    Database db = await dbHelper.database;
    await db.insert(
      GameEnum.tableName.label,
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllGame(List<Game> games) async {
    Database db = await dbHelper.database;
    for (var game in games) {
      await db.insert(
        GameEnum.tableName.label,
        game.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Game>> findCurrentRoundGames(
      int eventId, int currentRound) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
        GameEnum.tableName.label,
        where: '${GameEnum.eventId.label} = ? AND ${GameEnum.round.label} = ?',
        whereArgs: [eventId, currentRound]);
    return List.generate(maps.length, (i) {
      return _makeGame(maps[i]);
    });
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

  Game _makeGame(Map<String, dynamic> map) {
    return Game(
      gameId: map[GameEnum.id.label],
      eventId: map[GameEnum.eventId.label],
      round: map[GameEnum.round.label],
      team1Id: map[GameEnum.team1Id.label],
      team1Point: map[GameEnum.team1Point.label],
      team2Id: map[GameEnum.team2Id.label],
      team2Point: map[GameEnum.team2Point.label],
    );
  }
}
