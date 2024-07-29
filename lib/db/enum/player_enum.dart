enum PlayerEnum {
  tableName('Player'),
  id('playerId'),
  name('name'),
  teamId('teamId'),
  position('position'),
  point('point'),
  ;

  final String label;

  const PlayerEnum(this.label);
}