import 'package:ddw_duel/domain/game/domain/game.dart';
import 'package:flutter/cupertino.dart';

class RoundProvider with ChangeNotifier {
  List<Game> _games = [];

  List<Game> get games => _games;

  void setGames(List<Game> games) {
    _games = games;
    notifyListeners();
  }
}
