import 'package:ddw_duel/domain/duel/domain/duel.dart';
import 'package:flutter/cupertino.dart';

class DuelProvider with ChangeNotifier {
  final Map<int, Map<int, Duel>> _duelMap = {};

  Map<int, Map<int, Duel>> get duelMap => _duelMap;

  void putDuel(Duel duel) {
    if (_duelMap.containsKey(duel.gameId)) {
      _duelMap[duel.gameId]![duel.duelPosition] = duel;
    } else {
      _duelMap[duel.gameId] = {duel.duelPosition: duel};
    }
  }
}
