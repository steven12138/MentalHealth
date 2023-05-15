import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:inner_peace/data/emotion.dart';
import 'package:inner_peace/data/emotion_dao.dart';
import 'package:inner_peace/pages/main_page.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康冥想',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.green, // Set the desired background color
          contentTextStyle:
              TextStyle(color: Colors.white), // Set the text color
        ),
      ),
      home: MainPage(),
    );
  }
}
