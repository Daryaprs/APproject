import 'package:flutter/material.dart';

class PlaylistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("پلی‌لیست"),
      ),
      body: Center(
        child: Text(
          "این‌جا صفحه پلی‌لیست است.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
