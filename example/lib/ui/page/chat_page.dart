import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim_example/ui/page/chat_detail_page.dart';
import 'package:flutter_ytim_example/ui/view/expanded_viewport.dart';
import 'package:flutter_ytim_example/ui/view/full_screen_image_gallery.dart';
import 'package:flutter_ytim_example/ui/view/im_refresh_header.dart';
import 'package:flutter_ytim_example/ui/view/input_from.dart';
import 'package:flutter_ytim_example/ui/view/item_chat_msg.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async';

//单聊会话页面
class ChatPage extends StatefulWidget {
  final IMChatModel chatModel;
  final bool? popRoot;
  final ChatType chatType;

  const ChatPage(
      {super.key,
      required this.chatModel,
      this.popRoot = true,
      required this.chatType});

  @override
  State<StatefulWidget> createState() {
    return _ChatPageState();
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<IMBaseMessage> _msgList = [];
  final ScrollController _scrollController = ScrollController();
  bool hasFriend = false;
  StreamSubscription? subscription;

  String? nextTime;
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
  }

  @override
  void initState() {
    super.initState();

    List<IMUser> firends = context.read<IMStore>().firends;
    for (var item in firends) {
      if (item.userId == widget.chatModel.userId) {
        hasFriend = true;
        break;
      }
    }

    _getHistoryData(); //获取聊天消息
    _readMsgAction(); //发送已读请求
    Future.delayed(Duration.zero, () => _readMsg());
    subscription = imEventBus.on<IMEventCommand>().listen((event) {
      switch (event.type) {
        case IMEventCommandType.readMsg:
          if (event.command?.chatType == ChatType.user) {
            IMMessage msg = event.command?.msgData as IMMessage;
            if (msg.from == widget.chatModel.userId.toString() ||
                msg.to == widget.chatModel.userId.toString()) {
              for (var element in _msgList) {
                element.isRead = '1';
              }
              setState(() {});
            }
          }
          break;
        case IMEventCommandType.revokeMsg:
          if (event.command?.chatType == ChatType.user) {
            IMMessage msg = event.command?.msgData as IMMessage;
            if (msg.from == widget.chatModel.userId.toString() ||
                msg.to == widget.chatModel.userId.toString()) {
              _remoteMsgFromMsgList(msg.time, msg.content);
            }
          }
          break;
        case IMEventCommandType.chatMsg:
          if (event.message?.chatType == ChatType.user) {
            IMMessage msg = event.message as IMMessage;
            if (mounted) {
              setState(() {
                //判定对方发来的消息
                if (msg.from == widget.chatModel.userId.toString()) {
                  setState(() {
                    _msgList.insert(0, msg);
                  });
                  _jump2bottom();
                  _saveLastMsg();
                }
              });
              YTIM().setMessageRead(MessageTypeRead.chatMsg,
                  widget.chatModel.userId.toString(), (value) {});
            }
          }
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final toUser = IMUser(
      nickname: widget.chatModel.userInfo?.nickname,
      userId: widget.chatModel.userId,
    );
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        if (widget.popRoot!) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.pop(context);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: Text(toUser.nickname ?? ''),
              actions: hasFriend
                  ? [
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: blackColor,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return ChatDetailPage(
                              chatModel: widget.chatModel,
                            );
                          })).then((value) => setState(() {}));
                        },
                      ),
                    ]
                  : [],
            ),
            body: Column(
              children: [
                _buildMsgList(),
                const Divider(),
                ChatInputForm(
                  chatType: widget.chatType,
                  toUser: toUser,
                  onMessageSuccessCallback: (msg, status) {
                    switch (status) {
                      case IMMessageSendState.sending:
                        //发送中
                        _jump2bottom();
                        // 消息发送成功
                        setState(() {
                          _msgList.insert(0, msg);
                        });
                        _saveLastMsg();
                        _saveChat();
                        break;
                      case IMMessageSendState.sendError:
                        //发送失败
                        int targetIndex = _msgList
                            .indexWhere((message) => message.uuid == msg.uuid);
                        IMBaseMessage message = _msgList[targetIndex];
                        message.status = '2';
                        setState(() {
                          _msgList[targetIndex] = message;
                        });
                        _saveLastMsg();
                        break;
                      case IMMessageSendState.sendSuccess:
                        //发送成功
                        int targetIndex = _msgList
                            .indexWhere((message) => message.uuid == msg.uuid);
                        IMBaseMessage message = _msgList[targetIndex];
                        msg.filePath = message.filePath;
                        setState(() {
                          _msgList[targetIndex] = msg;
                        });
                        _saveLastMsg();
                        break;
                      default:
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 消息列表
  _buildMsgList() {
    return Expanded(
      child: EasyRefresh(
        controller: _refreshController,
        refreshOnStart: true,
        refreshOnStartHeader: IMRefreshOnStartHeader(),
        onLoad: () {
          if (_msgList.isNotEmpty) {
            _getHistoryData();
          }
        },
        child: Scrollable(
          controller: _scrollController,
          axisDirection: AxisDirection.up,
          viewportBuilder: (context, offset) {
            return ExpandedViewport(
              offset: offset as ScrollPosition,
              axisDirection: AxisDirection.up,
              slivers: [
                SliverExpanded(),
                SliverList(
                  delegate: SliverChildBuilderDelegate((c, i) {
                    IMBaseMessage imsg = _msgList[i];
                    IMBaseMessage? preMsg;
                    if (i != _msgList.length - 1) {
                      preMsg = _msgList[i + 1];
                    }
                    if (imsg.from == YTIM().mUser.userId.toString()) {
                      return GestureDetector(
                        onLongPress: () {
                          if (imsg.isRecall != "1") {
                            _revokeMessage(imsg.time);
                          }
                        },
                        child: ItemChat(
                          preItem: preMsg,
                          item: imsg,
                          user: YTIM().mUser,
                          type: ChatItemType.me,
                          chatType: widget.chatType,
                          imgTap: () {
                            if (imsg.type == "2") {
                              //图片预览
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return FullScreenImageGallery(messages: [imsg]);
                              }));
                            }
                          },
                        ),
                      );
                    } else {
                      return ItemChat(
                        preItem: preMsg,
                        chatType: widget.chatType,
                        item: imsg,
                        user: widget.chatModel.userInfo!,
                        type: ChatItemType.other,
                        imgTap: () {
                          if (imsg.type == "2") {
                            //图片预览
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return FullScreenImageGallery(messages: [imsg]);
                            }));
                          }
                        },
                      );
                    }
                  }, childCount: _msgList.length),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// 列表滚动到底部
  _jump2bottom() {
    _scrollController.jumpTo(0.0);
  }

  _getHistoryData() {
    YTIM().getChatHistoryMessage(
        widget.chatType, widget.chatModel.userId.toString(), nextTime,
            (value) {
          if (mounted && value.messageList != null) {
            setState(() {
              _msgList.addAll(value.messageList!);
            });
            //更新页码
            if (nextTime == null) {
              //最新的一页数据
              // 保存最后一条消息。
              _saveLastMsg();
              _jump2bottom();
            }
            if (value.nextTime != null) {
              nextTime = value.nextTime;
            }

            _refreshController.finishLoad(
              value.hasMore ? IndicatorResult.success : IndicatorResult.noMore,
            );
          }
        });
  }

  _readMsgAction() {
    YTIM().setMessageRead(
        MessageTypeRead.chatMsg, widget.chatModel.userId.toString(),
            (value) {
          _readMsg();
        });
  }

  _readMsg() {
    // 重置对方的未读消息个数。
    IMUtils.clearSingleChatUnreadCount(
        context, widget.chatType, widget.chatModel.userId.toString());
  }

  /// 撤销消息
  _revokeMessage(String? timestamp) {
    YTUtils.showAlertDialogActionsHasTitle(
      context,
      IMLocalizations.of(context).currentLocalization.imRevokeMessage,
      okCallBack: () {
        YTIM().revokeMessage(
            widget.chatType, widget.chatModel.userId.toString(), timestamp!,
            (value) {
          if (value.event == 'cnl') {
            _remoteMsgFromMsgList(value.msgData?.time, value.msgData?.content);
          }
        });
        Navigator.pop(context);
      },
    );
  }

  _remoteMsgFromMsgList(String? timestamp, String? content) {
    if (_msgList.isNotEmpty) {
      int index = 0;
      for (var i = 0; i < _msgList.length; i++) {
        var item = _msgList[i];
        if (item.time == timestamp) {
          index = i;
          break;
        }
      }
      setState(() {
        _msgList[index].isRecall = '1';
        _msgList[index].content = content;

        /// 如果撤销的是最后一条消息，需要同时更新本地记录。
        if (_msgList.first.time == timestamp) {
          _saveLastMsg();
        }
      });
    }
  }

  /// 保存最后一条消息到本地，用于展示在聊天历史界面。
  _saveLastMsg() {
    if (_msgList.isNotEmpty) {
      IMMessage lastMsg = _msgList.first as IMMessage;
      String? pk;
      if (lastMsg.from == YTIM().mUser.userId.toString()) {
        // 自己发给对方的消息
        pk = lastMsg.to;
      } else {
        pk = lastMsg.from;
      }
      pk ??= widget.chatModel.userId;
      IMUtils.saveLastMsg(widget.chatType, pk!, lastMsg.toString());
    } else {
      IMUtils.saveLastMsg(
          widget.chatType, widget.chatModel.userId.toString(), null);
    }
  }

  _saveChat() {
    //读取会话列表判定并添加对应会话到聊天列表
    IMUtils.saveChat(context, widget.chatType, widget.chatModel);
  }
}
