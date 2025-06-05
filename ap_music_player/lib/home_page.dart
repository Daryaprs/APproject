import 'package:flutter/material.dart';

import 'login_page.dart';

class homePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: Text('بازگشت به صفحه ورود'),
      )
    )
      );
    throw UnimplementedError();
  }

}