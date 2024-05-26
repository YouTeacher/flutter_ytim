import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';

/// 全局IM信息
class IMLastInfo {
  IMBaseMessage? msg;
  int unreadCount;

  IMLastInfo({this.msg, this.unreadCount = 0});
}

/// 全局IM信息，支持刷新
class IMStore with ChangeNotifier {
  Map<String?, IMLastInfo> _lastInfo;
  Map<String?, IMLastInfo> _groupLastInfo;
  Map<String?, IMLastInfo> _customServiceLastInfo;

  List<IMUser> _firends;
  List<IMChatModel> _chats;
  List<IMSysMessage> _sysMessages;
  List<IMGroup> _groups;

  IMStore(this._lastInfo, this._groupLastInfo, this._customServiceLastInfo,
      this._firends, this._chats, this._groups, this._sysMessages);

  List<IMUser> get firends => _firends;

  List<IMChatModel> get chats => _chats;

  List<IMSysMessage> get sysMessages => _sysMessages;

  List<IMGroup> get groups => _groups;

  void updateLastInfo(ChatType chatType, Map<String?, IMLastInfo> map) {
    switch (chatType) {
      case ChatType.user:
        _lastInfo = map;
        break;
      case ChatType.groups:
        _groupLastInfo = map;
        break;
      case ChatType.store:
        _customServiceLastInfo = map;
        break;
    }
    notifyListeners();
  }

  Map<String?, IMLastInfo> getLastInfo(ChatType chatType) {
    switch (chatType) {
      case ChatType.user:
        return _lastInfo;
      case ChatType.groups:
        return _groupLastInfo;
      case ChatType.store:
        return _customServiceLastInfo;
    }
  }

  void updateFirends(List<IMUser> value) {
    _firends = value;
    notifyListeners();
  }

  void updateChats(List<IMChatModel> value) {
    _chats = value;
    notifyListeners();
  }

  void updateSysMessages(List<IMSysMessage> value) {
    _sysMessages = value;
    notifyListeners();
  }

  void updateGroups(List<IMGroup> value) {
    _groups = value;
    notifyListeners();
  }

  void updateCleanData() {
    _lastInfo = {};
    _customServiceLastInfo = {};
    _groupLastInfo = {};
    _firends = [];
    _chats = [];
    _sysMessages = [];
    _groups = [];
    notifyListeners();
  }
}
