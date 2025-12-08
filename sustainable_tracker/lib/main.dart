import 'package:flutter/material.dart';
import 'package:sustainable_tracker/Views/Pages/Home.dart';
import 'package:sustainable_tracker/Views/Welcome_Pages/Welcome_Page1.dart';
import 'package:sustainable_tracker/Views/widgets/widget_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Welcome_Page1(),
    );
  }
}
