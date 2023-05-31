import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';

/// 聊天消息类别
enum IMChatItemType { Me, Other }

/// 聊天消息item
class IMItemChat extends StatelessWidget {
  final IMUser user;
  final IMMessage? preItem;
  final IMMessage item;
  final IMChatItemType type;

  /// 头像点击事件
  final Callback<IMUser>? onAvatarTap;

  const IMItemChat({
    Key? key,
    required this.item,
    required this.user,
    required this.preItem,
    required this.type,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time;
    if (preItem == null) {
      // 第一条消息，需要显示。
      time = YTUtils.millisecondsToString(item.timestamp);
    } else {
      // 两条消息时间差在5分钟之内的话，不显示。大于5分钟显示出来。
      if (int.parse(item.timestamp!) - int.parse(preItem!.timestamp!) >
          5 * 60 * 1000) {
        time = YTUtils.millisecondsToString(item.timestamp);
      } else {
        time = '';
      }
    }
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Offstage(
            offstage: time.isEmpty,
            child: Container(
              child: Text(time, style: Theme.of(context).textTheme.bodySmall),
              margin: preItem == null
                  ? EdgeInsets.only(top: 30, bottom: 5)
                  : EdgeInsets.only(bottom: 5),
            ),
          ),
          _buildItem(context, type),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IMChatItemType type) {
    double defaultRadius = 6.0;
    Widget widget;
    switch (type) {
      case IMChatItemType.Me:
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 40,
            ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    item.read == '1'
                        ? Icons.check_circle_outline
                        : Icons.radio_button_off,
                    color: item.read == '1' ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                  Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        padding: EdgeInsets.all(10),
                        child: Text(item.content!),
                        decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.all(
                                Radius.circular(defaultRadius))),
                        constraints: BoxConstraints(minHeight: 40)),
                  ),
                ],
              ),
            ),
            IMUserAvatar(
              user,
              onAvatarTap: onAvatarTap,
            ),
          ],
        );
        break;
      case IMChatItemType.Other:
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IMUserAvatar(
              user,
              onAvatarTap: onAvatarTap,
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 40),
                padding: EdgeInsets.all(10),
                child: Text(item.content!),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                        BorderRadius.all(Radius.circular(defaultRadius))),
                constraints: BoxConstraints(minHeight: 40),
              ),
            )
          ],
        );
        break;
    }
    return widget;
  }
}
