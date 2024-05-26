import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMCustomBottomNavigationBar extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const IMCustomBottomNavigationBar({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: grey02Color.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width >600 ? (MediaQuery.of(context).size.width - 600)/2 + 15 : 15,
            right: MediaQuery.of(context).size.width >600 ? (MediaQuery.of(context).size.width - 600)/2 + 15 : 15,
            top: 15,
            bottom: 15,
          ),
          height: 50,
          decoration: const BoxDecoration(
            color: themeColor,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}