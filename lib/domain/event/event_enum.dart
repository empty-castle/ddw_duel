enum EventEnum {
  tableName('Event'),
  id('eventId'),
  name('name'),
  description('description'),
  ;

  final String label;

  const EventEnum(this.label);
}