import 'package:flutter/material.dart';

class MatchBracketComponent extends StatefulWidget {
  const MatchBracketComponent({super.key});

  @override
  State<MatchBracketComponent> createState() => _MatchBracketComponentState();
}

class _MatchBracketComponentState extends State<MatchBracketComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border:
              Border.all(color: Colors.white24, width: 1)),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.blueGrey),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TeamA'),
                    Text(' vs '),
                    Text('TeamB'),
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('A'),
                  Text(' 3:0 '),
                  Text('A'),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('B'),
                  Text(' 0:3 '),
                  Text('B'),
                ],
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
