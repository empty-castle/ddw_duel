import 'package:ddw_duel/domain/event/domain/event_enum.dart';
import 'package:ddw_duel/domain/table_abstract.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Event implements TableAbstract {
  final int? id;
  final String name;
  final String? description;

  Event({this.id, required this.name, this.description});

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description};
  }

  static Future<void> initTable(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${EventEnum.tableName.label}(
        ${EventEnum.id.label}id INTEGER PRIMARY KEY AUTOINCREMENT,
        ${EventEnum.name.label} TEXT,
        ${EventEnum.description.label} TEXT
      )
    ''');
  }
}
