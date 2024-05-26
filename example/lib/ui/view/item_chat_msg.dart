import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/view/voice_message_cell.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

/// 聊天消息类别
enum ChatItemType { me, other }

/// 聊天消息item
class ItemChat extends StatelessWidget {
  final IMUser? user;

  final ChatType chatType;

  final IMBaseMessage? preItem;
  final IMBaseMessage item;
  final StoreModel? store;

  final ChatItemType type;
  final void Function()? imgTap;

  const ItemChat({
    super.key,
    required this.item,
    this.user,
    this.preItem,
    this.imgTap,
    this.store,
    required this.type, required this.chatType,
  });

  @override
  Widget build(BuildContext context) {
    String time = '';
    if (preItem == null) {
      time = YTUtils.millisecondsToString(item.time);
    } else {
      if (int.parse(item.time!) - int.parse(preItem!.time!) > (5 * 60 * 1000)) {
        time = YTUtils.millisecondsToString(item.time);
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        children: [
          Offstage(
            offstage: time.isEmpty,
            child: Container(
              margin: preItem == null
                  ? const EdgeInsets.only(top: 16, bottom: 5)
                  : const EdgeInsets.only(bottom: 5),
              child: Text(time, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          _buildItem(context, type),
        ],
      ),
    );
  }

  _buildItem(BuildContext context, ChatItemType type) {
    double defaultRadius = 6.0;
    Widget widget;
    switch (type) {
      case ChatItemType.me:
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 40),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: item.status == '1'
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        : item.status == '2'
                            ? const Icon(Icons.error)
                            : Container(),
                  ),
                  if (item.isRecall != '1')
                    if(item.chatType != ChatType.groups) Text(
                      item.isRead == '1'
                          ? IMLocalizations.of(context).currentLocalization.imRead
                          : IMLocalizations.of(context).currentLocalization.imUnread,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 15, right: 15),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius:
                              BorderRadius.all(Radius.circular(defaultRadius))),
                      constraints: const BoxConstraints(minHeight: 40),
                      child: ChatMessageType(
                        type: item.type!,
                        isRecall: item.isRecall,
                        status: item.status,
                        content: item.content,
                        filePath: item.filePath,
                        imgTap: imgTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IMCustomCircleAvatar(
              type: IMAvatarType.user,
              avatarUrl: chatType == ChatType.store ? user?.avatar ?? store?.cover : user?.avatar,
              size: 40,
            )
          ],
        );
        break;
      case ChatItemType.other:
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IMCustomCircleAvatar(
              type: IMAvatarType.user,
              avatarUrl: chatType == ChatType.store ? user?.avatar ?? store?.cover : user?.avatar,
              size: 40,
            ),
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(left: 15, right: 40),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                        BorderRadius.all(Radius.circular(defaultRadius))),
                constraints: const BoxConstraints(minHeight: 40),
                child: ChatMessageType(
                  type: item.type!,
                  isRecall: item.isRecall,
                  status: item.status,
                  content: item.content,
                  filePath: item.filePath,
                  imgTap: imgTap,
                ),
              ),
            )
          ],
        );
        break;
    }
    return widget;
  }
}

class ChatMessageType extends StatelessWidget {
  final String type;
  final String? isRecall;
  final String? status;
  final String? content;
  final String? filePath;
  final void Function()? imgTap;

  const ChatMessageType(
      {super.key,
      this.isRecall,
      this.status,
      this.content,
      this.filePath,
      this.imgTap,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return _getItemView(context);
  }

  _getItemView(BuildContext context) {
    // 文本
    if (type == '1') {
      return Text(content ?? "");
    }
    // 图片
    else if (type == '2') {
      if (status == '1' || status == '2') {
        return InkWell(
          onTap: imgTap,
          child: Image.file(File(filePath ?? "")),
        );
      } else {
        if (isRecall == '1') {
          return Text(content ?? "");
        }
        return InkWell(
          onTap: imgTap,
          child: CachedNetworkImage(
            imageUrl: content ?? "",
            placeholder: (context, url) => filePath != null
                ? Image.file(File(filePath ?? ""))
                : Icon(Icons.photo),
            errorWidget: (context, url, error) =>
                Icon(Icons.photo),
            fit: BoxFit.cover,
          ),
        );
      }
    }
    // 语音
    else if (type == '3') {
      if (isRecall == '1') {
        return Text(content ?? "");
      }
      return VoiceMessageCell(
        audioUrl: content ?? "", // 替换为实际的音频文件URL
      );
    }
    return const Text("");
  }
}
