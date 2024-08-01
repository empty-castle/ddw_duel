enum EventEnum {
  tableName('Event'),
  id('eventId'),
  name('name'),
  description('description'),
  currentRound('currentRound'),
  endRound('endRound')
  ;

  final String label;

  const EventEnum(this.label);
}