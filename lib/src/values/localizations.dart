import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 国际化，支持 英文、中文、日文。
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
      return values[locale.languageCode]!;
    }
    return values["en"]!;
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
  late String ok;
  late String cancel;
  late String read;
  late String unread;
  late String alertRevokeMessage;
  late String alertKickout;
  late String muteConversation;
  late String deleteConversation;
}

class EnYTIMString extends YTIMString {
  String ok = 'OK';
  String cancel = 'CANCEL';
  String read = 'read';
  String unread = 'unread';
  String alertRevokeMessage = 'Confirm revoke this message.';
  String alertKickout = 'You are already logged in to another device.';
  String muteConversation = 'Mute notification for this conversation';
  String deleteConversation = 'Are you sure you want to permanently delete this conversation?';
}

class ZhYTIMString extends YTIMString {
  String ok = '确定';
  String cancel = '取消';
  String read = '已读';
  String unread = '未读';
  String alertRevokeMessage = '确认撤回消息';
  String alertKickout = '您已在另一个设备登陆。';
  String muteConversation = '关闭这个对话的通知';
  String deleteConversation = '确定要永久删除这个对话？';
}

class JaYTIMString extends YTIMString {
  String ok = '確定';
  String cancel = 'キャンセル';
  String read = '既読';
  String unread = '未読';
  String alertRevokeMessage = 'メッセージを削除';
  String alertKickout = 'すでに他の端末にログインしています';
  String muteConversation = 'この会話のミュート通知';
  String deleteConversation = 'この会話を完全に削除してもよろしいですか？';
}
