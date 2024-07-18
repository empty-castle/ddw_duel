enum PlayerEnum {
  tableName('Player'),
  id('playerId'),
  name('name'),
  teamId('teamId'),
  playerOrder('playerOrder'),
  point('point'),
  ;

  final String label;

  const PlayerEnum(this.label);
}