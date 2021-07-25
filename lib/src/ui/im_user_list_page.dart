import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/bean/im_store.dart';
import 'package:flutter_ytim/src/bean/im_unread_msg_list.dart';
import 'package:flutter_ytim/src/ui/im_chat_page.dart';
import 'package:flutter_ytim/src/utils/yt_sp_utils.dart';
import 'package:flutter_ytim/src/utils/yt_utils.dart';
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

  /// 更多按钮点击事情
  final Callback<IMUser>? onMoreTap;

  const IMUserListPage({
    Key? key,
    required this.header,
    this.order,
    this.widthInPad,
    this.onMeAvatarTap,
    this.onOtherAvatarTap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  _IMUserListPageState createState() => _IMUserListPageState();
}

class _IMUserListPageState extends State<IMUserListPage> {
  List<IMUser>? _items = [];
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
      if (map.keys.contains(event.from)) {
        if (YTIM().currentChatUserId != event.from) {
          map[event.from]!.unreadCount += 1;
        }
        map[event.from]!.msg = event;
      } else {
        if (event.from != YTIM().mUser.userId.toString()) {
          map[event.from] = IMLastInfo(
              msg: event,
              unreadCount: YTIM().currentChatUserId != event.from ? 1 : 0);
        }
      }
      YTSPUtils.saveLastMsg(event.from!, event);
      context.read<IMStore>().update(map);
      _updateUnreadCount(map);
    });
    // 联系人列表
    YTIM().on<IMUserList>().listen((event) {
      _refreshController.refreshCompleted();
      if (mounted) {
        YTIM().getUnreadMessage();
        setState(() {
          _items = event.userList;
        });
        _setLastMsg();
      }
    });
    // 取最近联系人。
    YTIM().getUserList(order: widget.order);
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
            return _buildItem(_items![i],
                map[_items![i].userId.toString()]?.unreadCount ?? 0);
          },
          childCount: _items!.length,
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
    return InkWell(
      onTap: () {
        // 重置对方的未读消息个数。
        Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
        if (map.keys.contains(item.userId.toString())) {
          map[item.userId.toString()]!.unreadCount = 0;
          context.read<IMStore>().update(map);
        }
        YTUtils.updateUnreadCount(map);
        YTIM().currentChatUserId = item.userId.toString();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return IMChatPage(
              tid: item.userId.toString(),
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
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 6),
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
                              .lastInfos[item.userId.toString()]
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Offstage(
                  offstage: widget.onMoreTap == null,
                  child: GestureDetector(
                    child: Icon(Icons.more_horiz, color: Colors.grey),
                    onTap: () {
                      if (widget.onMoreTap != null) {
                        widget.onMoreTap!(item);
                      }
                    },
                  ),
                ),
                // 时间
                Text(
                    YTUtils.millisecondsToString(context
                            .read<IMStore>()
                            .lastInfos[item.userId.toString()]
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
    );
  }

  void _setLastMsg() {
    setState(() {
      for (IMUser user in _items!) {
        IMMessage? msg = YTSPUtils.getLastMsg(user.userId.toString());
        if (msg != null) {
          Map<String?, IMLastInfo> map = context.read<IMStore>().lastInfos;
          if (map[user.userId.toString()] == null) {
            map[user.userId.toString()] = IMLastInfo(msg: msg);
          } else {
            map[user.userId.toString()]!.msg = msg;
          }
        }
      }
    });
  }
}
