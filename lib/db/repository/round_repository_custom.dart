import 'package:ddw_duel/db/database_helper.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/rank_team_model.dart';
import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/db/repository/team_repository.dart';

class RoundRepositoryCustom {
  final DatabaseHelper dbHelper = DatabaseHelper();

  final GameRepository gameRepo = GameRepository();
  final DuelRepository duelRepo = DuelRepository();
  final TeamRepository teamRepo = TeamRepository();
  final PlayerRepository playerRepo = PlayerRepository();

  Future<RoundModel> findRound(int eventId, int currentRound) async {
    List<Team> teams = await teamRepo.findTeams(eventId);
    List<RankTeamModel> rankedTeams = await _makeRankedTeams(teams);
    List<Game> games = await gameRepo.findCurrentRoundGames(eventId, currentRound);

    return RoundModel(games: , rankedTeams: rankedTeams);
  }

  Future<List<RankTeamModel>> _makeRankedTeams(List<Team> teams) async {
    List<Team> sortedTeams = List.from(teams)
      ..sort((a, b) => b.point.compareTo(a.point));

    List<RankTeamModel> rankedTeams = [];
    int rank = 1;
    for (int i = 0; i < sortedTeams.length; i++) {
      if (i > 0 && sortedTeams[i].point < sortedTeams[i - 1].point) {
        rank = i + 1;
      }
      List<Player> players =
          await playerRepo.findPlayers(sortedTeams[i].teamId!);
      rankedTeams.add(
          RankTeamModel(team: sortedTeams[i], rank: rank, players: players));
    }

    return rankedTeams;
  }

  Future<List<GameModel>> _makeGameModels(List<Game> games) async {

  }
}
