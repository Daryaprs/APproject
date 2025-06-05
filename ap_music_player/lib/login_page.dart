import 'package:flutter/material.dart';
import 'package:ap_music_player/home_page.dart';

import 'User.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Show dialog for now
      Navigator.pushReplacementNamed(context, '/home');
      User loginUser = new User(username: userNameController.text, password: passwordController.text);
      sendLoginData(loginUser);
      // showDialog(
      //   context: context,
      //   builder: (_) => AlertDialog(
      //     title: Text('Login Success'),
      //     content: Text('Welcome, ${emailController.text}!'),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Welcome Back!", style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 24),
              TextFormField(
                controller: userNameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your email or phone number' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your password' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: Text("Don't have an account? Sign up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
