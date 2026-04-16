import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/showroom_screen.dart';

final Color primaryNeon = const Color(0xFF00F5FF);
final Color midnightBg = const Color(0xFF0B0D0F); 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: midnightBg,
        primaryColor: primaryNeon,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ShowroomScreen(),
    );
  }
}
