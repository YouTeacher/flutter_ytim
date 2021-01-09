import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class YTIMLocalizations {
  final Locale locale;

  YTIMLocalizations(this.locale);

  static const YTIMLocalizationsDelegate delegate = YTIMLocalizationsDelegate();

  static YTIMLocalizations of(BuildContext context) {
    return Localizations.of(context, YTIMLocalizations);
  }

  Map<String, YTIMString> values = {
    'en': EnYTIMString(),
    'zh': ZhYTIMString(),
    'ja': JaYTIMString(),
  };

  YTIMString get currentLocalization {
    if (values.containsKey(locale.languageCode)) {
      return values[locale.languageCode];
    }
    return values["en"];
  }
}

class YTIMLocalizationsDelegate
    extends LocalizationsDelegate<YTIMLocalizations> {
  const YTIMLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'zh',
      'ja',
    ].contains(locale.languageCode);
  }

  @override
  Future<YTIMLocalizations> load(Locale locale) {
    return SynchronousFuture<YTIMLocalizations>(YTIMLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<YTIMLocalizations> old) {
    return false;
  }
}

abstract class YTIMString {
  String ok;
  String cancel;
  String read;
  String unread;
  String alertRevokeMessage;
  String alertKickout;
}

class EnYTIMString extends YTIMString {
  String ok = 'OK';
  String cancel = 'CANCEL';
  String read = 'read';
  String unread = 'unread';
  String alertRevokeMessage = 'Confirm revoke this message.';
  String alertKickout = 'You are already logged in to another device.';
}

class ZhYTIMString extends YTIMString {
  String ok = '确定';
  String cancel = '取消';
  String read = '已读';
  String unread = '未读';
  String alertRevokeMessage = '确认撤回消息';
  String alertKickout = '您已在另一个设备登陆。';
}

class JaYTIMString extends YTIMString {
  String ok = '確定';
  String cancel = 'キャンセル';
  String read = '既読';
  String unread = '未読';
  String alertRevokeMessage = 'メッセージを削除';
  String alertKickout = 'すでに他の端末にログインしています';
}
