enum GameEnum {
  tableName('Game'),
  id('gameId'),
  eventId('eventId'),
  round('round'),
  status('status'),
  team1Id('team1Id'),
  team1Point('team1Point'),
  team2Id('team2Id'),
  team2Point('team2Point'),
  ;

  final String label;

  const GameEnum(this.label);
}
