import 'package:ddw_duel/domain/team/repository/team_repository.dart';
import 'package:ddw_duel/provider/event_provider.dart';
import 'package:ddw_duel/provider/player_provider.dart';
import 'package:ddw_duel/view/manage/player/player_history_component.dart';
import 'package:ddw_duel/view/manage/player/player_list_component.dart';
import 'package:ddw_duel/view/manage/player/player_manage_component.dart';
import 'package:ddw_duel/view/manage/player/team_list_component.dart';
import 'package:ddw_duel/view/manage/player/team_mange_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView>
    with SingleTickerProviderStateMixin {
  final TeamRepository teamRepo = TeamRepository();

  late TabController _tabController;
  final List<String> _tabs = [ '매칭 히스토리', '팀 관리', '선수 관리'];
  late List<Widget> _tabViews;

  void initTab(int eventId) {
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabViews = [
      const PlayerHistoryComponent(),
      const TeamMangeComponent(),
      const PlayerManageComponent(),
    ];
  }

  @override
  void initState() {
    super.initState();
    int eventId = Provider.of<EventProvider>(context, listen: false).eventId!;
    initTab(eventId);
    Provider.of<PlayerProvider>(context, listen: false).clearPlayerProvider();
    Provider.of<PlayerProvider>(context, listen: false).fetchTeams(eventId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(color: Colors.white24, width: 1)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '팀 리스트',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        TeamListComponent()
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(color: Colors.white24, width: 1)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선수 리스트',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        PlayerListComponent()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: _tabs.map((tab) {
                  return Tab(text: tab);
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabViews,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
