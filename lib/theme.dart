import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

ThemeData theme() {
  return ThemeData(
    primarySwatch: Colors.yellow,
    primaryColor: kPrimaryColor,
    accentColor: kAccentColor,
    appBarTheme: AppBarTheme(
      color: kPrimaryColor,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      textTheme:
      TextTheme(headline6: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w600)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: Colors.black,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: kPrimaryColor,
      backgroundColor: Colors.white
    ),
  );
}

ThemeData themeDark() {

  return ThemeData(
    brightness: Brightness.dark,
    accentColor: kAccentColor,
    appBarTheme: AppBarTheme(
      color: kPrimaryColor,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      textTheme:
      TextTheme(headline6: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w600)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white
    ),
    dividerColor: Colors.white,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: kPrimaryColor,
    ),
  );
}
