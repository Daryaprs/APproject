import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'User.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthService {
  final String host;
  final int port;
  AuthService({required this.host, required this.port});

  /// Sends login request and returns server response as String.
  /// Example responses: "login_success", "login_failed", "error"
  Future<String> login(User user, {Duration timeout = const Duration(seconds: 5)}) async {
    Socket? socket;
    try {
      // connect with timeout
      socket = await Socket.connect(host, port).timeout(timeout);

      Map<String, dynamic> payload = user.toJson();
      payload['type'] = 'login';
      String jsonData = jsonEncode(payload);

      // send and ensure newline so server's readLine() gets it
      socket.write(jsonData + '\n');

      // wait for single response (first chunk)
      // we convert first event to string
      final data = await socket.first.timeout(timeout);
      final response = utf8.decode(data).trim();
      return response;
    } on TimeoutException {
      return 'timeout';
    } catch (e) {
      debugPrint('AuthService login error: $e');
      return 'error';
    } finally {
      try { socket?.destroy(); } catch (_) {}
    }
  }

  Future<String> signup(User user, {Duration timeout = const Duration(seconds: 5)}) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port).timeout(timeout);

      Map<String, dynamic> payload = user.toJson();
      payload['type'] = 'signup';
      String jsonData = jsonEncode(payload);

      socket.write(jsonData + '\n');

      final data = await socket.first.timeout(timeout);
      final response = utf8.decode(data).trim();
      return response;
    } catch (e) {
      debugPrint('AuthService signup error: $e');
      return 'error';
    } finally {
      try { socket?.destroy(); } catch (_) {}
    }
  }

  Future<List<String>> fetchServerSongNames({Duration timeout = const Duration(seconds: 5)}) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port).timeout(timeout);
      final req = jsonEncode({"type": "get_music_list"});
      socket.write("$req\n");
      final data = await socket.first.timeout(timeout);
      final response = jsonDecode(utf8.decode(data));
      if (response["status"] == "ok") {
        final list = (response["music_list"] as List).map((e) => e as String).toList();
        return list;
      }
      return [];
    } finally {
      socket?.destroy();
    }
  }

  Future<String?> fetchSongBase64(String fileName, {Duration timeout = const Duration(seconds: 10)}) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port).timeout(timeout);
      final req = jsonEncode({"type": "get_music_file", "file_name": fileName});
      socket.write("$req\n");
      // final data = await socket.first.timeout(timeout);
      // final resp = utf8.decode(data);
      String response = '';
      await for(String chunk in socket.cast<List<int>>().transform(const Utf8Decoder())){
        response += chunk;
        if(response.contains('\n\n')){
          break;
        }
      }
      socket.close();
      if (response!=null && response.isNotEmpty) {
        response = response.trim();
        return response;
      }
      return null;
    } finally {
      socket?.destroy();
    }
  }

  static Future<void> saveLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // یا فقط کلیدهای لاگین رو پاک کن
  }

}
