import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';

class RankTeamModel {
  final int rank;
  final Team team;
  final List<Player> players;

  RankTeamModel({required this.team, required this.rank, required this.players});
}