import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/model/game_model.dart';

class RoundModel {
  final Map<int, EntryModel> entryMap;
  final List<GameModel> gameModels;

  RoundModel({required this.gameModels, required this.entryMap});
}
