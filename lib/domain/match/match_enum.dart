enum MatchEnum {
  tableName('Match'),
  id('matchId'),
  eventId('eventId'),
  round('round'),
  team1Id('team1Id'),
  team1Point('team1Point'),
  team2Id('team2Id'),
  team2Point('team2Point'),
  ;

  final String label;

  const MatchEnum(this.label);
}
