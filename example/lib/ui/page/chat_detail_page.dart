import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/set_nick_name.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

//聊天详情页面，删除好友，设置备注
class ChatDetailPage extends StatefulWidget {
  final IMChatModel chatModel;
  const ChatDetailPage({
    super.key,
    required this.chatModel,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  IMUser? _user;
  @override
  void initState() {
    super.initState();
    YTIM().getUserInfoByUserId(widget.chatModel.userId!, (value) {
      setState(() {
        _user = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(IMLocalizations.of(context).currentLocalization.detail)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: Center(
              child: SizedBox(
                width: YTUtils.iPadSize(constraints),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        border: Border(
                          bottom: BorderSide(
                              width: 1.0, color: sepColor.withOpacity(0.6)),
                        ),
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            child: CachedNetworkImage(
                              imageUrl: widget.chatModel.userInfo?.avatar ?? '',
                              placeholder: (context, url) =>
                                  Icon(Icons.person,size: 30,),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.person,size: 30,),
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _user != null ? _user!.username! : '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Offstage(
                                      offstage: widget.chatModel.userInfo
                                                      ?.sex ==
                                                  null ||
                                              widget.chatModel.userInfo?.sex ==
                                                  0
                                          ? true
                                          : false,
                                      child: SvgPicture.asset(
                                        widget.chatModel.userInfo?.sex == 1
                                            ? 'assets/svg/ic_man.svg'
                                            : 'assets/svg/ic_woman.svg',
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _user?.nickname == '' ||
                                          _user?.nickname == null
                                      ? ''
                                      : '${IMLocalizations.of(context).currentLocalization.notes}: ${_user?.nickname ?? ''}',
                                  style: const TextStyle(color: darkColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        height: 60,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                            top: BorderSide(
                                width: 1.0, color: sepColor.withOpacity(0.6)),
                            bottom: BorderSide(
                                width: 1.0, color: sepColor.withOpacity(0.6)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${IMLocalizations.of(context).currentLocalization.settings}${IMLocalizations.of(context).currentLocalization.notes}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _user?.nickname ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: darkColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 16,
                                  color: grey01Color,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        /// 设置备注
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                          return SetNickNamePage(
                            userId: widget.chatModel.userId!,
                            nickname: _user?.nickname,
                          );
                        })).then((value) {
                          setState(() {
                            if (value != '') {
                              widget.chatModel.userInfo?.nickname = value;
                              _user?.nickname = value;
                            } else {
                              _user?.nickname = '';
                              widget.chatModel.userInfo?.nickname =
                                  _user?.username;
                            }
                          });
                        });
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        height: 60,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          border: Border(
                            top: BorderSide(
                                width: 1.0, color: sepColor.withOpacity(0.6)),
                            bottom: BorderSide(
                                width: 1.0, color: sepColor.withOpacity(0.6)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            IMLocalizations.of(context).currentLocalization.remove,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        YTUtils.showAlertDialogActionsHasTitle(
                          context,
                          IMLocalizations.of(context).currentLocalization.deleteFirend,
                          okCallBack: () {
                            Navigator.pop(context);
                            _deleteFirend();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteFirend() {
    var user = widget.chatModel;
    YTIM().deleteFriend(context, user.userId.toString(), '1', (value) {
      IMUtils.deleteFriend(context, user.userId.toString());
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}
