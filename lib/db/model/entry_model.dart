import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/domain/team.dart';

class EntryModel {
  final Team team;
  final List<Player> players;

  EntryModel({required this.team, required this.players});
}
