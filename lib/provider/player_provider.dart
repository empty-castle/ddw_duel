import 'package:ddw_duel/domain/player/domain/player.dart';
import 'package:ddw_duel/domain/player/repository/player_repository.dart';
import 'package:flutter/material.dart';

class PlayerProvider with ChangeNotifier {
  final PlayerRepository playerRepo = PlayerRepository();

  List<Player> _players = [];
  bool _isLoading = false;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;

  Future<void> fetchPlayers(int teamId) async {
    _isLoading = true;
    notifyListeners();

    // fixme
    await Future.delayed(Duration(seconds: 1));
    List<Player> players = await playerRepo.findPlayers(teamId);
    _players = players;

    _isLoading = false;
    notifyListeners();
  }

  void clearPlayerProvider() {
    _players = [];
  }
}