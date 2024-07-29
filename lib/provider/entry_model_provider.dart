import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/repository/entry_repository_custom.dart';
import 'package:flutter/cupertino.dart';

class EntryModelProvider with ChangeNotifier {
  final EntryRepositoryCustom entryRepositoryCustom = EntryRepositoryCustom();

  List<EntryModel> _entryModels = [];

  List<EntryModel> get entryModels => _entryModels;

  Future<void> fetchEntryModels(int eventId) async {
    // fixme
    await Future.delayed(Duration(seconds: 1));
    _entryModels = await entryRepositoryCustom.findAllEntryModel(eventId);
    notifyListeners();
  }
}