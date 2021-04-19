import 'package:music/constants.dart';
import 'package:music/page/home_page.dart';
import 'package:music/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music',
      debugShowCheckedModeBanner: false,
      theme: theme(),
      darkTheme: themeDark(),
      home: HomePage(

      ),
    );
  }
}
