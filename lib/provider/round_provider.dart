import 'package:ddw_duel/db/model/round_model.dart';
import 'package:flutter/cupertino.dart';

class RoundProvider with ChangeNotifier {
  RoundModel? _round;

  RoundModel? get round => _round;

  Future<void> fetchRound() async {

  }
}