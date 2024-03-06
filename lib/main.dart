import 'package:flutter/material.dart';
import 'layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const LayoutPage(),
    );
  }
}
