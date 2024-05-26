import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMWhiteButton extends StatelessWidget {
  final String? content;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final Color? bgColor;
  final Color? textColor;
  final TextStyle? textStyle;

  const IMWhiteButton({
    super.key,
    required this.content,
    required this.onPressed,
    this.margin,
    this.bgColor,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return whiteButtonTapColor; // 点击状态的按钮颜色
            }
            return whiteButtonColor; // 默认状态的按钮颜色
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
          margin ??
              const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 10), // 内边距
        ),
      ),
      onPressed: onPressed,
      child: Text(
        content!,
        style: textStyle ?? const TextStyle(color: themeColor, fontSize: 16),
      ),
    );
  }
}