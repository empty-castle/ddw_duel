import 'package:ddw_duel/provider/selected_event_provider.dart';
import 'package:ddw_duel/view/manage/entry/entry_view.dart';
import 'package:ddw_duel/view/manage/round/round_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

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
    _selectedPage = const RoundView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(children: [
          Consumer<SelectedEventProvider>(
            builder: (context, provider, child) {
              return Text(provider.selectedEvent!.name);
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _updateBody(const RoundView());
                  },
                  child:
                      const Text("대진표", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    _updateBody(const EntryView());
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
