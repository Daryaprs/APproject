import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authService = AuthService(host: '192.168.1.33', port: 3000);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Signup Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(authService: authService),
        '/signup': (context) => SignupPage(authService: authService),
        '/home': (context) => HomePage(authService: authService,),
      },
    );
  }
}
