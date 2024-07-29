import 'package:ddw_duel/db/domain/player.dart';
import 'package:flutter/material.dart';

class PlayerFormComponent extends StatefulWidget {
  final Player? player;
  final int position;
  final TextEditingController playerNameController;
  final GlobalKey<FormState> formKey;

  const PlayerFormComponent(
      {super.key,
      required this.position,
      required this.playerNameController,
      required this.formKey,
      required this.player});

  @override
  State<PlayerFormComponent> createState() => _PlayerFormComponentState();
}

class _PlayerFormComponentState extends State<PlayerFormComponent> {

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextFormField(
              controller: widget.playerNameController,
              decoration: const InputDecoration(
                labelText: '선수 이름',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '선수 이름을 입력해주세요.';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePlayerControllers();
  }

  @override
  void didUpdateWidget(PlayerFormComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePlayerControllers();
  }

  void _updatePlayerControllers() {
    if (widget.player != null) {
      widget.playerNameController.text = widget.player!.name;
    }
  }
}
