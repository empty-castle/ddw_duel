import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/domain/game/domain/game.dart';
import 'package:ddw_duel/domain/game/repository/game_repository.dart';
import 'package:flutter/cupertino.dart';

class GameProvider with ChangeNotifier {
  final GameRepository gameRepo = GameRepository();

  Map<int, Game> _gameMap = {};

  Map<int, Game> get gameMap => _gameMap;

  void setGames(List<Game> games) {
    _gameMap = _gameListToMap(games);
    notifyListeners();
  }

  Future<void> fetchGames(Event event) async {
    // fixme
    await Future.delayed(Duration(seconds: 1));
    List<Game> games = await gameRepo.findCurrentRoundGames(event.eventId!, event.currentRound);
    _gameMap = _gameListToMap(games);
    notifyListeners();
  }

  Map<int, Game> _gameListToMap(List<Game> games) {
    Map<int, Game> gameMap = {};
    for (var game in games) {
      gameMap[game.gameId!] = game;
    }
    return gameMap;
  }
}
