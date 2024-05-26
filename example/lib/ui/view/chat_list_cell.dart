import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/view/unread_count_view.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

// 会话列表
class ChatListCell extends StatelessWidget {
  final IMChatModel? chatModle;
  final IMLastInfo? lastInfo;

  const ChatListCell(this.chatModle, {super.key, this.lastInfo});

  @override
  Widget build(BuildContext context) {
    String? id = chatModle?.chatType == ChatType.user ? chatModle?.userId : chatModle?.chatType == ChatType.groups ? chatModle?.groupId : chatModle?.storeId;
    final lastMsg = IMUtils.getLastInfo(context,chatModle!.chatType)[id]?.msg;
    return ChatCellItem(
      chatType: chatModle?.chatType,
      chatMessageType: lastMsg?.type,
      name: chatModle?.chatType == ChatType.user ? chatModle?.userInfo?.nickname : chatModle?.chatType == ChatType.groups ? chatModle?.gourp?.name ?? "" : chatModle?.store?.name ?? "",
      content: lastMsg?.content,
      lastTalkAt: chatModle?.lastTalkAt,
      unreadCount: lastInfo?.unreadCount ?? 0,
      avatarUrl: chatModle?.chatType == ChatType.user ? chatModle?.userInfo?.avatar : chatModle?.chatType == ChatType.groups ? chatModle?.gourp?.avatar : chatModle?.store?.logo,
    );
  }
}

class ChatCellItem extends StatelessWidget {
  final ChatType? chatType;
  final String? chatMessageType;
  final String? name;
  final String? content;
  final String? lastTalkAt;
  final String? avatarUrl;
  final int? unreadCount;

  /// 头像点击事件
  final void Function(IMUser?)? onAvatarTap;

  /// 添加好友
  final void Function(IMUser?)? onAddFirendTap;

  const ChatCellItem({
    super.key,
    this.chatMessageType,
    this.chatType,
    this.name,
    this.content,
    this.lastTalkAt,
    this.avatarUrl,
    this.unreadCount,
    this.onAvatarTap,
    this.onAddFirendTap,
  });

  @override
  Widget build(BuildContext context) {
    String showStr = '';
    switch (chatMessageType) {
      case "1":
        showStr = content ?? "";
        break;
      case "2":
        showStr = content == IMLocalizations.of(context).currentLocalization.messageRescinded
            ? IMLocalizations.of(context).currentLocalization.messageRescinded
            : '[${IMLocalizations.of(context).currentLocalization.imMsgTypeImg}]';
        break;
      case "3":
        showStr = content == IMLocalizations.of(context).currentLocalization.messageRescinded
            ? IMLocalizations.of(context).currentLocalization.messageRescinded
            : '[${IMLocalizations.of(context).currentLocalization.imMsgTypeAudio}]';
        break;
      case "4":
        showStr = '[${IMLocalizations.of(context).currentLocalization.imMsgTypeVideo}]';
        break;
      case "5":
        showStr = '[${IMLocalizations.of(context).currentLocalization.imMsgTypeFile}]';
        break;
      case "6":
        showStr = '[${IMLocalizations.of(context).currentLocalization.imMsgTypeLocation}]';
        break;
      default:
    }
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context,
                color: sepColor.withOpacity(0.7))),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: IMCustomCircleAvatar(
              type: IMAvatarType.user,
              avatarUrl: avatarUrl ?? '',
              size: 40,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 名字
                Row(
                  children: [
                    Text(
                      name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 3),
                    _iconType(),
                  ],
                ),
                const SizedBox(height: 3),
                // 最后一条消息
                Text(
                  showStr,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 时间
              Text(YTUtils.millisecondsToString(lastTalkAt ?? ''),
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 3),
              // 未读个数
              UnreadCountView(count: unreadCount ?? 0),
            ],
          )
        ],
      ),
    );
  }

  _iconType() {
    String name = 'assets/svg/ic_chat.svg';
    Color color = const Color(0xff999999);
    if (chatType == ChatType.user) {
      name = 'assets/svg/ic_chat.svg';
      color = const Color(0xff999999);
    } else if (chatType == ChatType.groups) {
      name = 'assets/svg/ic_groups.svg';
      color = const Color(0xff79C0E8);
    } else if (chatType == ChatType.store) {
      name = 'assets/svg/ic_customer.svg';
      color = const Color(0xffA51B1B);
    }
    return SvgPicture.asset(
      name,
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
