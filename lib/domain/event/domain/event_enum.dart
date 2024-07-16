enum EventEnum {
  tableName(label: 'Event'),
  id(label: 'id'),
  name(label: 'name'),
  description(label: 'description'),
  ;

  final String label;

  const EventEnum({required this.label});
}