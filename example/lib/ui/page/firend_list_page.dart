import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_botton_bar.dart';
import 'package:flutter_ytim_example/ui/widget/im_empty_view.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

enum FirendListType {
  select, // 创建组选择组员
  manager, // 删除好友
}

//好友列表
class FriendListPage extends StatefulWidget {
  final FirendListType? type;
  final List<IMUser>? users;
  final String? groupId;
  const FriendListPage({this.type, this.users, this.groupId, super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  List<String> userIds = [];
  List<IMUser> users = [];
  @override
  void initState() {
    super.initState();
    if (widget.users != null) {
      users = widget.users!;
      for (IMUser item in widget.users!) {
        if (item.userId != null) {
          userIds.add(item.userId!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<IMUser> items = context.watch<IMStore>().firends;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text(IMLocalizations.of(context).currentLocalization.friendList)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: Center(
              child: Container(
                width: YTUtils.iPadSize(constraints),
                alignment: Alignment.center,
                child: items.isEmpty
                    ? const IMEmptyView()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SlidableAutoCloseBehavior(
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return _buildItem(index, context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Offstage(
        offstage: widget.type == FirendListType.manager ? true : false,
        child: IMCustomBottomNavigationBar(
          onTap: () {
            Navigator.pop(context,users);
          },
          title: IMLocalizations.of(context).currentLocalization.ok,
        ),
      ),
    );
  }

  _buildItem(int index, BuildContext? fatherContext) {
    List<IMUser> items = context.watch<IMStore>().firends;
    return widget.type == FirendListType.manager
        ? Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.2,
              children: [
                SlidableAction(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  onPressed: (context) {
                    YTUtils.showAlertDialogActionsHasTitle(
                      context,
                      IMLocalizations.of(context).currentLocalization.deleteFirend,
                      okCallBack: () {
                        Navigator.pop(fatherContext ?? context);
                        _deleteFirend(items[index]);
                      },
                    );
                  },
                ),
              ],
            ),
            child: _buildListItem(index),
          )
        : _buildListItem(index);
  }

  _buildListItem(int index) {
    List<IMUser> items = context.watch<IMStore>().firends;
    return IMUserCell(
      items[index],
      type: widget.type,
      isAddFriend: false,
      isSelect: userIds.contains(items[index].userId),
      onSelectTap: (value) {
        if (value) {
          if (mounted) {
            setState(() {
              userIds.add(items[index].userId!);
              users.add(items[index]);
            });
          }
        } else {
          if (userIds.contains(items[index].userId)) {
            userIds.remove(items[index].userId!);
            users.removeWhere((user) => user.userId == items[index].userId);
          }
          if (mounted) {
            setState(() {});
          }
        }
      },
    );
  }

  // 删除好友
  _deleteFirend(IMUser user) {

    YTIM().deleteFriend(context, user.userId.toString(), '1', (value) {
      IMUtils.deleteFriend(context, user.userId.toString());
    });
  }
}
