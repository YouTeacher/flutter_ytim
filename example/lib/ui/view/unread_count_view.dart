import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class UnreadCountView extends StatelessWidget {
  final int count;

  const UnreadCountView({super.key, this.count = 0});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: count == 0 ? 0 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minHeight: 16, minWidth: 16),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Center(
          child: Text(
            count > 999 ? '999' : count.toString(),
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
