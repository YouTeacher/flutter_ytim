import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 国际化，支持 中文、日文。
class IMLocalizations {
  final Locale locale;

  IMLocalizations(this.locale);

  static const IMLocalizationsDelegate delegate = IMLocalizationsDelegate();

  static IMLocalizations of(BuildContext context) {
    return Localizations.of(context, IMLocalizations);
  }

  Map<String, IMString> values = {
    'zh': ZhIMString(),
    'ja': JaIMString(),
  };

  IMString get currentLocalization {
    if (values.containsKey(locale.languageCode)) {
      return values[locale.languageCode]!;
    }
    return values["zh"]!;
  }
}

class IMLocalizationsDelegate extends LocalizationsDelegate<IMLocalizations> {
  const IMLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'zh',
      'ja',
    ].contains(locale.languageCode);
  }

  @override
  Future<IMLocalizations> load(Locale locale) {
    return SynchronousFuture<IMLocalizations>(IMLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<IMLocalizations> old) {
    return false;
  }
}

abstract class IMString {
  String get ok;
  String get cancel;
  String get read;
  String get unread;
  String get alertRevokeMessage;
  String get alertKickout;
  String get muteConversation;
  String get deleteConversation;
  String get block;
  String get deleteFirend;
  String get messageRescinded;
  String get imMsgTypeImg;
  String get imMsgTypeAudio;
  String get imMsgTypeVideo;
  String get imMsgTypeFile;
  String get imMsgTypeLocation;
  String get imMessageIgnore;
  String get imgSaveSuccessTip;
  String get imSendTo;
  String get send;
  String get imRead;
  String get imUnread;
  String get must;
  String get addressSearch;
  String get imSearchPlh;
  String get customerAddress;
  String get imGroupFirendHaveApplied;
  String get imGroupAddFriendBtn;
  String get imAddGroup;
  String get addFriend;
  String get noData;
  String get imAddFirendReqErrorTip;
  String get addGroup;
  String get imAddGroupReqErrorTip ;
  String get friend ;
  String get imTabGroupsTitle;
  String get detail ;
  String get notes;
  String get settings;
  String get remove;
  String get imRevokeMessage ;
  String get friendList;
  String get addGroupTitle;
  String get groupDesTitle;
  String get groupNamePlh;
  String get groupNameTitel;
  String get groupDesPlh ;
  String get groupUsers ;
  String get groupHeaderImg;
  String get completionReservation;
  String get cancelBtn;
  String get uploadCredentialsActionPicture;
  String get uploadCredentialsActionAlbum;
  String get uploadCredentialsAlertTitle;
  String get imAddGroupNameNilTip;
  String get imAddGroupDesNilTip;
  String get imAddGroupAvatarNilTip;
  String get memberInvitation;
  String get deleteGroupConfirm;
  String get exitGroupConfirm;
  String get imGroupDisbandBtn;
  String get imGroupExitBtn;
  String get imSysNotificationsTitle;
  String get imFriendRemarksName;
  String get imFriendRemarksNamePlh;
  String get imAddFriendReqError;
  String get imRejectAddFriendBtn;
  String get imRejectAddFriendReqError;
  String get imAddGroupBtn;
  String get imAddGroupReqError;
  String get imRejectAddGroupBtn;
  String get imRejectAddGroupReqError;
  String get inputNote;
  String get save;
  String get friendManager;
  String get editGroupTitle;
  String get tabMessage;
  String get imTabUserTitle;
  String get imTabNotice;
  String get imTabAddressBook;
}

class ZhIMString extends IMString {
  @override
  String ok = '确定';
  @override
  String cancel = '取消';
  @override
  String read = '已读';
  @override
  String unread = '未读';
  @override
  String alertRevokeMessage = '确认撤回消息';
  @override
  String alertKickout = '您已在另一个设备登陆。';
  @override
  String muteConversation = '关闭这个对话的通知';
  @override
  String deleteConversation = '确定要永久删除这个对话？';
  @override
  String block = '屏蔽对方消息';
  @override
  String deleteFirend = '确认删除好友吗？';
  @override
  String messageRescinded = '已撤回';
  @override
  String  imMsgTypeImg = "写真";
  @override
  String  imMsgTypeAudio = "音声";
  @override
  String  imMsgTypeVideo ="视频";
  @override
  String  imMsgTypeFile = "文件";
  @override
  String  imMsgTypeLocation = "位置";
  @override
  String imMessageIgnore = '忽略';
  @override
  String imgSaveSuccessTip = "图片已保存至相册";
  @override
  String imSendTo = "发给";
  @override
  String send ='发布';
  @override
  String imRead = "已读";
  @override
  String imUnread = "未读";
  @override
  String must = "必须";
  @override
  String addressSearch = "搜索";
  @override
  String imSearchPlh = "名前を検索";
  @override
  String customerAddress = "地址";
  @override
  String imGroupFirendHaveApplied = '已申请';
  @override
  String imGroupAddFriendBtn = "追加";
  @override
  String imAddGroup = '申请';
  @override
  String addFriend = '添加好友';
  @override
  String noData = "暂无数据";
  @override
  String imAddFirendReqErrorTip = "好友请求发出失败，请重试";
  @override
  String addGroup = '添加群组';
  @override
  String imAddGroupReqErrorTip = '申请入群失败';
  @override
  String friend = "好友";
  @override
  String imTabGroupsTitle = '群组';
  @override
  String detail = '詳細';
  @override
  String notes = "备注";
  @override
  String get settings => '设置';
  @override
  String get remove => "删除";
  @override
  String get imRevokeMessage => "撤回消息？";
  @override
  String get friendList => '好友列表';
  @override
  String get addGroupTitle => '创建群组';
  @override
  String get groupDesTitle => '群组描述';
  @override
  String get groupNamePlh => '请输入群组名称';
  @override
  String get groupNameTitel => '群组名称';
  @override
  String get groupDesPlh => '请输入群组描述';
  @override
  String get groupUsers => '群组成员';
  @override
  String get groupHeaderImg => '群组头像';
  @override
  String get completionReservation => "完成";
  @override
  String get cancelBtn => "取消";
  @override
  String get uploadCredentialsActionPicture => "拍照片";
  @override
  String get uploadCredentialsActionAlbum => "从库中选择";
  @override
  String get uploadCredentialsAlertTitle => "选择上传方法";
  @override
  String get imAddGroupNameNilTip => "请输入群组名称";
  @override
  String get imAddGroupDesNilTip => "请输入群组描述";
  @override
  String get imAddGroupAvatarNilTip => "请选择群组头像";
  @override
  String get memberInvitation => '成员邀请';
  @override
  String get deleteGroupConfirm => '确定解散群吗？';
  @override
  String get exitGroupConfirm => '确定退出群吗？';
  @override
  String get imGroupDisbandBtn => '解散群组';
  @override
  String get imGroupExitBtn => '退出群组';
  @override
  String get imSysNotificationsTitle => "通知";
  @override
  String get imFriendRemarksName => "备注名称";
  @override
  String get imFriendRemarksNamePlh => "请输入备注名称";
  @override
  String get imAddFriendReqError => '添加失败请重试';
  @override
  String get imRejectAddFriendBtn => '拒绝好友请求';
  @override
  String get imRejectAddFriendReqError => '拒绝失败请重试';
  @override
  String get imAddGroupBtn => '同意入群';
  @override
  String get imAddGroupReqError => '入群失败请重试';
  @override
  String get imRejectAddGroupBtn => '拒绝入群';
  @override
  String get imRejectAddGroupReqError => '拒绝失败请重试';
  @override
  String get inputNote => '请输入备注';
  @override
  String get save => '保存';
  @override
  String get friendManager => '好友管理';
  @override
  String get editGroupTitle => '群组编辑';
  @override
  String get tabMessage => "消息";
  @override
  String get imTabUserTitle => '聊天';
  @override
  String get imTabNotice => '通知';
  @override
  String get imTabAddressBook => '通讯录';
}

class JaIMString extends IMString {
  @override
  String ok = '確定';
  @override
  String cancel = 'キャンセル';
  @override
  String read = '既読';
  @override
  String unread = '未読';
  @override
  String alertRevokeMessage = 'メッセージを削除';
  @override
  String alertKickout = 'すでに他の端末にログインしています';
  @override
  String muteConversation = 'このメッセージを無視する';
  @override
  String deleteConversation = 'このメッセージを削除しても宜しいですか';
  @override
  String block = 'この方をブロックする';
  @override
  String deleteFirend = '好友を削除しますか？';
  @override
  String messageRescinded = '撤回されました';
  @override
  String imMsgTypeImg = "写真";
  @override
  String imMsgTypeAudio = "音声";
  @override
  String imMsgTypeVideo = "ビデオ";
  @override
  String imMsgTypeFile = "ファイル";
  @override
  String imMsgTypeLocation = "位置";
  @override
  String imMessageIgnore = '無視する';
  @override
  String imgSaveSuccessTip = "画像をアルバムに保存しました";
  @override
  String imSendTo = "to:";
  @override
  String send = '送信';
  @override
  String imRead = "既読";
  @override
  String imUnread = "未読";
  @override
  String must = "必須";
  @override
  String addressSearch = "検索";
  @override
  String imSearchPlh = "名前を検索";
  @override
  String customerAddress = "住所";
  @override
  String imGroupFirendHaveApplied = '申請済み';
  @override
  String imGroupAddFriendBtn = "追加";
  @override
  String imAddGroup = '申請';
  @override
  String addFriend = '友達追加';
  @override
  String noData = "データがありません";
  @override
  String imAddFirendReqErrorTip = "友達申請の送信が失敗、再試行してください";
  @override
  String addGroup = 'グループ追加';
  @override
  String imAddGroupReqErrorTip = 'グループ申請が失敗しました';
  @override
  String friend = "友達";
  @override
  String imTabGroupsTitle = 'グループ';
  @override
  String detail = '詳細';
  @override
  String get notes => "備考";
  @override
  String get settings => '設定';
  @override
  String get remove => "削除";
  @override
  String get imRevokeMessage => "メッセージを撤回しますか？";
  @override
  String get friendList => '友達リスト';
  @override
  String get addGroupTitle => 'グループ作成';
  @override
  String get groupDesTitle => 'グループルール';
  @override
  String get groupNamePlh => 'グループ名を入力';
  @override
  String get groupNameTitel => 'グループ名';
  @override
  String get groupDesPlh => 'グループルールを入力';
  @override
  String get groupUsers => 'グループメンバー';
  @override
  String get groupHeaderImg => 'グループアバター';
  @override
  String get completionReservation => "完成";
  @override
  String get cancelBtn => "キャンセル";
  @override
  String get uploadCredentialsActionPicture => "写真を撮る";
  @override
  String get uploadCredentialsActionAlbum => "ライブラリから選ぶ";
  @override
  String get uploadCredentialsAlertTitle => "アップロード方法を選択";
  @override
  String get imAddGroupNameNilTip => "グループ名を入力してください";
  @override
  String get imAddGroupDesNilTip => "グループルールを入力してください";
  @override
  String get imAddGroupAvatarNilTip => "グループアバターをアップロードしてください";
  @override
  String get memberInvitation => 'メンバー招待';
  @override
  String get deleteGroupConfirm => 'グループを解散しますか？';
  @override
  String get exitGroupConfirm => 'グループを終了しますか？';
  @override
  String get imGroupDisbandBtn => '解散';
  @override
  String get imGroupExitBtn => '退会';
  @override
  String get imSysNotificationsTitle => "通知";
  @override
  String get imFriendRemarksName => "備考";
  @override
  String get imFriendRemarksNamePlh => "備考を入力してください";
  @override
  String get imAddFriendReqError => '追加に失敗しました、もう一度お試しください';
  @override
  String get imRejectAddFriendBtn => '友達申請を拒否';
  @override
  String get imRejectAddFriendReqError => '拒否に失敗しました、再度試してください';
  @override
  String get imAddGroupBtn => 'グループに参加';
  @override
  String get imAddGroupReqError => 'グループ入りに失敗しました、再試行してください';
  @override
  String get imRejectAddGroupBtn => 'グループに参加しない';
  @override
  String get imRejectAddGroupReqError => '拒否に失敗しました、もう一度お試しください';
  @override
  String get inputNote => 'コメントを入力してください';
  @override
  String get save => '保存';
  @override
  String get friendManager => '友達管理';
  @override
  String get editGroupTitle => 'グループ編集';
  @override
  String get tabMessage => "チャット";
  @override
  String get imTabUserTitle => 'トーク';
  @override
  String get imTabNotice => '通知';
  @override
  String get imTabAddressBook => '連絡先';
}
