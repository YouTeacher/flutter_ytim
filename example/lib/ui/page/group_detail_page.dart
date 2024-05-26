import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim_example/ui/page/group_edit_page.dart';
import 'package:flutter_ytim_example/ui/page/group_friend_list_page.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_botton_bar.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class GroupDetailsPage extends StatefulWidget {
  final IMGroup group;
  const GroupDetailsPage({super.key, required this.group});

  @override
  State<StatefulWidget> createState() {
    return _GroupDetailsPageState();
  }
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  IMGroup? _groupModel;
  List<IMUser> _selectedUsers = [];
  String? userType;

  @override
  void initState() {
    super.initState();
    _groupModel = widget.group;
    _selectedUsers = _groupModel?.userList ?? [];
    if (_selectedUsers.isNotEmpty) {
      bool isSame = false;
      for (var i = 0; i < _selectedUsers.length; i++) {
        var item = _selectedUsers[i];
        if (item.userId == YTIM().mUser.userId) {
          isSame = true;
          break;
        }
      }
      if (isSame) {
        IMUser user = _selectedUsers
            .firstWhere((element) => element.userId == YTIM().mUser.userId);
        userType = user.userType;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(IMLocalizations.of(context).currentLocalization.detail),
        actions: userType == '1' || userType == '2'
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                      return GroupsEditPage(
                        group: widget.group,
                      );
                    })).then((value) {
                      if (mounted) {
                        if (value != null) {
                          setState(() {
                            _groupModel = value;
                          });
                        }
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: darkColor,
                    size: 22,
                  ),
                )
              ]
            : [],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = (YTUtils.iPadSize(constraints) - 80) / 5;
          return Center(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
              width: YTUtils.iPadSize(constraints),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IMCustomCircleAvatar(
                    type: IMAvatarType.user,
                    avatarUrl: _groupModel?.avatar ?? '',
                    size: width,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 5),
                    child: Text(
                      IMLocalizations.of(context).currentLocalization.groupNameTitel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    _groupModel?.name ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 5),
                    child: Text(IMLocalizations.of(context).currentLocalization.groupDesTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  // 群组简介
                  Text(_groupModel?.desc ?? ""),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 10),
                    child: Text(
                      IMLocalizations.of(context).currentLocalization.memberInvitation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 成员头像
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: width / (width + 30),
                      ),
                      itemCount: userType == '3'
                          ? _selectedUsers.length
                          : _selectedUsers.length + 2,
                      itemBuilder: (context, index) {
                        if (userType == '3') {
                          return _buildMemberItem(_selectedUsers[index], width);
                        }
                        // 添加的图标
                        if (index == _selectedUsers.length) {
                          return _buildOtherMemberItem(width, 1);
                        }
                        // 删除图标
                        if (index == _selectedUsers.length + 1) {
                          return _buildOtherMemberItem(width, 0);
                        }

                        return _buildMemberItem(_selectedUsers[index], width);
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: IMCustomBottomNavigationBar(
        onTap: () {
          if (userType == '1' || userType == '2') {
            YTUtils.showAlertDialogActionsHasTitle(
              context,
              IMLocalizations.of(context).currentLocalization.deleteGroupConfirm,
              okCallBack: () {
                Navigator.pop(context);
                YTIM().deleteOrExitGroup(_groupModel!.groupId.toString(), 0, (value) {
                  _update();
                });
              },
            );
          } else {
            YTUtils.showAlertDialogActionsHasTitle(
              context,
              IMLocalizations.of(context).currentLocalization.exitGroupConfirm,
              okCallBack: () {
                Navigator.pop(context);
                YTIM().deleteOrExitGroup(_groupModel!.groupId.toString(), 1, (value) {
                  _update();
                });
              },
            );
          }
        },
        title: userType == '1' || userType == '2'
            ? IMLocalizations.of(context).currentLocalization.imGroupDisbandBtn
            : IMLocalizations.of(context).currentLocalization.imGroupExitBtn,
      ),
    );
  }

  _update() {
    IMUtils.deleteGroup(context, _groupModel!.groupId.toString());
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  _buildMemberItem(IMUser user, double width) {
    return SizedBox(
      width: width,
      height: width + 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffe4e4e4),
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(width / 2)),
            ),
            child: IMCustomCircleAvatar(
              decoration: false,
              type: IMAvatarType.user,
              avatarUrl: user.avatar,
              size: width,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: width,
            child: Text(
              textAlign: TextAlign.center,
              user.nickname ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 0是管理群好友 1是添加群好友
  _buildOtherMemberItem(double width, int type) {
    return GestureDetector(
      child: SizedBox(
        width: width,
        height: width,
        child: Column(
          children: [
            Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                  color: grey02Color,
                  borderRadius: BorderRadius.all(Radius.circular(width / 2))),
              child: type == 0
                  ? Center(
                      child: SvgPicture.asset(
                      'assets/svg/ic_jh.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        greyColor,
                        BlendMode.srcIn,
                      ),
                    ))
                  : const Icon(
                      Icons.add,
                      size: 30,
                      color: greyColor,
                    ),
            ),
          ],
        ),
      ),
      onTap: () {
        if (type == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return GroupFriendListPage(
              type: GroupFriendListType.delete,
              groupId: widget.group.groupId,
              users: _selectedUsers,
            );
          })).then((value) {
            if (value != null) {
              setState(() {
                _groupModel = value;
                _selectedUsers = _groupModel?.userList ?? [];
              });
            }
          });
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return GroupFriendListPage(
              type: GroupFriendListType.add,
              groupId: widget.group.groupId,
              users: _selectedUsers,
            );
          })).then((value) {
            if (value != null) {
              setState(() {
                _groupModel = value;
                _selectedUsers = _groupModel?.userList ?? [];
              });
            }
          });
        }
      },
    );
  }
}
