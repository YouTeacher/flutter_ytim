import 'package:flutter/material.dart';

class VoiceAnimation extends StatefulWidget {
  const VoiceAnimation({super.key});

  @override
  State<VoiceAnimation> createState() => _VoiceAnimationState();
}

class _VoiceAnimationState extends State<VoiceAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = IntTween(begin: 0, end: 2).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          Image? image;
          if (_animation.value == 0) {
            image = Image.asset('assets/image/imIcons/im/left_voice_1.png',width: 25,height: 25,);
          } else if (_animation.value == 1) {
            image = Image.asset('assets/image/imIcons/im/left_voice_2.png',width: 25,height: 25,);
          } else if (_animation.value == 2) {
            image = Image.asset('assets/image/imIcons/im/left_voice_3.png',width: 25,height: 25,);
          }
          return Container(
            child: image,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
