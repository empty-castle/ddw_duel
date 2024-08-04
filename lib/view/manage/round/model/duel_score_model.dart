import 'package:ddw_duel/db/domain/type/duel_status.dart';

class DuelScoreModel {
  final String label;
  final DuelStatus duelStatus;
  final int player1Wins;
  final int player2Wins;

  DuelScoreModel(
      {required this.label,
      required this.duelStatus,
      required this.player1Wins,
      required this.player2Wins});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final DuelScoreModel otherModel = other as DuelScoreModel;
    return duelStatus == otherModel.duelStatus &&
        player1Wins == otherModel.player1Wins &&
        player2Wins == otherModel.player2Wins;
  }

  @override
  int get hashCode =>
      duelStatus.hashCode ^ player1Wins.hashCode ^ player2Wins.hashCode;
}
