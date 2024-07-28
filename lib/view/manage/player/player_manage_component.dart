import 'package:ddw_duel/provider/player_provider.dart';
import 'package:ddw_duel/view/manage/player/player_form_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerManageComponent extends StatefulWidget {
  const PlayerManageComponent({super.key});

  @override
  State<PlayerManageComponent> createState() => _PlayerManageComponentState();
}

class _PlayerManageComponentState extends State<PlayerManageComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            Consumer<PlayerProvider>(builder: (context, playerProvider, child) {
          if (playerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white24, width: 1))),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '포지션 A',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    PlayerFormComponent(position: 0)
                  ],
                ),
              )),
              const SizedBox(
                height: 8,
              ),
              const Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '포지션 B',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  PlayerFormComponent(position: 1)
                ],
              )),
            ],
          );
        }));
  }
}
