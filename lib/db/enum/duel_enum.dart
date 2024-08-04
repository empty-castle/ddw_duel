enum DuelEnum {
  tableName('Duel'),
  id('duelId'),
  gameId('gameId'),
  position('position'),
  status('status'),
  player1Id('player1Id'),
  player1Point('player1Point'),
  player2Id('player2Id'),
  player2Point('player2Point'),
  ;

  final String label;

  const DuelEnum(this.label);
}