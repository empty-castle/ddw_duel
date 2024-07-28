import 'package:ddw_duel/domain/team/domain/team.dart';
import 'package:ddw_duel/domain/team/repository/team_repository.dart';
import 'package:flutter/cupertino.dart';

class TeamProvider with ChangeNotifier {
  final TeamRepository teamRepo = TeamRepository();

  List<Team> _teams = [];

  List<Team> get teams => _teams;

  Future<void> fetchTeams(int eventId) async {
    // fixme
    await Future.delayed(Duration(seconds: 1));
    List<Team> teams = await teamRepo.findTeams(eventId);
    _teams = teams;
    notifyListeners();
  }
}