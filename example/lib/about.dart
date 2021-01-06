import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人中心'),
      ),
      body: Container(
        margin: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '简介',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text('YouTeacher IM 示例代码。')
          ],
        ),
      ),
    );
  }
}
