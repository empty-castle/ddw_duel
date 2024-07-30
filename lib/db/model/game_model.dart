import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/game.dart';

class GameModel {
  final Game game;
  final List<Duel> duels;

  GameModel({required this.duels, required this.game});
}