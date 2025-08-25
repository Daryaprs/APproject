import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final loggedInUser = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? "";
  runApp(MyApp(isLoggedIn: loggedInUser, Username: username));
}



class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String Username;
  final authService = AuthService(host: '192.168.1.36', port: 3000);
  MyApp({Key? key, required this.isLoggedIn, required this.Username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => LoginPage(authService: authService),
        '/signup': (context) => SignupPage(authService: authService),
        '/home': (context) => HomePage(authService: authService, username: Username),
      },
    );
  }
}
