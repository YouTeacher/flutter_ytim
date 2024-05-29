import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim_example/ui/page/group_detail_page.dart';
import 'package:flutter_ytim_example/ui/view/expanded_viewport.dart';
import 'package:flutter_ytim_example/ui/view/full_screen_image_gallery.dart';
import 'package:flutter_ytim_example/ui/view/im_refresh_header.dart';
import 'package:flutter_ytim_example/ui/view/input_from.dart';
import 'package:flutter_ytim_example/ui/view/item_chat_msg.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class GroupChatPage extends StatefulWidget {
  final IMGroup group;
  final ChatType chatType;
  const GroupChatPage({super.key, required this.group, required this.chatType});

  @override
  State<StatefulWidget> createState() {
    return _GroupChatPageState();
  }
}

class _GroupChatPageState extends State<GroupChatPage> {
  final List<IMBaseMessage> _msgList = [];
  final ScrollController _scrollController = ScrollController();
  int page = 1;
  String? nextTime; //用来标记分页其实位置
  IMGroup? _groupModel;
  List<IMUser> _users = [];
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  StreamSubscription? subscription;

  @override
  void dispose() {
    super.dispose();
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
    _groupModel = widget.group;
    _initData();
    subscription = imEventBus.on<IMEventCommand>().listen((event) {
      switch (event.type) {
        case IMEventCommandType.updateGroupInfo:
          setState(() {
            _groupModel = event.group;
            _users = _groupModel?.userList ?? [];
          });
          break;
        case IMEventCommandType.revokeMsg:
          if(mounted){
            if(event.command?.chatType == ChatType.groups){
              IMGroupMessage msg = event.command?.msgData as IMGroupMessage;
              if (msg.groupId == _groupModel?.groupId.toString()) {
                _remoteMsgFromMsgList(msg.time,msg.content);
              }
            }
          }
          break;
        case IMEventCommandType.chatMsg:
          if(mounted){
            if(event.message?.chatType == ChatType.groups){
              setState(() {
                IMGroupMessage message = event.message as IMGroupMessage;
                setState(() {
                  //判定对方发来的消息
                  if (message.groupId == _groupModel?.groupId.toString()) {
                    setState(() {
                      _msgList.insert(0, message);
                    });
                    _jump2bottom();
                    _saveLastMsg();
                  }
                });
                YTIM().setMessageRead(MessageTypeRead.groupMsg, _groupModel?.groupId.toString() ?? '', (value) {

                });
              });
            }
          }
          break;
        default:
      }
    });
  }

  //读取群组详细信息
  _initData() {
    YTIM().getGroupInfo(context, widget.group.groupId!, 1, (value) {
      if(mounted){
        setState(() {
          _groupModel = value;
          _users = _groupModel!.userList!;
        });
      }
    });
    _getGroupHistoryData(); //获取聊天消息
    Future.delayed(Duration.zero, () => _readGroupMsgAction()); //已读处理
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_groupModel?.name ?? ""),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: blackColor,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                      return GroupDetailsPage(
                        group: _groupModel!,
                      );
                    }));
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                _buildMsgList(),
                const Divider(),
                ChatInputForm(
                  toGroup: _groupModel,
                  chatType: widget.chatType,
                  onGroupMessageSuccessCallback: (msg, status) {
                    switch (status) {
                      case IMMessageSendState.sending:
                        //发送中
                        _jump2bottom();
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
                )
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
            _getGroupHistoryData();
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
                            _revokeMessage(imsg.time!);
                          }
                        },
                        child: ItemChat(
                          preItem: preMsg,
                          item: imsg,
                          user: YTIM().mUser,
                          type: ChatItemType.me,
                          imgTap: () {
                            if (imsg.type == "2") {
                              //图片预览
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                return FullScreenImageGallery(
                                    messages: [imsg]);
                              }));
                            }
                          }, chatType: widget.chatType,
                        ),
                      );
                    } else {
                      IMUser user = IMUser(avatar: '');
                      for (var item in _users) {
                        if (item.userId == imsg.from) {
                          user = item;
                          break;
                        }
                      }
                      return ItemChat(
                        preItem: preMsg,
                        item: imsg,
                        user: user,
                        chatType: widget.chatType,
                        type: ChatItemType.other,
                        imgTap: () {
                          if (imsg.type == "2") {
                            //图片预览
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                              return FullScreenImageGallery(
                                  messages: [imsg]);
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

  // 获取消息数据
  _getGroupHistoryData() {

    YTIM().getChatHistoryMessage(widget.chatType, _groupModel?.groupId.toString() ?? '', nextTime, (value) {
      if (mounted && value.messageList != null) {
        setState(() {
          _msgList.addAll(value.messageList!);
        });
        //更新页码
        if (nextTime == null) {
          // 最新的一页数据
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

  // 发送消息已读
  _readGroupMsgAction() {

    YTIM().setMessageRead(MessageTypeRead.groupMsg, _groupModel?.groupId.toString() ?? '', (value) {
      //已读成功 处理本地数据
      _readGroupMsg();
    });
  }

  _readGroupMsg() {
    // 重置对方的未读消息个数。
    IMUtils.clearSingleChatUnreadCount(context, widget.chatType, _groupModel?.groupId.toString() ?? '');
  }

  /// 撤销消息
  _revokeMessage(String timestamp) {
    YTUtils.showAlertDialogActionsHasTitle(
      context,
      IMLocalizations.of(context).currentLocalization.imRevokeMessage,
      okCallBack: () {
        YTIM().revokeMessage(widget.chatType, _groupModel?.groupId.toString() ?? '', timestamp, (value) {
          if (value.event == 'cnl') {
            _remoteMsgFromMsgList(timestamp,value.msgData?.content);
          }
        });
        Navigator.pop(context);
      },
    );
  }

  _remoteMsgFromMsgList(String? timestamp,String? content) {
    if(content== null || content.isEmpty){
      return;
    }
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
      IMGroupMessage lastMsg = _msgList.first as IMGroupMessage;
      IMUtils.saveLastMsg(widget.chatType, lastMsg.groupId!, lastMsg.toString());
    } else {
      IMUtils.saveLastMsg(widget.chatType,_groupModel!.groupId.toString(), null);
    }
  }

  _saveChat() {
    //读取会话列表判定并添加对应会话到聊天列表
    IMUtils.saveChat(context, widget.chatType, IMChatModel(
        groupId: widget.group.groupId, gourp: widget.group, chatType: widget.chatType));
  }
}
