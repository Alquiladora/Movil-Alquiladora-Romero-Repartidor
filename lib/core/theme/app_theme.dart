// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';


final ThemeData appTheme = ThemeData(

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 247, 188, 60), 
  ),
  

  fontFamily: 'Montserrat', 
  
 
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Montserrat', 
      fontWeight: FontWeight.bold, 
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Montserrat', 
      fontWeight: FontWeight.normal,
    ),
  ),

  useMaterial3: true,
);