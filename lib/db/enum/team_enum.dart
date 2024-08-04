enum TeamEnum {
  tableName('Team'),
  id('teamId'),
  name('name'),
  eventId('eventId'),
  point('point'),
  isForfeited('isForfeited')
  ;

  final String label;

  const TeamEnum(this.label);
}