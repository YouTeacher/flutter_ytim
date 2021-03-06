import 'package:flutter/material.dart';

/// 未读消息个数展示控件。
/// 个数为0时不显示。
class UnreadCountView extends StatelessWidget {
  final int count;

  const UnreadCountView({Key? key, this.count = 0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: count == 0 ? 0 : 1,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 20,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(3),
        child: Text(
          count.toString(),
          style: TextStyle(fontSize: 11, color: Colors.white),
        ),
        decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }
}
