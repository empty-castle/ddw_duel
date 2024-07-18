import 'package:ddw_duel/domain/match/match_enum.dart';
import 'package:ddw_duel/domain/match/domain/match.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';

class MatchRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveMatch(Match match) async {
    Database db = await dbHelper.database;
    await db.insert(
      MatchEnum.tableName.label,
      match.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMatch(Match match) async {
    Database db = await dbHelper.database;
    await db.update(
      MatchEnum.tableName.label,
      match.toMap(),
      where: "${MatchEnum.id.label} = ?",
      whereArgs: [match.matchId],
    );
  }

  Future<void> deleteMatch(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      MatchEnum.tableName.label,
      where: "${MatchEnum.id.label} = ?",
      whereArgs: [id],
    );
  }
}