import 'package:ddw_duel/db/domain/player.dart';

class PlayerHelper {
  static Player? getPlayerByPosition(List<Player> players, int position) {
    for (Player player in players) {
      if (player.position == position) {
        return player;
      }
    }
    return null;
  }
}