import 'package:ddw_duel/provider/entry_provider.dart';
import 'package:ddw_duel/provider/selected_entry_provider.dart';
import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/manage/entry/player_history_component.dart';
import 'package:ddw_duel/view/manage/entry/player_list_component.dart';
import 'package:ddw_duel/view/manage/entry/player_manage_component.dart';
import 'package:ddw_duel/view/manage/entry/team_list_component.dart';
import 'package:ddw_duel/view/manage/entry/team_mange_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntryView extends StatefulWidget {
  const EntryView({super.key});

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['매칭 히스토리', '팀 관리', '선수 관리'];
  late List<Widget> _tabViews;

  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    int eventId = Provider.of<SelectedEventProvider>(context, listen: false)
        .selectedEvent!
        .eventId!;
    initTab(eventId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _fetchData();
  }

  void initTab(int eventId) {
    _tabViews = [
      const PlayerHistoryComponent(),
      const TeamMangeComponent(),
      const PlayerManageComponent(),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await Provider.of<EntryProvider>(context, listen: false).fetchEntries(
        Provider.of<SelectedEventProvider>(context, listen: false).selectedEvent!.eventId!
    );
    if (mounted) {
      Provider.of<SelectedEntryProvider>(context, listen: false).resetSelectedEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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
      },
    );
  }
}
