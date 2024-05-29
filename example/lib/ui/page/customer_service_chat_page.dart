import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim_example/ui/view/expanded_viewport.dart';
import 'package:flutter_ytim_example/ui/view/full_screen_image_gallery.dart';
import 'package:flutter_ytim_example/ui/view/im_refresh_header.dart';
import 'package:flutter_ytim_example/ui/view/input_from.dart';
import 'package:flutter_ytim_example/ui/view/item_chat_msg.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

//客服会话页面
class CustomerServiceChatPage extends StatefulWidget {
  final StoreModel storeModel;
  final ChatType chatType;
  const CustomerServiceChatPage({super.key, required this.storeModel, required this.chatType});

  @override
  State<StatefulWidget> createState() {
    return _CustomerServiceChatPageState();
  }
}

class _CustomerServiceChatPageState extends State<CustomerServiceChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<IMBaseMessage> _msgList = [];
  final ScrollController _scrollController = ScrollController();
  String? nextTime;
  StreamSubscription? subscription;
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
    _getHistoryData(); //获取聊天消息
    _readMsgAction(); //发送已读请求
    Future.delayed(Duration.zero, () => _readMsg());

    subscription = imEventBus.on<IMEventCommand>().listen((event) {
      if(mounted){
        switch (event.type) {
          case IMEventCommandType.readMsg:
            if(event.command?.chatType == ChatType.store){
              IMStoreMessage msg = event.command?.msgData as IMStoreMessage;
              if (msg.storeId == widget.storeModel.storeId.toString()) {
                for (var element in _msgList) {
                  element.isRead = '1';
                }
                _remoteMsgFromMsgList(msg.time,msg.content);
              }
            }
            break;
          case IMEventCommandType.revokeMsg:
            if(event.command?.chatType == ChatType.store){
              IMStoreMessage msg = event.command?.msgData as IMStoreMessage;
              if (msg.storeId == widget.storeModel.storeId.toString()) {
                _remoteMsgFromMsgList(msg.time,msg.content);
              }
            }
            break;
          case IMEventCommandType.chatMsg:
            if(event.message?.chatType == ChatType.store){
              IMStoreMessage msg = event.message as IMStoreMessage;
              setState(() {
                //判定对方发来的消息
                if (msg.storeId == widget.storeModel.storeId.toString()) {
                  setState(() {
                    _msgList.insert(0, msg);
                  });
                  _jump2bottom();
                  _saveLastMsg();
                }
              });
              YTIM().setMessageRead(MessageTypeRead.storeMsg, widget.storeModel.storeId.toString(), (value) {

              });
            }
          default:
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final toUser = IMUser(
      username: widget.storeModel.name,
      userId: widget.storeModel.storeId.toString(),
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeModel.name ?? "")),
      body: Column(
        children: [
          _buildMsgList(),
          const Divider(),
          ChatInputForm(
            chatType: ChatType.store,
            toUser: toUser,
            onStoreMessageSuccessCallback: (msg, status) {
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
              slivers: <Widget>[
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
                          chatType: widget.chatType,
                          user: YTIM().mUser,
                          type: ChatItemType.me,
                          imgTap: () {
                            if (imsg.type == "2") {
                              //图片预览
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){return FullScreenImageGallery(
                                  messages: [imsg]);}));
                            }
                          },
                        ),
                      );
                    } else {
                      return ItemChat(
                        preItem: preMsg,
                        item: imsg,
                        chatType: widget.chatType,
                        store: widget.storeModel,
                        type: ChatItemType.other,
                        imgTap: () {
                          if (imsg.type == "2") {
                            //图片预览
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){return FullScreenImageGallery(
                                messages: [imsg]);}));
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
    YTIM().getChatHistoryMessage(widget.chatType, widget.storeModel.storeId.toString(), nextTime, (value) {
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
    YTIM().setMessageRead(MessageTypeRead.storeMsg, widget.storeModel.storeId.toString(), (value) {
      _readMsg();
    });
  }

  _readMsg() {
    // 重置对方的未读消息个数。
    IMUtils.clearSingleChatUnreadCount(context, widget.chatType, widget.storeModel.storeId.toString());
  }

  /// 撤销消息
  _revokeMessage(String? timestamp) {
    YTUtils.showAlertDialogActionsHasTitle(
      context,
      IMLocalizations.of(context).currentLocalization.imRevokeMessage,
      okCallBack: () {
        YTIM().revokeMessage(widget.chatType, widget.storeModel.storeId.toString(), timestamp!, (value) {
          if (value.event == 'cnl') {
            _remoteMsgFromMsgList(value.msgData?.time,value.msgData?.content);
          }
        });
        Navigator.pop(context);
      },
    );
  }

  _remoteMsgFromMsgList(String? timestamp,String? content) {
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
      IMStoreMessage lastMsg = _msgList.first as IMStoreMessage;
      String? storeId;
      // 自己发给对方的消息
      storeId = widget.storeModel.storeId.toString();
      IMUtils.saveLastMsg(widget.chatType, storeId, lastMsg.toString());
    } else {
      IMUtils.saveLastMsg(widget.chatType, widget.storeModel.storeId.toString(), null);
    }
  }

  //读取会话列表判定并添加对应会话到聊天列表
  _saveChat() {
    IMUtils.saveChat(context, ChatType.store, IMChatModel(
        storeId: widget.storeModel.storeId.toString(),
        store: widget.storeModel,
        chatType: widget.chatType));
  }
}
