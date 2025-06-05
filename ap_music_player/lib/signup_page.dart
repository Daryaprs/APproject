import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      // Simulate signup
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Signup Success'),
          content: Text('Account created for ${userNameController.text}!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Create Account", style: Theme.of(context).textTheme.headlineMedium),
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
                value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) =>
                value != passwordController.text ? 'Passwords do not match' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Already have an account? Log in"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
