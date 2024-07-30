import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/rank_team_model.dart';

class RoundModel {
  final List<RankTeamModel> rankedTeams;
  final List<GameModel> games;

  RoundModel({required this.games, required this.rankedTeams});
}
