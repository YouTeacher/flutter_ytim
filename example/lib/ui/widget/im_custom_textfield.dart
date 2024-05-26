import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ytim_example/ui/widget/im_field_lable.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';

class IMCustomTextField extends StatelessWidget {
  final String labelText;
  final String? placeholderText;
  final TextEditingController? textController;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int maxLines;
  final int minLines;
  final double? sizedBoxHeight;
  final Widget? trailing;
  final bool showInputLayout;
  final bool obscureText;
  final EdgeInsetsGeometry? labelMargin;
  final TextInputAction? textInputAction;
  final InputDecoration? decoration;
  final void Function()? textFieldOnTap;
  final Color? dividerColor;
  final bool mandatory;
  final Widget? prefix;
  final Color? bgColor;
  final bool enabled;
  final bool hasTitleLabel;

  const IMCustomTextField({
    super.key,
    required this.labelText,
    this.placeholderText,
    this.textController,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.trailing,
    this.showInputLayout = true,
    this.obscureText = false,
    this.labelMargin,
    this.textInputAction,
    this.textFieldOnTap,
    this.dividerColor,
    this.decoration,
    this.mandatory = false,
    this.prefix,
    this.bgColor,
    this.enabled = true,
    this.sizedBoxHeight,
    this.hasTitleLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Offstage(
          offstage: !hasTitleLabel,
          child: IMFieldTitleLabel(
            text: labelText,
            mandatory: mandatory,
          ),
        ),
        SizedBox(height: sizedBoxHeight ?? 10.0), // 间隔
        Container(
          color: bgColor ?? backGroundColor,
          child: TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            controller: textController,
            enabled: enabled,
            autocorrect: false,
            obscureText: obscureText,
            cursorColor: themeColor,
            maxLines: maxLines,
            minLines: minLines,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: decoration ??
                InputDecoration(
                  filled: true, // 填充背景
                  fillColor: enabled ? Colors.white : backGroundColor,
                  prefixIcon: prefix,
                  prefixIconConstraints: const BoxConstraints(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: grey02Color),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: grey02Color),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: grey02Color),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),

                  hintText: placeholderText ?? labelText, // 提示文本
                ),
            onChanged: onChanged,
            onTap: textFieldOnTap,
          ),
        ),
      ],
    );
  }
}
