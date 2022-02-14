import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// IM 用户列表
class IMUserListPage extends StatefulWidget {
  /// header: 头布局 [SliverPersistentHeader] or [AppBar] or 其他类型组件
  final Widget? header;
  final String? order;
  final double? widthInPad;

  /// 聊天界面中自己的头像被点击
  final Callback<IMUser>? onMeAvatarTap;

  /// 聊天界面中对方的头像被点击
  final Callback<IMUser>? onOtherAvatarTap;

  const IMUserListPage({
    Key? key,
    required this.header,
    this.order,
    this.widthInPad,
    this.onMeAvatarTap,
    this.onOtherAvatarTap,
  }) : super(key: key);

  @override
  _IMUserListPageState createState() => _IMUserListPageState();
}

class _IMUserListPageState extends State<IMUserListPage> {
  List<IMUser> _items = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    // 未读消息列表
    YTIM().on<IMUnreadMsgList>().listen((event) {
      Map<String, dynamic> messageList = event.messageList!;
      Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
      for (String imId in messageList.keys) {
        List? msgs = messageList[imId] as List?;
        if (map[imId] == null) {
          map[imId] = IMLastInfo(
              msg: IMMessage.fromJson(msgs!.last), unreadCount: msgs.length);
        } else {
          map[imId]!.msg = IMMessage.fromJson(msgs!.last);
          map[imId]!.unreadCount = msgs.length;
        }
      }
      context.read<IMStore>().update(map);
      _updateUnreadCount(map);
    });
    // 新消息
    YTIM().on<IMMessage>().listen((event) {
      Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
      if (!YTSPUtils.getMuteList().contains(event.from)) {
        if (map.keys.contains(event.from)) {
          if (YTIM().currentChatUserId != event.from) {
            map[event.from]!.unreadCount += 1;
          }
          map[event.from]!.msg = event;
        } else {
          if (event.from != YTIM().mUser.userId) {
            map[event.from] = IMLastInfo(
                msg: event,
                unreadCount: YTIM().currentChatUserId != event.from ? 1 : 0);
          }
        }
      }
      // 如果对方不在历史列表中，重新获取一次联系人列表。
      if (!_items.map((e) => e.userId).contains(event.from)) {
        YTIM().getUserList(order: widget.order);
      }
      YTSPUtils.saveLastMsg(event.from!, event);
      context.read<IMStore>().update(map);
      _updateUnreadCount(map);
    });
    // 联系人列表
    YTIM().on<IMUserList>().listen((event) {
      _refreshController.refreshCompleted();
      if (event.userList != null) {
        if (mounted) {
          YTIM().getUnreadMessage();
          setState(() {
            _items = event.userList!;
          });
          _setLastMsg();
        }
      }
    });
  }

  /// 通知更新未读消息
  void _updateUnreadCount(Map<String?, IMLastInfo> map) {
    YTUtils.updateUnreadCount(map);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (c, i) {
            Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
            return _buildItem(
                _items[i], map[_items[i].userId]?.unreadCount ?? 0);
          },
          childCount: _items.length,
        ),
      )
    ];
    if (widget.header != null && !(widget.header is AppBar)) {
      if (widget.header is SliverPersistentHeader) {
        children.insert(0, widget.header!);
      } else {
        children.insert(0, SliverToBoxAdapter(child: widget.header));
      }
    }
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          Widget child = SmartRefresher(
            controller: _refreshController,
            onRefresh: () => YTIM().getUserList(order: widget.order),
            child: CustomScrollView(slivers: children),
          );
          if (constraints.maxWidth > 600) {
            if (widget.widthInPad == null) {
              return child;
            } else {
              return Center(
                child: Container(
                  width: widget.widthInPad,
                  child: child,
                ),
              );
            }
          } else {
            return child;
          }
        },
      ),
    );
  }

  Widget _buildItem(IMUser item, int count) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            icon: YTSPUtils.getMuteList().contains(item.userId)
                ? Icons.notifications_none_outlined
                : Icons.notifications_off_outlined,
            onPressed: (context) {
              if (YTSPUtils.getMuteList().contains(item.userId)) {
                YTSPUtils.removeFromMuteList(item.userId!);
                setState(() {});
              } else {
                _showDialogWithActions(
                    YTIMLocalizations.of(context)
                        .currentLocalization
                        .muteConversation, () {
                  // 将当前会话对方id加入本地黑名单，收到消息直接将消息设置为已读。
                  YTSPUtils.insertMuteList(item.userId!);
                  Navigator.pop(context);
                  setState(() {});
                });
              }
            },
          ),
          SlidableAction(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            onPressed: (context) {
              _showDialogWithActions(
                  YTIMLocalizations.of(context)
                      .currentLocalization
                      .deleteConversation, () {
                // 2021/7/26 删除会话
                YTIM().deleteSession(item.userId!);
                _resetUserReadCount(item.userId!);
                Navigator.pop(context);
                setState(() {
                  _items
                      .removeWhere((element) => element.userId == item.userId);
                });
              });
            },
          ),
          SlidableAction(
            backgroundColor: YTSPUtils.getBlockList().contains(item.userId)
                ? Colors.grey
                : Colors.redAccent,
            foregroundColor: Colors.white,
            icon: YTSPUtils.getBlockList().contains(item.userId)
                ? Icons.block_flipped
                : Icons.block,
            onPressed: (context) {
              if (YTSPUtils.getBlockList().contains(item.userId)) {
                // 取消拉黑
                YTSPUtils.removeFromBlockList(item.userId!);
                setState(() {});
              } else {
                // 拉黑
                _showDialogWithActions(
                    YTIMLocalizations.of(context).currentLocalization.block,
                    () {
                  // 2021/7/27 拉黑对方
                  YTSPUtils.insertBlockList(item.userId!);
                  _resetUserReadCount(item.userId!);
                  Navigator.pop(context);
                  setState(() {});
                });
              }
            },
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 重置对方的未读消息个数。
          Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
          if (map.keys.contains(item.userId)) {
            map[item.userId]!.unreadCount = 0;
            context.read<IMStore>().update(map);
          }
          YTUtils.updateUnreadCount(map);
          YTIM().currentChatUserId = item.userId!;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return IMChatPage(
                tid: item.userId!,
                widthInPad: widget.widthInPad,
                onMeAvatarTap: widget.onMeAvatarTap,
                onOtherAvatarTap: widget.onOtherAvatarTap,
              );
            }),
          ).then((value) {
            YTIM().currentChatUserId = '';
            _setLastMsg();
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: Divider.createBorderSide(context)),
            color: Colors.white,
          ),
          constraints: BoxConstraints(minHeight: 72),
          child: Row(
            children: [
              IMUserAvatar(item),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 名字
                      Text(item.username!),
                      SizedBox(height: 3),
                      // 最后一条消息
                      Text(
                        context
                                .read<IMStore>()
                                .lastInfos[item.userId]
                                ?.msg
                                ?.content ??
                            '',
                        style: Theme.of(context).textTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              YTSPUtils.getBlockList().contains(item.userId)
                  ? Icon(Icons.block, color: Colors.grey)
                  : YTSPUtils.getMuteList().contains(item.userId)
                      ? Icon(Icons.notifications_off_outlined,
                          color: Colors.grey)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 时间
                            Text(
                                YTUtils.millisecondsToString(context
                                        .read<IMStore>()
                                        .lastInfos[item.userId]
                                        ?.msg
                                        ?.timestamp ??
                                    ''),
                                style: Theme.of(context).textTheme.caption),
                            SizedBox(height: 3),
                            // 未读个数
                            UnreadCountView(count: count),
                          ],
                        )
            ],
          ),
        ),
      ),
    );
  }

  /// 重置对方的未读数，并且发送已读回执。
  void _resetUserReadCount(String userId) {
    // 这个会话的未读数置为0。
    Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
    if (map.keys.contains(userId)) {
      map[userId]!.unreadCount = 0;
      context.read<IMStore>().update(map);
    }
    YTUtils.updateUnreadCount(map);
    // 给对方发一条已读指令，不然会刷新到未读消息，最近联系人中却看不到。
    YTIM().sendACK(userId);
  }

  void _setLastMsg() {
    setState(() {
      for (IMUser user in _items) {
        IMMessage? msg = YTSPUtils.getLastMsg(user.userId);
        if (msg != null) {
          Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
          if (map[user.userId] == null) {
            map[user.userId] = IMLastInfo(msg: msg);
          } else {
            map[user.userId]!.msg = msg;
          }
        }
      }
    });
  }

  void _showDialogWithActions(String title, VoidCallback onOKPressed) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(title),
          actions: <Widget>[
            TextButton(
                child: Text(
                    YTIMLocalizations.of(context).currentLocalization.cancel,
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            TextButton(
              child: Text(YTIMLocalizations.of(context).currentLocalization.ok,
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: onOKPressed,
            ),
          ],
        );
      },
    );
  }
}
