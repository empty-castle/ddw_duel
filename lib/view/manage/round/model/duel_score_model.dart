class DuelScoreModel {
  final String label;
  final int player1Wins;
  final int player2Wins;

  DuelScoreModel({required this.label, required this.player1Wins, required this.player2Wins});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final DuelScoreModel otherModel = other as DuelScoreModel;
    return player1Wins == otherModel.player1Wins &&
        player2Wins == otherModel.player2Wins;
  }

  @override
  int get hashCode => player1Wins.hashCode ^ player2Wins.hashCode;
}