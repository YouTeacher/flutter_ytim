import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/ui/view/wechat_voice_screen.dart';
import 'package:flutter_ytim_example/utils/im_audio_player_service.dart';

class VoiceMessageCell extends StatefulWidget {
  final String audioUrl;

  const VoiceMessageCell({super.key, required this.audioUrl});

  @override
  State<VoiceMessageCell> createState() => _VoiceMessageCellState();
}

class _VoiceMessageCellState extends State<VoiceMessageCell> {
  bool isStop = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _duration = 0;

  Future<void> getAudioDuration(String url) async {
    await _audioPlayer.setSourceUrl(url);
    Duration? duration = await _audioPlayer.getDuration();
    if (mounted) {
      setState(() {
        _duration = duration?.inSeconds ?? 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AudioPlayerService().onPlayerCompletion(() {
      if (mounted) {
        setState(() {
          isStop = true;
        });
      }
    });
    getAudioDuration(widget.audioUrl);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _togglePlayback();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isStop ? _buildDurationText() : _buildPlayingAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingAnimation() {
    return const VoiceAnimation();
  }

  Widget _buildDurationText() {
    return Row(
      children: [
        const Icon(Icons.volume_up, color: Colors.white),
        const SizedBox(width: 4.0),
        if (_duration != 0)
          Text(
            '$_duration 秒',
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }

  Future<void> _togglePlayback() async {
    if (isStop) {
      await AudioPlayerService().play(widget.audioUrl).then((value) {
        setState(() {
          isStop = true;
        });
      });

      setState(() {
        isStop = false;
      });
    } else {
      AudioPlayerService().stop();
      setState(() {
        isStop = true;
      });
    }
  }
}
