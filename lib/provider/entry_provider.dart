import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/repository/entry_repository_custom.dart';
import 'package:flutter/cupertino.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepositoryCustom entryRepositoryCustom = EntryRepositoryCustom();

  List<EntryModel> _entries = [];

  List<EntryModel> get entries => _entries;

  Future<void> fetchEntries(int eventId) async {
    // fixme
    await Future.delayed(Duration(seconds: 1));
    _entries = await entryRepositoryCustom.findAllEntry(eventId);
    notifyListeners();
  }
}