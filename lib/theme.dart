import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff0f1424),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18, color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 20, 19, 19),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(
          onPrimary: Color(0xff182039),
          primary: Color(0xff182039),
          secondary: Color(0xFF615DFC),
          onSecondary: Color(0xFF615DFC),
          surface: Color(0xff0f1424),
          onSurface: Color(0xff0f1424),
          error: Color(0xffFF5252),
          onError: Color(0xffFF5252),
          background: Color(0xff0f1424),
          onBackground: Color(0xff0f1424),
          seedColor: const Color.fromARGB(255, 13, 9, 9))
      .copyWith(brightness: Brightness.dark),
);
