
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class YTUtils {

  /// 隐藏键盘
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Pad 宽度
  static double iPadSize(BoxConstraints constraints) {
    if (constraints.maxWidth > 600) {
      return 600;
    }
    return constraints.maxWidth;
  }

  /// 显示提示框：内容+取消按钮+确定按钮，确定按钮需要点击事件。
  static showAlertDialogActionsHasTitle(BuildContext context, String content,
      {String? title,
        bool isHasTitle = false,
        String? okStr,
        Color? titleColor,
        String? cancelStr,
        Color? cancelColor,
        required VoidCallback okCallBack,
        VoidCallback? cancelCallBack}) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: isHasTitle
              ? SizedBox(
            width: 300,
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: titleColor ?? Colors.black, fontSize: 16),
            ),
          )
              : null,
          content: isHasTitle
              ? SizedBox(width: 300, child: Text(content))
              : SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          buttonPadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.all(0),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                  border:
                  Border(top: BorderSide(color: Colors.grey, width: .5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: TextButton(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(fontSize: 15)),
                          foregroundColor:
                          MaterialStateProperty.all(cancelColor ?? darkColor),
                        ),
                        child: Text(cancelStr ?? IMLocalizations.of(context).currentLocalization.cancel),
                        onPressed: () {
                          if (cancelCallBack != null) {
                            cancelCallBack();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      )),
                  const SizedBox(
                    width: .5,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 15)),
                        foregroundColor: MaterialStateProperty.all(
                            titleColor ?? Colors.blue),
                      ),
                      onPressed: okCallBack,
                      child: Text(okStr ?? IMLocalizations.of(context).currentLocalization.ok),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  /// 显示提示框：widget+取消按钮+确定按钮，确定按钮需要点击事件。
  static Future<bool?> showIMAlertWidget(BuildContext context, File imageFile,
      {String? cancelStr,
        String? okStr,
        Color? okColor,
        required VoidCallback okCallBack}) async {
    return await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            margin: const EdgeInsets.only(top: 10, right: 0),
            child: Image.file(imageFile),
          ),
          buttonPadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.all(0),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                  border:
                  Border(top: BorderSide(color: Colors.grey, width: .5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 15)),
                        foregroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      child: Text(
                        cancelStr ?? IMLocalizations.of(context).currentLocalization.cancel,
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(
                    width: .5,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                      child: TextButton(
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 15)),
                            foregroundColor: MaterialStateProperty.all(
                                okColor ?? Colors.blue),
                          ),
                          onPressed: okCallBack,
                          child: Text(okStr ?? IMLocalizations.of(context).currentLocalization.ok))),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  //读取文件地址里的 文件名称
  static String extractFileName(String filePath) {
    List<String> pathSegments = filePath.split(Platform.pathSeparator);
    String fileName = pathSegments.last;
    return fileName;
  }

  /// 限制组件在大屏下的显示宽度。
  static Widget generateWidgetOfWideScreen(Widget child) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return Center(
              child: SizedBox(
                width: 600,
                child: child,
              ),
            );
          } else {
            return child;
          }
        });
  }

  /// 将时间戳转换为本地格式化时间：1586182731897 -> 2020-04-07 11:35
  static String millisecondsToString(String? milliseconds) {
    if (milliseconds == null || milliseconds == '') {
      return '';
    }
    String dateOriginal =
    DateTime.fromMillisecondsSinceEpoch(int.parse(milliseconds))
        .toLocal()
        .toString();
    var today = DateTime.now();
    var standardDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    //传入的日期与今天的23:59:59秒进行比较
    Duration diff = standardDate.difference(DateTime.parse(dateOriginal));
    if (diff < const Duration(days: 1)) {
      return dateOriginal.substring(11, 16);
    } else {
      if (diff >= const Duration(days: 1) &&
          today.year.toString() == dateOriginal.substring(0, 4)) {
        return dateOriginal.substring(5, 10);
      } else {
        // 2019.01.23
        return dateOriginal.substring(0, 10);
      }
    }
  }
}