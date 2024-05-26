import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/chat_page.dart';
import 'package:flutter_ytim_example/ui/page/group_chat_page.dart';
import 'package:flutter_ytim_example/ui/view/search_view.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/ui/widget/im_empty_view.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

//im 总搜索页面
class ImSearchPage extends StatefulWidget {
  const ImSearchPage({super.key});

  @override
  State<ImSearchPage> createState() => _ImSearchPageState();
}

class _ImSearchPageState extends State<ImSearchPage> {
  List<IMGroup> _groups = [];
  List<IMUser> _friends = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(IMLocalizations.of(context).currentLocalization.imSearchPlh),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          List<Widget> widgets = [];
          widgets.add(Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchBarView(
                constraints: constraints,
                onSearchTap: (value) {
                  //筛选展示数据
                  searchName(value);
                },
              ),
              Expanded(
                child: _friends.isEmpty && _groups.isEmpty
                    ? const IMEmptyView()
                    : ListView.builder(
                        itemCount: _friends.length + _groups.length,
                        itemBuilder: (context, index) {
                          if (_groups.length > index) {
                            return GestureDetector(
                              child: IMGroupCell(
                                _groups[index],
                                isAddGroup: false,
                              ),
                              onTap: () {

                                IMUtils.clearSingleChatUnreadCount(context, ChatType.groups, _groups[index].groupId!);

                                YTIM().currentGroupId = _groups[index].groupId!;
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                  return GroupChatPage(
                                    group: _groups[index],
                                    chatType: ChatType.groups,
                                  );
                                })).then((value){
                                  YTIM().currentGroupId = '';
                                  _setLastMsg();
                                });
                              },
                            );
                          } else if (_friends.length >
                              (index - _groups.length)) {
                            return GestureDetector(
                              child: IMUserCell(
                                _friends[index - _groups.length],
                                isAddFriend: false,
                              ),
                              onTap: () {

                                IMUtils.clearSingleChatUnreadCount(context, ChatType.user, _friends[index - _groups.length].userId!);

                                YTIM().currentChatUserId =
                                    _friends[index - _groups.length].userId!;
                                IMChatModel chatModel = IMChatModel(
                                  chatType: ChatType.user,
                                    userId: _friends[index - _groups.length]
                                        .userId!,
                                    userInfo: _friends[index - _groups.length]);
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                  return ChatPage(
                                    chatModel: chatModel,
                                    chatType: ChatType.user,
                                  );
                                })).then((value) {
                                  YTIM().currentChatUserId = '';
                                  _setLastMsg();
                                });
                              },
                            );
                          }
                          return null;
                        },
                      ),
              ),
            ],
          ));

          return SafeArea(
            child: Center(
              child: Container(
                width: YTUtils.iPadSize(constraints),
                alignment: Alignment.topCenter,
                child: Stack(
                  children: widgets,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _setLastMsg() {
    setState(() {
      IMUtils.setLastMessage(context);
    });
  }

  void searchName(String searchStr) {
    if (searchStr == '') {
      if (mounted) {
        setState(() {
          _groups = [];
          _friends = [];
        });
      }
      return;
    }
    final groups = context.read<IMStore>().groups;
    final friends = context.read<IMStore>().firends;

    List<IMGroup> tempGroups = [];
    List<IMUser> tempFriends = [];
    for (int i = 0; i < groups.length; i++) {
      IMGroup group = groups[i];
      if ((group.name ?? '').contains(searchStr)) {
        tempGroups.add(group);
      }
    }

    for (int i = 0; i < friends.length; i++) {
      IMUser user = friends[i];
      if ((user.username ?? '').contains(searchStr) ||
          (user.nickname ?? '').contains(searchStr)) {
        tempFriends.add(user);
      }
    }

    if (mounted) {
      setState(() {
        _groups = tempGroups;
        _friends = tempFriends;
      });
    }
  }
}
