import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim_example/ui/page/firend_list_page.dart';
import 'package:flutter_ytim_example/ui/page/group_friend_list_page.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/widget/im_white_cell_button.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class IMUserCell extends StatelessWidget {
  final IMUser imUser;
  final bool isAddFriend;
  final FirendListType? type;
  final bool? isSelect; //是否选中
  /// 点击事件
  final void Function(bool)? onSelectTap;

  /// 添加好友
  final void Function(IMUser)? onAddFirendTap;

  const IMUserCell(
    this.imUser, {
    super.key,
    this.type,
    required this.isAddFriend,
    this.onAddFirendTap,
    this.isSelect,
    this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context,
                color: sepColor.withOpacity(0.7))),
        color: Colors.white,
      ),
      child: Row(
        children: [
          IMCustomCircleAvatar(
            type: IMAvatarType.user,
            avatarUrl: imUser.avatar,
            size: 40,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                imUser.nickname ?? imUser.username ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 添加好友
          if (isAddFriend &&
              (imUser.firendStatus == 0 || imUser.firendStatus == null))
            SizedBox(
              height: 30,
              width: 55,
              child: IMWhiteCellButton(
                  content: IMLocalizations.of(context).currentLocalization.imGroupAddFriendBtn,
                  onPressed: () {
                    if (onAddFirendTap != null) {
                      onAddFirendTap!(imUser);
                    }
                  }),
            ),
          if (isAddFriend && imUser.firendStatus == 1)
            Text(IMLocalizations.of(context).currentLocalization.imGroupFirendHaveApplied),

          // 群创建选择好友
          if (type == FirendListType.select)
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                height: 27,
                width: 27,
                child: isSelect == true
                    ? Image.asset('assets/image/ic_checkboxs.png')
                    : Image.asset('assets/image/ic_checkbox.png'),
              ),
              onTap: () {
                if (onSelectTap != null) {
                  onSelectTap!(!(isSelect ?? false));
                }
              },
            )
        ],
      ),
    );
    return child;
  }
}

// 通讯录群组cell
class IMGroupCell extends StatelessWidget {
  final IMGroup imGroup;
  final double defaultAvatarSize = 40.0;
  final bool? isAddGroup;

  /// 申请入群
  final void Function(IMGroup)? onAddGroupTap;

  const IMGroupCell(
    this.imGroup, {
    super.key,
    this.isAddGroup,
    this.onAddGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context,
                color: sepColor.withOpacity(0.7))),
        color: Colors.white,
      ),
      height: 65,
      child: Row(
        children: [
          IMCustomCircleAvatar(
            type: IMAvatarType.user,
            avatarUrl: imGroup.avatar,
            size: defaultAvatarSize,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                imGroup.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (isAddGroup! &&
              (imGroup.groupdStatus == 0 || imGroup.groupdStatus == null))
            SizedBox(
              height: 30,
              width: 55,
              child: IMWhiteCellButton(
                content: IMLocalizations.of(context).currentLocalization.imAddGroup,
                onPressed: () {
                  if (onAddGroupTap != null) {
                    onAddGroupTap!(imGroup);
                  }
                },
              ),
            ),
          if (isAddGroup! && imGroup.groupdStatus == 1)
            Text(IMLocalizations.of(context).currentLocalization.imGroupFirendHaveApplied),
        ],
      ),
    );
  }
}

class IMGroupUserCell extends StatelessWidget {
  final List<IMUser>? userList;
  final IMUser imUser;
  final GroupFriendListType? type;
  final bool isSelect; //是否选中
  final void Function(IMUser)? onAddTap;
  final void Function(IMUser)? onDeleteTap;

  const IMGroupUserCell(
    this.imUser, {
    super.key,
    this.userList,
    this.type,
    required this.isSelect,
    this.onAddTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context,
                color: sepColor.withOpacity(0.7))),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IMCustomCircleAvatar(
            type: IMAvatarType.user,
            avatarUrl: imUser.avatar,
            size: 40,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                imUser.nickname ?? imUser.username ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GestureDetector(
            child: _buildItem(),
            onTap: () {
              if (type == GroupFriendListType.add) {
                if (_isHasContains()) {
                  return;
                }
              }
              if (isSelect) {
                if (onDeleteTap != null) {
                  onDeleteTap!(imUser);
                }
              } else {
                if (onAddTap != null) {
                  onAddTap!(imUser);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  _isHasContains() {
    bool flag = false;
    if (userList != null) {
      for (var item in userList!) {
        if (item.userId == imUser.userId) {
          flag = true;
          break;
        }
      }
      return flag;
    }
    return flag;
  }

  _buildItem() {
    if (type == GroupFriendListType.add) {
      return Container(
        margin: const EdgeInsets.only(left: 5),
        height: 27,
        width: 27,
        child: _isHasContains()
            ? Image.asset(
                'assets/image/ic_checkboxs.png',
                color: themeColor.withOpacity(0.2),
              )
            : (isSelect
                ? Image.asset('assets/image/ic_checkboxs.png')
                : Image.asset('assets/image/ic_checkbox.png')),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 5),
      height: 27,
      width: 27,
      child: isSelect
          ? Image.asset('assets/image/ic_checkboxs.png')
          : Image.asset('assets/image/ic_checkbox.png'),
    );
  }
}
