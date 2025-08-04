import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("اطلاعات کاربری"),
      ),
      body: Center(
        child: Text(
          "این‌جا صفحه اطلاعات کاربری است.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
