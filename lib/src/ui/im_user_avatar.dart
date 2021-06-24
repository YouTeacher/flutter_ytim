import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/bean/im_user.dart';

/// 自定义圆形头像，显示圆形网络图片或本地图片。
class IMUserAvatar extends StatelessWidget {
  final IMUser imUser;
  final double defaultAvatarSize = 40.0;
  final double? size;
  final EdgeInsetsGeometry? margin;

  /// 头像点击事件
  final Callback<IMUser>? onAvatarTap;

  const IMUserAvatar(
    this.imUser, {
    Key? key,
    this.size,
    this.margin,
    this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      margin: margin,
      width: size ?? defaultAvatarSize,
      height: size ?? defaultAvatarSize,
      child: ClipOval(
        child: imUser.headImg == null ||
                imUser.headImg == '' ||
                !imUser.headImg!.startsWith('http')
            ? Container(
                child: Center(
                  child: Text(
                    imUser.username?.substring(0, 1).toUpperCase() ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Image.network(
                imUser.headImg!,
                fit: BoxFit.cover,
              ),
      ),
    );
    return onAvatarTap == null
        ? child
        : GestureDetector(
            onTap: () {
              if (onAvatarTap != null) {
                onAvatarTap!(imUser);
              }
            },
            child: child,
          );
  }
}
