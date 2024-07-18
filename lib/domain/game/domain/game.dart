import 'package:ddw_duel/domain/game/game_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Game implements TableAbstract {
  final int? gameId;
  final int duelId;
  final int gameOrder;
  final int isPlayer1Win;

  Game(
      {this.gameId,
      required this.duelId,
      required this.gameOrder,
      required this.isPlayer1Win});

  @override
  Map<String, dynamic> toMap() {
    return {
      'duelId': duelId,
      'gameOrder': gameOrder,
      'isPlayer1Win': isPlayer1Win,
    };
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${GameEnum.tableName.label}(
        ${GameEnum.id.label} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${GameEnum.duelId.label} INTEGER,
        ${GameEnum.gameOrder.label} INTEGER,
        ${GameEnum.isPlayer1Win.label} INTEGER
      )
    ''');
  }
}
