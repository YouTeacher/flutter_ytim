import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class IMFieldTitleLabel extends StatelessWidget {
  final String? text;
  final Widget? trailing;
  final double? minHeight;
  final bool mandatory;

  const IMFieldTitleLabel({
    super.key,
    required this.text,
    this.trailing,
    this.minHeight,
    this.mandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, trailing == null ? 16 : 0, 0),
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 14.0, // 标题文本大小
                    fontWeight: FontWeight.bold, // 标题文本粗细
                  ),
                ),
                Offstage(
                  offstage: !mandatory,
                  child: Container(
                    alignment: Alignment.center,
                    // height: 15,
                    margin: const EdgeInsets.only(left: 10),
                    padding:
                    const EdgeInsets.only(left: 3, right: 3, bottom: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xffF12121), width: 1)),
                    child: Center(
                      child: Text(IMLocalizations.of(context).currentLocalization.must,
                          style: const TextStyle(
                              color: Color(0xffF12121),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ]),
          trailing == null
              ? Container()
              : Container(
            constraints: const BoxConstraints(minWidth: 58),
            child: Theme(
              data: ThemeData(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: trailing!,
            ),
          )
        ],
      ),
    );
  }
}
