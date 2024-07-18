import 'package:ddw_duel/domain/match/match_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Match implements TableAbstract {
  final int? matchId;
  final int eventId;
  final int round;
  final int team1Id;
  final int team1Point = 0;
  final int team2Id;
  final int team2Point = 0;

  Match(
      {this.matchId,
      required this.eventId,
      required this.round,
      required this.team1Id,
      required this.team2Id});

  @override
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'round': round,
      'team1Id': team1Id,
      'team1Point': team1Point,
      'team2Id': team2Id,
      'team2Point': team2Point,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${MatchEnum.tableName.label}(
        ${MatchEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MatchEnum.eventId.label} INTEGER,
        ${MatchEnum.round.label} INTEGER,
        ${MatchEnum.team1Id.label} INTEGER,
        ${MatchEnum.team1Point.label} INTEGER,
        ${MatchEnum.team2Id.label} INTEGER,
        ${MatchEnum.team2Point.label} INTEGER
      )
    ''');
  }
}
