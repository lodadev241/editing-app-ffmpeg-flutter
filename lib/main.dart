import 'package:editor_app/constants/constants.dart';
import 'package:editor_app/features/home/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    debugInvertOversizedImages = true;

    return MaterialApp(
      title: 'Editor App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: Constants.font,
      ),
      home: const HomeView(),
    );
  }
}
