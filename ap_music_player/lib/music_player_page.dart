import 'dart:io';

import 'package:ap_music_player/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<String> songList;   // لیست آهنگ‌ها
  final int initialIndex;
  final AuthService authService;
  //final String songPath;

  const MusicPlayerPage({
    super.key,
    required this.songList,
    required this.initialIndex,
    required this.authService,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;
  late AnimationController _rotationController;
  late int currentIndex;


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    currentIndex = widget.initialIndex;

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotationController.repeat();
    _rotationController.stop();

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

    _audioPlayer.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _duration = d);
      }
    });


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

  Future<void> _playMusic(String songName) async {
    await _audioPlayer.stop();

    String? base64 = await widget.authService.fetchSongBase64(songName);
    if (base64 != null) {
      String cleanedBase64 = base64.replaceAll(RegExp(r'\s+'), '');
      Uint8List audioBytes = base64Decode(cleanedBase64);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$songName.mp3');
      await file.writeAsBytes(audioBytes, flush: true);

      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();
    }
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.audioSource == null) {
        await _playMusic(widget.songList[currentIndex]);
      } else {
        await _audioPlayer.play();
      }
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.songList[currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                    image: AssetImage("assets/CDImage.png"),
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
                      Text(_formatDuration(_position),
                          style: const TextStyle(color: Colors.white)),
                      Text(_formatDuration(_duration),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),

            // دکمه‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon:
                  Icon(Icons.skip_previous, color: Colors.white, size: 40),
                  onPressed: () {
                    if (currentIndex > 0) {
                      setState(() => currentIndex--);
                      _playMusic(widget.songList[currentIndex]);
                    }
                  },
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 70,
                  ),
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
                  onPressed: () {
                    if (currentIndex < widget.songList.length - 1) {
                      setState(() => currentIndex++);
                      _playMusic(widget.songList[currentIndex]);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}