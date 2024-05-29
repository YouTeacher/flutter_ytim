//IM通知详细页面
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_sys_msg.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/chat_page.dart';
import 'package:flutter_ytim_example/ui/page/group_chat_page.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_textfield.dart';
import 'package:flutter_ytim_example/ui/widget/im_red_button.dart';
import 'package:flutter_ytim_example/ui/widget/im_white_button.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

class SystemMessageDetailPage extends StatefulWidget {
  static const String routeName = '/SystemMessageDetailPage';
  final IMSysMessage? model;
  const SystemMessageDetailPage({super.key, this.model});

  @override
  State<SystemMessageDetailPage> createState() =>
      SystemMessageDetailPageState();
}

class SystemMessageDetailPageState extends State<SystemMessageDetailPage> {
  final TextEditingController _nickNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 不需要操作的消息进来后设置为已读，并删除
    if (widget.model?.type != "10" && widget.model?.type != "20") {
      _readSysMessageApi();
    }
  }

  _readSysMessageApi() {
    YTIM().setMessageRead(MessageTypeRead.sysMsg, widget.model!.messageId!, (value) {
      _updateMessage();
    });
  }

  _updateMessage() {
    final list = context.read<IMStore>().sysMessages;
    list.removeWhere((model) => (model.messageId == widget.model!.messageId));
    context.read<IMStore>().updateSysMessages(list);
  }

  @override
  void dispose() {
    super.dispose();
    _nickNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      Widget view = Container();
      if (widget.model?.type == "10") {
        view = _addFirendView(context, YTUtils.iPadSize(constraints));
      } else if (widget.model?.type == "20") {
        view = _addGroupView(context, YTUtils.iPadSize(constraints));
      } else {
        view = _addContentView(context);
      }
      return Scaffold(
        appBar: AppBar(
          title: Text( IMLocalizations.of(context).currentLocalization.imSysNotificationsTitle),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(0),
              width: YTUtils.iPadSize(constraints),
              child: view,
            ),
          ),
        ),
      );
    });
  }

  _addFirendView(BuildContext context, double totalWidth) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Text(
            widget.model?.content ?? "",
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30, left: 20, right: 20),
          child: IMCustomTextField(
            labelText: IMLocalizations.of(context).currentLocalization.imFriendRemarksName,
            placeholderText: IMLocalizations.of(context).currentLocalization.imFriendRemarksNamePlh,
            textController: _nickNameController,
            keyboardType: TextInputType.name,
            mandatory: false,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          width: totalWidth - 40,
          child: IMRedButton(
            onPressed: () {
              YTUtils.hideKeyboard(context);
              if (widget.model?.from != null) {
                YTIM().operationFriendRequest(widget.model!.from!, 1, (value) {
                  Map<String, dynamic> obj = json.decode(value);
                  if (obj['code'] == 200) {
                    IMSysMessage sysModel = IMSysMessage.fromJson(obj['data']);
                    // 更新好友
                    if (_nickNameController.text.isNotEmpty) {
                      sysModel.fromName = _nickNameController.text;
                    }
                    IMUtils.addFriend(context, sysModel);
                  }

                  // 设置消息已读
                  _readSysMessageApi();

                  YTIM().currentChatUserId = widget.model?.from ?? "";
                  //添加成功 进入会话页面
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                    return ChatPage(
                      chatType: ChatType.user,
                      chatModel: IMChatModel(
                        userId: widget.model?.from,
                        userInfo: IMUser(
                          userId: widget.model?.from,
                          nickname: _nickNameController.text.isNotEmpty
                              ? _nickNameController.text
                              : (widget.model?.fromName ?? ""),
                        ), chatType: ChatType.user,
                      ),
                    );
                  })).then((value){
                    YTIM().currentChatUserId = "";
                  });
                }, (error) {
                  //添加失败
                  EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddFriendReqError);
                },nickName: _nickNameController.text);
              }
            },
            content: IMLocalizations.of(context).currentLocalization.addFriend,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          width: totalWidth - 40,
          child: IMWhiteButton(
            content: IMLocalizations.of(context).currentLocalization.imRejectAddFriendBtn,
            onPressed: () {
              YTUtils.hideKeyboard(context);
              if (widget.model?.from != null) {
                YTIM().operationFriendRequest(widget.model!.from!, 0, (value) {
                  // 设置消息已读
                  _readSysMessageApi();
                  Navigator.pop(context);
                }, (error) {
                  EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imRejectAddFriendReqError);
                });
              }
            },
          ),
        )
      ],
    );
  }

  _addGroupView(BuildContext context, double totalWidth) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Text(
            widget.model?.content ?? "",
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          width: totalWidth - 40,
          child: IMRedButton(
            onPressed: () {
              YTUtils.hideKeyboard(context);
              if (widget.model?.from != null) {
                YTIM().operationGroupRequest(widget.model?.groupId ?? "", widget.model?.messageId ?? "", 1, (value) {
                  YTIM().currentGroupId = widget.model?.groupId ?? "";

                  // 设置消息已读
                  _readSysMessageApi();

                  //添加成功 进入会话页面
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                    return GroupChatPage(
                      group: IMGroup(groupId: widget.model?.groupId ?? ""),
                      chatType: ChatType.groups,
                    );
                  })).then((value) {
                    YTIM().currentGroupId = "";
                  });
                }, (error) {
                  //添加失败
                  EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddGroupReqError);
                });
              }
            },
            content: IMLocalizations.of(context).currentLocalization.imAddGroupBtn,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          width: totalWidth - 40,
          child: IMWhiteButton(
            onPressed: () {
              YTUtils.hideKeyboard(context);
              if (widget.model?.from != null) {
                YTIM().operationGroupRequest(widget.model?.groupId ?? "", widget.model?.messageId ?? "", 0, (value) {
                  // 设置消息已读
                  _readSysMessageApi();
                  Navigator.pop(context);
                }, (error) {
                  //添加失败
                  EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imRejectAddGroupReqError);
                });
              }
            },
            content: IMLocalizations.of(context).currentLocalization.imRejectAddGroupBtn,
          ),
        )
      ],
    );
  }

  _addContentView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Text(
        widget.model?.content ?? "",
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
