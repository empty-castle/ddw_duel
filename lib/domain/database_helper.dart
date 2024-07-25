import 'package:ddw_duel/domain/match/domain/match.dart';
import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'duel/domain/duel.dart';
import 'event/domain/event.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'ddw_duel.db');

    var myDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return myDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    Event.initTable(db, newVersion);
    Team.initTable(db, newVersion);
    Player.initTable(db, newVersion);
    Match.initTable(db, newVersion);
    Duel.initTable(db, newVersion);
  }
}
