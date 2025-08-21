import 'dart:io';

import 'package:ap_music_player/auth_service.dart';
import 'package:ap_music_player/music_player_manager.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class MusicPlayerPage extends StatefulWidget {
  final String songName;
  final AuthService authService;
  //final String songPath;

  const MusicPlayerPage({super.key, required this.songName, required this.authService});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotationController.repeat(); // سی‌دی همیشه بچرخه
    _rotationController.stop();// ولی اول متوقف باشه

    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      final completed = state.processingState == ProcessingState.completed;

      if (completed) {
        _rotationController.stop();
        _rotationController.reset();
        if (mounted) {
          setState(() => isPlaying = false);
        }
      } else if (playing) {
        _rotationController.repeat();
        if (mounted) {
          setState(() => isPlaying = true);
        }
      } else {
        _rotationController.stop();
        if (mounted) {
          setState(() => isPlaying = false);
        }
      }
    });
    /// گرفتن مدت آهنگ
    _audioPlayer.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _duration = d);
      }
    });

    /// گرفتن موقعیت فعلی آهنگ
    _audioPlayer.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if(_audioPlayer.audioSource == null) {
        String? base64 = await widget.authService.fetchSongBase64(
            widget.songName);
        if (base64 != null) {
          String cleanedBase64 = base64.replaceAll(RegExp(r'\s+'), '');
          Uint8List audioBytes = base64Decode(cleanedBase64);

          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/${widget.songName}.mp3');
          await file.writeAsBytes(audioBytes, flush: true);

          await _audioPlayer.setFilePath(file.path);

        }
      }
      await _audioPlayer.play();
    }
  }
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // دارک مود
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.songName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // سی‌دی چرخان
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage("assets/CDImage.png"), // عکس سی‌دی (خودت بذار تو assets)
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            /// SeekBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      final newPos = Duration(seconds: value.toInt());
                      _audioPlayer.seek(newPos);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  )
                ],
              ),
            ),

            // دکمه Play / Pause
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
                  onPressed: () {},
                ),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 70,
                  ),
                  onPressed: _togglePlayPause,
                ),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
