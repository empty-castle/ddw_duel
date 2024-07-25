import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:flutter/cupertino.dart';

class SelectedTeamProvider with ChangeNotifier {
  Team? _selectedTeam;

  Team? get selectedTeam => _selectedTeam;

  void setSelectedTeam(Team team) {
    _selectedTeam = team;
    notifyListeners();
  }
}