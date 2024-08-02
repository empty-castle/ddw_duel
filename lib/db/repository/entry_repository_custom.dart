import 'package:ddw_duel/db/database_helper.dart';
import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';
import 'package:ddw_duel/db/model/entry_model.dart';

class EntryRepositoryCustom {
  final DatabaseHelper dbHelper = DatabaseHelper();

  final TeamRepository teamRepo = TeamRepository();
  final PlayerRepository playerRepo = PlayerRepository();

  Future<List<EntryModel>> findAllEntry(int eventId) async {
    List<EntryModel> results = [];
    List<Team> teams = await teamRepo.findTeams(eventId);
    for (var team in teams) {
      List<Player> players = await playerRepo.findPlayers(team.teamId!);
      results.add(EntryModel(team: team, players: players));
    }
    return results;
  }

  Future<Map<int, EntryModel>> findAllEntryMap(int eventId) async {
    Map<int, EntryModel> results = {};
    List<Team> teams = await teamRepo.findTeams(eventId);
    for (var team in teams) {
      List<Player> players = await playerRepo.findPlayers(team.teamId!);
      results[team.teamId!] = EntryModel(team: team, players: players);
    }
    return results;
  }

  Future<EntryModel?> findEntry(int teamId) async {
    Team? team = await teamRepo.findTeam(teamId);
    if (team == null) {
      return null;
    }
    List<Player> players = await playerRepo.findPlayers(teamId);
    return EntryModel(team: team, players: players);
  }
}
