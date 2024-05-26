import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

///通用的按钮
///设置背景 边框、颜色 字体等
///默认背景white 边框文字颜色themeColor
///默认圆角5
class GenButton extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final Color? textColor;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? bgColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? widget;
  final VoidCallback? onBackPressed;
  final FontWeight? fontWeight;

  const GenButton({
    super.key,
    this.text,
    this.fontSize,
    this.textColor,
    this.width,
    this.height,
    this.borderColor,
    this.bgColor,
    this.borderRadius,
    this.onBackPressed,
    this.margin,
    this.widget,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width ?? ((MediaQuery.of(context).size.width > 600) ? 600 : MediaQuery.of(context).size.width),
      height: height ?? 50,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all<Color>(bgColor ?? Colors.white),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: borderColor ?? themeColor),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 5),
            ),
          ),
          //添加padding ，不限制vertical的高度
          padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(vertical: 0)),
        ),
        onPressed: onBackPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget ?? const SizedBox(),
            Text(
              textAlign: TextAlign.center,
              text ?? '',
              style: TextStyle(
                color: textColor ?? themeColor,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
