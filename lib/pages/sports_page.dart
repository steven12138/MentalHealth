import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inner_peace/components/sport_data_card.dart';
import 'package:inner_peace/components/sports_card.dart';
import 'package:provider/provider.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SportSaveState>(
      create: (_) => SportSaveState(),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: ListView(
          children: const [
            SportsRecordCard(),
            SportDataCard(),
          ],
        ),
      ),
    );
  }
}
