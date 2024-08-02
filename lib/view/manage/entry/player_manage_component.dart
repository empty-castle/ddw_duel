import 'package:ddw_duel/base/player_helper.dart';
import 'package:ddw_duel/base/snackbar_helper.dart';
import 'package:ddw_duel/db/domain/player.dart';
import 'package:ddw_duel/db/model/entry_model.dart';
import 'package:ddw_duel/db/repository/entry_repository_custom.dart';
import 'package:ddw_duel/db/repository/player_repository.dart';
import 'package:ddw_duel/provider/entry_provider.dart';
import 'package:ddw_duel/provider/selected_entry_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/manage/entry/player_form_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerManageComponent extends StatefulWidget {
  const PlayerManageComponent({super.key});

  @override
  State<PlayerManageComponent> createState() => _PlayerManageComponentState();
}

class _PlayerManageComponentState extends State<PlayerManageComponent> {
  final EntryRepositoryCustom entryRepositoryCustom = EntryRepositoryCustom();
  final PlayerRepository playerRepo = PlayerRepository();

  final _playerAFormKey = GlobalKey<FormState>();
  final TextEditingController _playerANameController = TextEditingController();

  final _playerBFormKey = GlobalKey<FormState>();
  final TextEditingController _playerBNameController = TextEditingController();

  void _onPressed() async {
    await _savePlayer(_playerAFormKey, _playerANameController, 1);
    await _savePlayer(_playerBFormKey, _playerBNameController, 2);
    await _afterSavePlayer();
  }

  Future<void> _savePlayer(GlobalKey<FormState> formKey,
      TextEditingController nameController, int position) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      EntryModel entryModel =
          Provider.of<SelectedEntryProvider>(context, listen: false)
              .selectedEntryModel!;

      Player? player =
          PlayerHelper.getPlayerByPosition(entryModel.players, position);
      if (player == null) {
        Player player = Player(
          name: nameController.text,
          teamId: entryModel.team.teamId!,
          position: position,
        );
        await playerRepo.savePlayer(player);
      } else {
        player.name = nameController.text;
        await playerRepo.savePlayer(player);
      }
    }
  }

  Future<void> _afterSavePlayer() async {
    int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .eventId!;
    await Provider.of<EntryProvider>(context, listen: false)
        .fetchEntries(eventId);

    if (!mounted) return;
    int teamId = Provider.of<SelectedEntryProvider>(context, listen: false)
        .selectedEntryModel!
        .team
        .teamId!;
    EntryModel? entryModel = await entryRepositoryCustom.findEntry(teamId);

    if (!mounted) return;
    Provider.of<SelectedEntryProvider>(context, listen: false)
        .setSelectedEntry(entryModel!);

    SnackbarHelper.showInfoSnackbar(context,
        "${_playerANameController.text}, ${_playerBNameController.text} 선수 저장이 완료되었습니다.");

    _playerAFormKey.currentState!.reset();
    _playerBFormKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectedEntryProvider>(
      builder: (context, provider, child) {
        if (provider.selectedEntryModel == null) {
          return const Center(
              child: Center(
            child: Text('팀을 선택해주세요.'),
          ));
        }
        List<Player> players = provider.selectedEntryModel!.players;
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '포지션 A',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      PlayerFormComponent(
                        position: 1,
                        playerNameController: _playerANameController,
                        formKey: _playerAFormKey,
                        player: PlayerHelper.getPlayerByPosition(players, 1),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '포지션 B',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      PlayerFormComponent(
                        position: 2,
                        playerNameController: _playerBNameController,
                        formKey: _playerBFormKey,
                        player: PlayerHelper.getPlayerByPosition(players, 2),
                      )
                    ],
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _onPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 150.0),
                    ),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
