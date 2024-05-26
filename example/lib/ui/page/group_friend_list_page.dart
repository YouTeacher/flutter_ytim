import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_botton_bar.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

enum GroupFriendListType {
  add, // 添加群组人员
  delete, // 管理群组人员
}

class GroupFriendListPage extends StatefulWidget {
  final List<IMUser>? users;
  final String? groupId;
  final GroupFriendListType type;
  const GroupFriendListPage(
      {required this.type, this.users, this.groupId, super.key});

  @override
  State<GroupFriendListPage> createState() => _GroupFriendListPageState();
}

class _GroupFriendListPageState extends State<GroupFriendListPage> {
  List<String> userIds = [];
  List<IMUser> users = [];
  List<IMUser> selectUsers = [];

  @override
  void initState() {
    super.initState();
    if (widget.type == GroupFriendListType.add) {
      users = context.read<IMStore>().firends;
    } else {
      for (IMUser item in widget.users!) {
        if (item.userId != YTIM().mUser.userId) {
          users.add(item);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: users.isEmpty
                    ? Center(
                        child: Text(IMLocalizations.of(context).currentLocalization.noData),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SlidableAutoCloseBehavior(
                              child: ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (context, index) {
                                  return _buildListItem(index);
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
      bottomNavigationBar: IMCustomBottomNavigationBar(
        onTap: () {
          if (widget.type == GroupFriendListType.delete) {
            _deleteGroupUser();
          } else {
            _addGroupUser();
          }
        },
        title: IMLocalizations.of(context).currentLocalization.ok,
      ),
    );
  }

  _buildListItem(int index) {
    var userId = users[index].userId;
    return IMGroupUserCell(
      users[index],
      userList: widget.users,
      type: widget.type,
      isSelect: userIds.contains(userId),
      onAddTap: (value) {
        setState(() {
          userIds.add(userId!);
        });
      },
      onDeleteTap: (value) {
        setState(() {
          if (userIds.contains(userId)) {
            userIds.remove(userId!);
          }
        });
      },
    );
  }

  _deleteGroupUser() {
    if (userIds.isEmpty) {
      Navigator.pop(context);
    } else {
      YTIM().groupUsersOperations(widget.groupId!, userIds, 1, (value) {
        _groupInfo();
      });
    }
  }

  _addGroupUser() {
    if (userIds.isEmpty) {
      Navigator.pop(context);
    } else {
      YTIM().groupUsersOperations(widget.groupId!, userIds, 0, (value) {
        _groupInfo();
      });
    }
  }

  //读取群组详细信息
  _groupInfo() {
    YTIM().getGroupInfo(context, widget.groupId!, 1, (value) {
      if(mounted){
        setState(() {
          imEventBus.fire(
              IMEventCommand(IMEventCommandType.updateGroupInfo, group: value));
          Navigator.pop(context,value);
        });
      }
    });
  }
}
