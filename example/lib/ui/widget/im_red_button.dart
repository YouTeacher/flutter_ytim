import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMRedButton extends StatelessWidget {
  final String? content;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final Color? bgColor;
  final Color? textColor;

  const IMRedButton(
      {super.key,
        required this.content,
        required this.onPressed,
        this.margin,
        this.bgColor,
        this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return redButtonTapColor; // 点击状态的按钮颜色
            }
            return redButtonColor; // 默认状态的按钮颜色
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45.0), // 圆角
            // 边框颜色
          ),
        ),
        side: MaterialStateProperty.all<BorderSide>(
          const BorderSide(
            color: themeColor, // 边框颜色
            width: 1.0, // 边框宽度
          ),
        ),
        shadowColor: MaterialStateProperty.all(themeColor),
        elevation: MaterialStateProperty.all(0), // 阴影深度
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.all(13.0), // 内边距
        ),
      ),
      child: Text(
        content!,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
