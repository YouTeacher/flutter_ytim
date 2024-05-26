import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> play(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void onPlayerCompletion(VoidCallback onCompletion) {
    _audioPlayer.onPlayerComplete.listen((event) {
      onCompletion();
    });
  }
}
