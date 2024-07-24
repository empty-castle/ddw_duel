import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/player/repository/player_repository.dart';
import 'package:flutter/material.dart';

import '../domain/team/domain/team.dart';
import '../domain/team/repository/team_repository.dart';

class PlayerProvider with ChangeNotifier {
  final TeamRepository teamRepo = TeamRepository();
  final PlayerRepository playerRepo = PlayerRepository();

  List<Team> _teams = [];
  int? _selectedTeamId;
  List<Player> _players = [];

  List<Team> get teams => _teams;
  int? get selectedTeamId => _selectedTeamId;
  List<Player> get players => _players;

  void setTeams(List<Team> teams) {
    _teams = teams;
    notifyListeners();
  }

  void setSelectedTeamId(int selectedTeamId) {
    _selectedTeamId = selectedTeamId;
    fetchPlayers(selectedTeamId);
    notifyListeners();
  }

  void fetchTeams(int eventId) async {
    List<Team> teams = await teamRepo.findTeams(eventId);
    setTeams(teams);
  }

  void setPlayers(List<Player> players) {
    _players = players;
    notifyListeners();
  }

  void fetchPlayers(int teamId) async {
    List<Player> players = await playerRepo.findPlayers(teamId);
    setPlayers(players);
  }

  void clearPlayerProvider() {
    _teams = [];
    _players = [];
    _selectedTeamId = null;
  }
}