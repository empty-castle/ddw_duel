enum GameEnum {
  tableName('Game'),
  id('gameId'),
  duelId('duelId'),
  gameOrder('gameOrder'),
  isPlayer1Win('isPlayer1Win'),
  ;

  final String label;

  const GameEnum(this.label);
}