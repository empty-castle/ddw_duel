import 'package:ddw_duel/domain/team/team_enum.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../database_helper.dart';
import '../domain/team.dart';

class TeamRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<int> saveTeam(Team team) async {
    Database db = await dbHelper.database;
    return await db.insert(
      TeamEnum.tableName.label,
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Team>> findTeams(int eventId) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
        TeamEnum.tableName.label,
        where: '${TeamEnum.eventId.label} = ?',
        whereArgs: [eventId]);
    return List.generate(maps.length, (i) {
      return _makeTeam(maps[i]);
    });
  }

  Future<Team?> findTeam(int teamId) async {
    Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
        TeamEnum.tableName.label,
        where: '${TeamEnum.id.label} = ?',
        whereArgs: [teamId]);
    if (maps.isNotEmpty) {
      return _makeTeam(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateTeam(Team team) async {
    Database db = await dbHelper.database;
    await db.update(
      TeamEnum.tableName.label,
      team.toMap(),
      where: "${TeamEnum.id.label} = ?",
      whereArgs: [team.teamId],
    );
  }

  Future<void> deleteTeam(int id) async {
    Database db = await dbHelper.database;
    await db.delete(
      TeamEnum.tableName.label,
      where: "${TeamEnum.id.label} = ?",
      whereArgs: [id],
    );
  }

  Team _makeTeam(Map<String, dynamic> map) {
    return Team(
      teamId: map[TeamEnum.id.label],
      eventId: map[TeamEnum.eventId.label],
      name: map[TeamEnum.name.label],
      point: map[TeamEnum.point.label]
    );
  }
}
