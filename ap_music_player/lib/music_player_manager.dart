import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'auth_service.dart';

class MusicPlayerManager {
  static final MusicPlayerManager _instance = MusicPlayerManager._internal();
  factory MusicPlayerManager() => _instance;

  final AudioPlayer _player = AudioPlayer();
  String? currentSong;
  bool _isPlaying = false;

  final AuthService _authService = AuthService(host: '10.0.2.2', port: 3000);
  MusicPlayerManager._internal();

  Future<void> playFromServer(String fileName) async {
    try {
      currentSong = fileName;
      String? base64String = await _authService.fetchSongBase64(fileName);
      Uint8List bytes = base64Decode(base64String!);

      final dir = await getTemporaryDirectory();
      File tempFile = File('${dir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      await _player.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print("Error playing from server: $e");
    }
  }

  Future<void> playLocal(File file) async {
    try {
      await _player.play(DeviceFileSource(file.path));
      _isPlaying = true;
    } catch (e) {
      print("Error playing local: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
