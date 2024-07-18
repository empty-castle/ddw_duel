import 'package:ddw_duel/domain/team/team_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';
import '../domain/team.dart';

class TeamRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> saveMatch(Team team) async {
    Database db = await dbHelper.database;
    await db.insert(
      TeamEnum.tableName.label,
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMatch(Team team) async {
    Database db = await dbHelper.database;
    await db.update(
      TeamEnum.tableName.label,
      team.toMap(),
      where: "${TeamEnum.id.label} = ?",
      whereArgs: [team.teamId],
    );
  }

  Future<void> deleteMatch(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      TeamEnum.tableName.label,
      where: "${TeamEnum.id.label} = ?",
      whereArgs: [id],
    );
  }
}