import 'package:flutter/material.dart';

class MatchBracketComponent extends StatefulWidget {
  const MatchBracketComponent({super.key});

  @override
  State<MatchBracketComponent> createState() => _MatchBracketComponentState();
}

class _MatchBracketComponentState extends State<MatchBracketComponent> {
  final List<String> _scores = [
    '3:0',
    '2:1',
    '1:2',
    '0:3',
  ];

  String? _gameAScore;
  String? _gameBScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1)),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xFF8A61DB)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TeamA'),
                    Text(' vs '),
                    Text('TeamB'),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('A'),
                  gameAScoreDropDownButton(),
                  Text('A'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('B'),
                  gameBScoreDropDownButton(),
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

  Widget gameScoreDropDownButton(String? currentScore, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: DropdownButton(
        value: currentScore,
        items: _scores.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget gameAScoreDropDownButton() {
    return gameScoreDropDownButton(_gameAScore, (String? value) {
      setState(() {
        _gameAScore = value;
      });
    });
  }

  Widget gameBScoreDropDownButton() {
    return gameScoreDropDownButton(_gameBScore, (String? value) {
      setState(() {
        _gameBScore = value;
      });
    });
  }
}
