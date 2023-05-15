import 'package:flutter/material.dart';
import 'package:inner_peace/components/todo_card.dart';
import 'package:inner_peace/components/trophy_card.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ListView(
        children: [
          const SizedBox(height: 10),
          TrophyCard(),
          const SizedBox(height: 20,),
          ToDoCard(),
        ],
      ),
    );
  }
}
