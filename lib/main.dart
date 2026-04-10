import 'package:flutter/material.dart';
import 'screens/showroom_screen.dart'; // Import your new screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vortex Motors',
      theme: ThemeData.dark(),
      home: const ShowroomScreen(), // Set the showroom as the starting page
    );
  }
}