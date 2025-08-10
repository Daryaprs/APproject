import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'User.dart';



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
}
