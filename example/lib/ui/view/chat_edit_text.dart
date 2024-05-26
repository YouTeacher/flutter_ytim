import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMChatEditText extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onReturnOnTap;
  final String? labelText;

  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? margin;
  final bool noBorder;
  final double borderRadius;
  final Color? backgroundColor;
  final int? maxLines;

  const IMChatEditText({
    super.key,
    required this.controller,
    this.onChanged,
    this.onReturnOnTap,
    this.labelText,
    this.inputFormatters,
    this.margin,
    this.noBorder = false,
    this.borderRadius = 20.0,
    this.hintText,
    this.backgroundColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greyColor, width: 0.5),
        borderRadius: BorderRadius.circular(4.0),
        color: backgroundColor,
      ),
      margin: margin,
      child: TextField(
        autocorrect: false,
        style: Theme.of(context).textTheme.bodyMedium,
        inputFormatters: inputFormatters,
        keyboardType: TextInputType.multiline,
        maxLines: maxLines,
        cursorColor: Theme.of(context).primaryColor,
        controller: controller,
        textInputAction: TextInputAction.done, // 设置键盘右下角的文案为"完成"
        onEditingComplete: onReturnOnTap,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: Theme.of(context).textTheme.bodySmall,
          isDense: true,
          contentPadding:
              const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
                color: noBorder ? Colors.transparent : Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
                color: noBorder ? Colors.transparent : Colors.grey, width: 1),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class IMChatMicButton extends StatelessWidget {
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final EdgeInsetsGeometry? margin;
  final Color? bgColor;
  final Color? textColor;

  const IMChatMicButton(
      {super.key,
      required this.onTapDown,
      required this.onTapUp,
      this.margin,
      this.bgColor,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      child: ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return grey03Color; // 点击状态的按钮颜色
              }
              return grey03Color; // 默认状态的按钮颜色
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // 圆角
              // 边框颜色
            ),
          ),
          side: MaterialStateProperty.all<BorderSide>(
            const BorderSide(
              color: blackColor, // 边框颜色
              width: 1.0, // 边框宽度
            ),
          ),
          shadowColor: MaterialStateProperty.all(themeColor),
          elevation: MaterialStateProperty.all(0), // 阴影深度
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(2.0), // 内边距
          ),
        ),
        child: const Icon(Icons.mic, color: blackColor),
      ),
    );
  }
}
