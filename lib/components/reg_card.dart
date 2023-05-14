
import 'package:flutter/material.dart';

class RegCard extends StatelessWidget {
  final Widget title;
  final Widget child;

  const RegCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Column(
          children: [
            AppBar(
              title: title,
              elevation: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}