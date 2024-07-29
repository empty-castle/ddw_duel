enum EventEnum {
  tableName('Event'),
  id('eventId'),
  name('name'),
  description('description'),
  currentRound('currentRound'),
  ;

  final String label;

  const EventEnum(this.label);
}