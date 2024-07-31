import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/round_repository_custom.dart';
import 'package:flutter/cupertino.dart';

class RoundProvider with ChangeNotifier {
  final RoundRepositoryCustom roundRepositoryCustom = RoundRepositoryCustom();

  RoundModel? _round;

  RoundModel? get round => _round;

  Future<void> fetchRound(int eventId, int currentRound) async {
    // fixme
    await Future.delayed(Duration(seconds: 1));
    _round = await roundRepositoryCustom.findRound(eventId, currentRound);
    notifyListeners();
  }
}