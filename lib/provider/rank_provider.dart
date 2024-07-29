import 'package:ddw_duel/db/domain/team.dart';
import 'package:ddw_duel/provider/model/RankTeam.dart';
import 'package:flutter/cupertino.dart';

class RankProvider with ChangeNotifier {
  List<RankTeam> _rankedTeams = [];
  int _round = 0;

  List<RankTeam> get rankedTeams => _rankedTeams;
  int get round => _round;

  void makeRankedTeams(List<Team> teams, int round) {
    _makeRankedTeams(teams);
    _round = round;
  }

  void _makeRankedTeams(List<Team> teams) {
    List<Team> sortedTeams = List.from(teams)
      ..sort((a, b) => b.point.compareTo(a.point));

    List<RankTeam> rankedTeams = [];
    int rank = 1;
    for (int i = 0; i < sortedTeams.length; i++) {
      if (i > 0 && sortedTeams[i].point < sortedTeams[i - 1].point) {
        rank = i + 1;
      }
      rankedTeams.add(RankTeam(team: sortedTeams[i], rank: rank));
    }

    _rankedTeams = rankedTeams;
  }
}
