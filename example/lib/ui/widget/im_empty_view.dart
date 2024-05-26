import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class IMEmptyView extends StatelessWidget {
  final String? content;
  const IMEmptyView({this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Center(
        child: Text(content ?? IMLocalizations.of(context).currentLocalization.noData),
      ),
    );
  }
}