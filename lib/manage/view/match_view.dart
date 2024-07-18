import 'package:flutter/material.dart';

class MatchView extends StatefulWidget {
  const MatchView({super.key});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.green),
                  child: const Center(
                    child: Text("라운드 & 버튼"),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: const Center(
                      child: Text("대진표"),
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(color: Colors.red),
              child: const Center(
                child: Text("팀 순위"),
              ),
            ))
      ],
    );
  }
}
