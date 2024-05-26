import 'dart:async';
import 'dart:convert';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_user_list.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/chat_page.dart';
import 'package:flutter_ytim_example/ui/page/customer_service_chat_page.dart';
import 'package:flutter_ytim_example/ui/page/group_chat_page.dart';
import 'package:flutter_ytim_example/ui/view/chat_list_cell.dart';
import 'package:flutter_ytim_example/ui/view/im_refresh_header.dart';
import 'package:flutter_ytim_example/ui/widget/im_empty_view.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:provider/provider.dart';

//会话列表
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///初始刷新聊天信息
  _initData() {
    // 总列表数据
    YTIM().getIMTotalData(context, (value) {
      _refreshController.finishRefresh();
    }, (error) {
      _refreshController.finishRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Container(
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.topCenter,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  _buildBody() {
    List<IMChatModel> chats = context.watch<IMStore>().chats;
    return EasyRefresh(
      controller: _refreshController,
      refreshOnStartHeader: IMRefreshOnStartHeader(),
      onRefresh: () {
        _initData();
      },
      child: chats.isEmpty
          ? const IMEmptyView()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      if (chats.length > index) {

                        String? id = chats[index].chatType == ChatType.user ? chats[index].userId : chats[index].chatType == ChatType.groups ? chats[index].groupId : chats[index].storeId;

                        return _buildItem(chats[index],
                            lastInfo: IMUtils.getLastInfo(context,chats[index].chatType)[id],contextBackUp: context);
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
    );
  }

  _buildItem(
    IMChatModel item, {
    IMLastInfo? lastInfo,
    BuildContext? contextBackUp,
  }) {
    return GestureDetector(
      onTap: () {
        item.unreadMessageList = [];
        item.unreadMessageCount = 0;
        String? id = item.chatType == ChatType.user ? item.userId : item.chatType == ChatType.groups ? item.groupId : item.storeId;

        IMUtils.clearSingleChatUnreadCount(context, item.chatType, id!);

        if (item.chatType == ChatType.user) {
          //单人
          YTIM().currentChatUserId = item.userId!;
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return ChatPage(chatModel: item,chatType: item.chatType,);
          })).then((value) {
            YTIM().currentChatUserId = '';
            _setLastMsg();
          });
        } else if (item.chatType == ChatType.groups) {
          //群组
          YTIM().currentGroupId = item.groupId!;
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return GroupChatPage(group: item.gourp!,chatType: item.chatType,);
          })).then((value) {
            YTIM().currentGroupId = '';
            _setLastMsg();
          });
        } else if (item.chatType == ChatType.store) {
          //客服
          YTIM().currentStoreId = item.storeId!;
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return CustomerServiceChatPage(
              storeModel: item.store!,
              chatType: item.chatType,
            );
          })).then((value) {
            YTIM().currentStoreId = '';
            _setLastMsg();
          });
        }
      },
      child: _buildChatCell(
        item,
        lastInfo: lastInfo,
      ),
    );
  }

  _buildChatCell(IMChatModel item,
      {IMLastInfo? lastInfo}) {
    return ChatListCell(item, lastInfo: lastInfo);
  }

  _setLastMsg() {
    setState(() {
      IMUtils.setLastMessage(context);
    });
  }
}
