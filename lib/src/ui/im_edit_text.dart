import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IMEditText extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? margin;
  final bool noBorder;
  final double borderRadius;
  final Color? backgroundColor;
  final int? maxLines;

  const IMEditText({
    Key? key,
    required this.controller,
    this.onChanged,
    this.labelText,
    this.inputFormatters,
    this.margin,
    this.noBorder = false,
    this.borderRadius = 20.0,
    this.hintText,
    this.backgroundColor,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor == null ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
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
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: Theme.of(context).textTheme.bodySmall,
          isDense: true,
          contentPadding:
              EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
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
