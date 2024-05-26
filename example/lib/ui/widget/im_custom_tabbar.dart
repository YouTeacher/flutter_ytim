import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMCustomTabBar extends StatelessWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final TabBarIndicatorSize? indicatorSize;
  const IMCustomTabBar(
      {super.key, this.controller, required this.tabs, this.indicatorSize});

  @override
  Widget build(BuildContext context) {
    bool isScrollable = indicatorSize == TabBarIndicatorSize.label;
    return TabBar(
      labelPadding: isScrollable ? null : EdgeInsets.zero,
      controller: controller,
      labelColor: themeColor,
      labelStyle:
      const TextStyle(color: themeColor, fontWeight: FontWeight.bold),
      indicatorColor: themeColor,
      indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
      unselectedLabelColor: grey01Color,
      tabs: tabs,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? TabAlignment.start : null,
    );
  }
}