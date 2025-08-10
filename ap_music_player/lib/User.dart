import 'dart:io';
import 'dart:convert';

import 'package:ap_music_player/login_page.dart';

class User {
  String username;
  String password;

  User({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}


