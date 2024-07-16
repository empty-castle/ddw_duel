import 'package:ddw_duel/domain/event/domain/event.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final Event event;

  const ManagePage({super.key, required this.event});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {

  // Widget _selectedPage = const ManagePage(event: event);
  //
  // void _updateBody(Widget newPage) {
  //   setState(() {
  //     _selectedPage = newPage;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        centerTitle: true,
        title: Row(children: [
          Text(widget.event.name),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child:
                      const Text("대진표", style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {},
                  child:
                      const Text("참가자", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        ]),
      ),
      body: const Center(
        child: Text('Welcome to the New Page'),
      ),
    );
  }
}
