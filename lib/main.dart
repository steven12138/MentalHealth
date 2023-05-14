import 'package:flutter/material.dart';
import 'package:inner_peace/pages/main_page.dart';

void main() {
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
          contentTextStyle: TextStyle(color: Colors.white), // Set the text color
        ),
      ),
      home: MainPage(),
    );
  }
}
