import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:flutter/cupertino.dart';

class SelectedEntryProvider with ChangeNotifier {
  EntryModel? _selectedEntryModel;

  EntryModel? get selectedEntryModel => _selectedEntryModel;

  void notify() {
    notifyListeners();
  }

  void setSelectedEntry(EntryModel entryModel) {
    _selectedEntryModel = entryModel;
    notifyListeners();
  }

  void resetSelectedEntry() {
    _selectedEntryModel = null;
    notifyListeners();
  }
}