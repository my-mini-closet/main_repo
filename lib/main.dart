import 'package:flutter/material.dart';
import 'screens/login_screen.dart' as login;
import 'screens/home_screen.dart' as home;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion App',
      initialRoute: '/',
      routes: {
        '/': (context) => login.LoginScreen(),
        '/home': (context) => home.HomeScreen(),
      },
    );
  }
}
