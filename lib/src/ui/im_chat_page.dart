import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/bean/im_command.dart';
import 'package:flutter_ytim/src/bean/im_history_msg_list.dart';
import 'package:flutter_ytim/src/bean/im_msg.dart';
import 'package:flutter_ytim/src/ui/im_edit_text.dart';
import 'package:flutter_ytim/src/ui/im_item_chat_msg.dart';
import 'package:flutter_ytim/src/utils/yt_sp_utils.dart';
import 'package:flutter_ytim/src/values/localizations.dart';

/// IM 1v1聊天界面
class IMChatPage extends StatefulWidget {
  /// 对方的im id。
  final String tid;
  final double? widthInPad;

  /// 聊天界面中自己的头像被点击
  final Callback<IMUser>? onMeAvatarTap;

  /// 聊天界面中对方的头像被点击
  final Callback<IMUser>? onOtherAvatarTap;

  const IMChatPage({
    Key? key,
    required this.tid,
    this.widthInPad,
    this.onMeAvatarTap,
    this.onOtherAvatarTap,
  }) : super(key: key);

  @override
  _IMChatPageState createState() => _IMChatPageState();
}

class _IMChatPageState extends State<IMChatPage> {
  TextEditingController _textController = TextEditingController();
  bool _btnDisabled = true;

  List<IMMessage> _items = [];
  ScrollController _scrollController = ScrollController();

  late IMUser _tUser;

  @override
  void dispose() {
    super.dispose();
    // 将全局的聊天对象用户id置为空。
    YTIM().currentChatUserId = '';
  }

  @override
  void initState() {
    super.initState();
    _tUser = IMUser(id: widget.tid);
    YTIM().getHistoryMessage(widget.tid);
    YTIM().on<IMHistoryMsgList>().listen((event) {
      if (mounted) {
        setState(() {
          _items.clear();
          event.messageList!
              .sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
          _items.addAll(event.messageList!);
        });
        _saveLastMsg();
        _jump2bottom();
      }
    });
    YTIM().getProfile(widget.tid);
    YTIM().sendACK(widget.tid);
    YTIM().on<IMUser>().listen((event) {
      if (mounted) {
        setState(() {
          _tUser = event;
        });
      }
    });
    YTIM().on<IMMessage>().listen((event) {
      if (mounted) {
        setState(() {
          if (event.from == widget.tid ||
              event.from == YTIM().mUser.userId.toString()) {
            _items.add(event);
          }
        });
        _saveLastMsg();
        _jump2bottom();
        YTIM().sendACK(widget.tid);
      }
    });
    YTIM().on<IMCommand>().listen((event) {
      if (mounted) {
        setState(() {
          if (event.from == widget.tid || event.to == widget.tid) {
            if (event.module == 'readMessage') {
              _items.forEach((element) {
                element.read = '1';
              });
            }
            if (event.module == 'revokeMessage') {
              _remoteMsgFromMsgList(event.timestamp);
            }
          }
        });
      }
    });
  }

  /// 列表滚动到底部
  void _jump2bottom() {
    Timer(
        Duration(milliseconds: 200),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_tUser.username ?? ''),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            Widget child = Column(
              children: [
                _buildMsgList(),
                Divider(height: 1),
                _buildInputPanel(),
              ],
            );
            if (constraints.maxWidth > 600) {
              if (widget.widthInPad == null) {
                return child;
              } else {
                return Center(
                  child: Container(
                    color: Colors.white,
                    width: widget.widthInPad,
                    child: child,
                  ),
                );
              }
            } else {
              return child;
            }
          },
        ));
  }

  /// 发送消息输入框
  Widget _buildInputPanel() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.keyboard, color: Colors.grey),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            Expanded(
                child: IMEditText(
              noBorder: true,
              controller: _textController,
              onChanged: (text) {
                if (_btnDisabled != text.isEmpty) {
                  setState(() {
                    _btnDisabled = text.isEmpty;
                  });
                }
              },
            )),
            IconButton(
              icon: Icon(
                Icons.send_rounded,
                color:
                    _btnDisabled ? Colors.grey : Theme.of(context).primaryColor,
              ),
              onPressed: _btnDisabled
                  ? null
                  : () {
                      String content = _textController.text.trim();
                      if (content.isNotEmpty) {
                        _sendMsg(content);
                      }
                    },
            )
          ],
        ),
      ),
    );
  }

  /// 消息列表
  Widget _buildMsgList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          IMMessage msg = _items[index];
          IMMessage? preMsg;
          if (index != 0) {
            preMsg = _items[index - 1];
          }
          if (msg.from == YTIM().mUser.userId.toString()) {
            return GestureDetector(
              onLongPress: () => _revokeMessage(msg.timestamp),
              child: IMItemChat(
                preItem: preMsg,
                item: msg,
                user: YTIM().mUser,
                type: IMChatItemType.Me,
                onAvatarTap: widget.onMeAvatarTap,
              ),
            );
          } else {
            return IMItemChat(
              preItem: preMsg,
              item: msg,
              user: _tUser,
              type: IMChatItemType.Other,
              onAvatarTap: widget.onOtherAvatarTap,
            );
          }
        },
        itemCount: _items.length,
      ),
    );
  }

  /// 发送消息给对方
  void _sendMsg(String content) {
    setState(() {
      // 清空输入框
      _textController.clear();
      _btnDisabled = true;
    });
    _jump2bottom();
    YTIM().send(widget.tid, _tUser.username, content);
  }

  void _revokeMessage(String? timestamp) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(YTIMLocalizations.of(context)
              .currentLocalization
              .alertRevokeMessage),
          actions: <Widget>[
            TextButton(
                child: Text(
                    YTIMLocalizations.of(context).currentLocalization.cancel,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: Text(
                    YTIMLocalizations.of(context).currentLocalization.ok,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.pop(context);
                  YTIM().revokeMessage(widget.tid, timestamp);
                }),
          ],
        );
      },
    );
  }

  /// 保存最后一条消息到本地，用于展示在聊天历史界面。
  void _saveLastMsg() {
    if (_items.isNotEmpty) {
      IMMessage lastMsg = _items.last;
      String pk;
      if (lastMsg.from == YTIM().mUser.userId.toString()) {
        // 自己发给对方的消息
        pk = lastMsg.to!;
      } else {
        pk = lastMsg.from!;
      }
      YTSPUtils.saveLastMsg(pk, lastMsg);
    } else {
      YTSPUtils.saveLastMsg(widget.tid, null);
    }
  }

  /// 从界面删除消息
  /// 如果删除的是最后一条消息，需要同时更新本地记录。
  void _remoteMsgFromMsgList(String? timestamp) {
    if (_items.isNotEmpty) {
      _items.removeWhere((element) => element.timestamp == timestamp);
      if (_items.last.timestamp == timestamp) {
        _saveLastMsg();
      }
    }
  }
}
