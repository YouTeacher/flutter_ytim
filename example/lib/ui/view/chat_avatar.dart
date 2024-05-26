import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/model/im_user.dart';

class ChatAvatar extends StatelessWidget {
  final IMUser user;
  final double? size;

  const ChatAvatar({super.key, required this.user, this.size});

  @override
  Widget build(BuildContext context) {
    return user.avatar == ''
        ? CustomCircleAvatar1Char(
            user.nickname ?? '',
            size: size,
          )
        : IMCustomCircleAvatar(
            avatarUrl: user.avatar,
            size: size,
            type: IMAvatarType.user,
          );
  }
}

enum IMAvatarType { groups, user, logo, ownerRegister }

/// 自定义圆形头像，显示圆形网络图片或本地图片。
class IMCustomCircleAvatar extends StatelessWidget {
  final double defaultAvatarSize = 40.0;
  final String? avatarUrl;
  final double? size;
  final EdgeInsetsGeometry? margin;
  final IMAvatarType type;
  final bool? decoration;

  const IMCustomCircleAvatar({
    super.key,
    this.avatarUrl,
    required this.type,
    this.decoration = true,
    this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    late Icon defaultAvatar;
    switch (type) {
      case IMAvatarType.logo:
        defaultAvatar = Icon(
          Icons.person,
          color: Colors.grey,
        );
        break;
      case IMAvatarType.groups:
        defaultAvatar = Icon(
          Icons.person,
          color: Colors.grey,
        );
        break;
      case IMAvatarType.user:
        defaultAvatar = Icon(
          Icons.person,
          color: Colors.grey,
        );
      case IMAvatarType.ownerRegister:
        defaultAvatar = Icon(
          Icons.person,
          color: Colors.grey,
        );
        break;
    }

    return Container(
      margin: margin,
      width: size ?? defaultAvatarSize,
      height: size ?? defaultAvatarSize,
      decoration: decoration!
          ? BoxDecoration(
              border: Border.all(
                color: const Color(0xffe4e4e4),
                width: 1,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(60)),
            )
          : const BoxDecoration(),
      child: ClipOval(
        child: avatarUrl == null || avatarUrl == ''
            ? type == IMAvatarType.ownerRegister
                ? Container(
                    color: const Color(0xffd9d9d9),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                      ),
                    ),
                  )
                : defaultAvatar
            : CachedNetworkImage(
                imageUrl: avatarUrl ?? '',
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    type == IMAvatarType.ownerRegister
                        ? Container(
                            color: const Color(0xffd9d9d9),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                              ),
                            ),
                          )
                        : defaultAvatar,
                fit: BoxFit.cover,
                width: size ?? defaultAvatarSize,
                height: size ?? defaultAvatarSize,
              ),
      ),
    );
  }
}

/// 自定义圆形头像，中间显示一个文字。
class CustomCircleAvatar1Char extends StatelessWidget {
  final double defaultAvatarSize = 40.0;
  final String? text;
  final double? size;
  final int? fontSize;
  final Color? bgColor;

  const CustomCircleAvatar1Char(this.text,
      {super.key, this.size, this.fontSize, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? defaultAvatarSize,
      width: size ?? defaultAvatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: bgColor ?? Theme.of(context).primaryColor,
      ),
      child: Center(
        child: Text(
          text?.substring(0, 1).toUpperCase() ?? '',
          style: TextStyle(
              color: Colors.white, fontSize: fontSize as double? ?? 22),
        ),
      ),
    );
  }
}
