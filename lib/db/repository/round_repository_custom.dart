import 'package:ddw_duel/db/domain/duel.dart';
import 'package:ddw_duel/db/domain/game.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';
import 'package:ddw_duel/db/model/round_model.dart';
import 'package:ddw_duel/db/repository/duel_repository.dart';
import 'package:ddw_duel/db/repository/entry_repository_custom.dart';
import 'package:ddw_duel/db/repository/game_repository.dart';

class RoundRepositoryCustom {

  final EntryRepositoryCustom entryRepositoryCustom = EntryRepositoryCustom();
  final GameRepository gameRepo = GameRepository();
  final DuelRepository duelRepo = DuelRepository();

  Future<RoundModel> findRound(int eventId, int currentRound) async {
    Map<int, EntryModel> entryMap =
        await entryRepositoryCustom.findAllEntryMap(eventId);

    List<Game> games =
        await gameRepo.findCurrentRoundGames(eventId, currentRound);
    List<GameModel> gameModels = await _makeGameModels(games);

    return RoundModel(gameModels: gameModels, entryMap: entryMap);
  }

  Future<List<GameModel>> _makeGameModels(List<Game> games) async {
    List<GameModel> result = [];
    for (var game in games) {
      List<Duel> duels = await duelRepo.findDuels(game.gameId!);
      result.add(GameModel(duels: duels, game: game));
    }
    return result;
  }

  Future<Map<int, Set<int>>> findTeamMatchHistory(int eventId) async {
    List<Game> games = await gameRepo.findGames(eventId);
    Map<int, Set<int>> teamHistoryMap = {};

    for (Game game in games) {
      if (!teamHistoryMap.containsKey(game.team1Id)) {
        teamHistoryMap[game.team1Id] = {};
      }
      teamHistoryMap[game.team1Id]!.add(game.team2Id);

      if (!teamHistoryMap.containsKey(game.team2Id)) {
        teamHistoryMap[game.team2Id] = {};
      }
      teamHistoryMap[game.team2Id]!.add(game.team1Id);
    }

    return teamHistoryMap;
  }
}
