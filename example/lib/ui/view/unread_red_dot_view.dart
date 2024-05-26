import 'package:flutter/material.dart';

class UnreadRedDotView extends StatelessWidget {
  const UnreadRedDotView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
