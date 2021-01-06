import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/bean/im_command.dart';
import 'package:flutter_ytim/src/bean/im_history.dart';
import 'package:flutter_ytim/src/bean/im_msg.dart';
import 'package:flutter_ytim/src/other/yt_sp_utils.dart';
import 'package:flutter_ytim/src/ui/item_chat_msg.dart';

class ChatPage extends StatefulWidget {
  /// 对方的im id。
  final String tid;

  const ChatPage({Key key, @required this.tid}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _textController = TextEditingController();
  bool _btnDisabled = true;

  List<IMMessage> _items = [];
  ScrollController _scrollController = ScrollController();

  IMUser _tUser;

  @override
  void initState() {
    super.initState();
    _tUser = IMUser(id: widget.tid);
    YTIM().getHistoryMessage(widget.tid);
    YTIM().on<IMHistory>().listen((event) {
      if (mounted) {
        setState(() {
          _items.clear();
          event.messageList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _items.addAll(event.messageList);
        });
        _saveLastMsg();
        _jump2bottom();
      }
    });
    YTIM().getProfile(widget.tid);
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
        Duration(milliseconds: 500),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tUser.username ?? ''),
      ),
      body: Column(
        children: [
          _buildMsgList(),
          Divider(height: 1),
          _buildInputPanel(),
        ],
      ),
    );
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
                child: TextField(
              keyboardType: TextInputType.multiline,
              cursorColor: Theme.of(context).primaryColor,
              controller: _textController,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.caption,
                isDense: true,
                contentPadding:
                    EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
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
          IMMessage preMsg;
          if (index != 0) {
            preMsg = _items[index - 1];
          }
          if (msg.from == YTIM().mUser.userId.toString()) {
            return GestureDetector(
              onLongPress: () => _revokeMessage(msg.timestamp),
              child: ItemChat(
                  preItem: preMsg,
                  item: msg,
                  user: YTIM().mUser,
                  type: ChatItemType.Me),
            );
          } else {
            return ItemChat(
                preItem: preMsg,
                item: msg,
                user: _tUser,
                type: ChatItemType.Other);
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

  void _revokeMessage(String timestamp) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('确定撤回删除？'),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: Text('OK',
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
        pk = lastMsg.to;
      } else {
        pk = lastMsg.from;
      }
      YTSPUtils.saveLastMsg(pk, lastMsg);
    } else {
      YTSPUtils.saveLastMsg(widget.tid, null);
    }
  }

  /// 从界面删除消息
  /// 如果删除的是最后一条消息，需要同时更新本地记录。
  void _remoteMsgFromMsgList(String timestamp) {
    if (_items.isNotEmpty) {
      _items.removeWhere((element) => element.timestamp == timestamp);
      if (_items.last.timestamp == timestamp) {
        _saveLastMsg();
      }
    }
  }
}
