import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:ddw_duel/view/manage/match/match_view.dart';
import 'package:ddw_duel/view/manage/player/player_view.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final Event event;

  const ManagePage({super.key, required this.event});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  late Widget _selectedPage;

  void _updateBody(Widget newPage) {
    setState(() {
      _selectedPage = newPage;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedPage = const MatchView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(children: [
          Text(widget.event.name),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _updateBody(const MatchView());
                  },
                  child:
                      const Text("대진표", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    _updateBody(const PlayerView());
                  },
                  child:
                      const Text("참가자", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        ]),
      ),
      body: _selectedPage,
    );
  }
}
