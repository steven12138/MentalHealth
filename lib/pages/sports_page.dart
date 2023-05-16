import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inner_peace/components/sports_card.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SportsRecordCard(),
      ],
    );
  }
}
