import 'package:ddw_duel/db/domain/team.dart';

class TeamHistoryModel {
  final Team team;
  final Map<int, Team> history = {};

  TeamHistoryModel({required this.team});
}