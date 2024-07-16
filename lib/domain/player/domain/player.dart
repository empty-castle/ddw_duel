import 'package:ddw_duel/domain/player/domain/player_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Player implements TableAbstract {
  final int? id;
  final String name;

  Player({required this.id, required this.name});

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${PlayerEnum.tableName.label}(
        ${PlayerEnum.id.label}id INTEGER PRIMARY KEY AUTOINCREMENT,
      )
    ''');
  }
}