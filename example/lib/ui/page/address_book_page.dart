import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/chat_page.dart';
import 'package:flutter_ytim_example/ui/page/group_chat_page.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/ui/widget/im_empty_view.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

//好友列表
class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<IMGroup> _groups = [];
  List<IMUser> _friends = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _groups = context.watch<IMStore>().groups;
    _friends = context.watch<IMStore>().firends;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.topCenter,
              child: _friends.isEmpty && _groups.isEmpty
                  ? const IMEmptyView()
                  : CustomScrollView(
                      slivers: [
                        _friends.isNotEmpty
                            ? _buildTitle(IMLocalizations.of(context).currentLocalization.friend)
                            : SliverToBoxAdapter(child: Container()),
                        _friends.isNotEmpty
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return GestureDetector(
                                      child: IMUserCell(
                                        _friends[index],
                                        isAddFriend: false,
                                      ),
                                      onTap: (){

                                        IMUtils.clearSingleChatUnreadCount(context, ChatType.user, _friends[index].userId!);

                                        YTIM().currentChatUserId =
                                            _friends[index].userId!;
                                        IMChatModel chatModel = IMChatModel(
                                          chatType: ChatType.user,
                                          userId: _friends[index].userId!,
                                          userInfo: _friends[index],
                                        );
                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                          return ChatPage(chatModel: chatModel,chatType: ChatType.user,);
                                        })).then((value) {
                                          YTIM().currentChatUserId = '';
                                            _setLastMsg();
                                        });
                                      },
                                    );
                                  },
                                  childCount: _friends.length,
                                ),
                              )
                            : SliverToBoxAdapter(child: Container()),
                        _groups.isNotEmpty
                            ? _buildTitle(IMLocalizations.of(context).currentLocalization.imTabGroupsTitle)
                            : SliverToBoxAdapter(child: Container()),
                        _groups.isNotEmpty
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return GestureDetector(
                                      child: IMGroupCell(
                                        _groups[index],
                                        isAddGroup: false,
                                      ),
                                      onTap: () {

                                        IMUtils.clearSingleChatUnreadCount(context, ChatType.groups, _groups[index].groupId!);

                                        YTIM().currentGroupId =
                                            _groups[index].groupId!;
                                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                          return GroupChatPage(
                                              group: _groups[index],chatType: ChatType.groups,);
                                        })).then((value) {
                                          YTIM().currentGroupId = '';
                                          _setLastMsg();
                                        });
                                      },
                                    );
                                  },
                                  childCount: _groups.length,
                                ),
                              )
                            : SliverToBoxAdapter(child: Container()),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  _buildTitle(String title) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: grey02Color.withOpacity(0.3),
            padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(color: blackColor),
            ),
          );
        },
        childCount: 1,
      ),
    );
  }

  _setLastMsg() {
    setState(() {
      IMUtils.setLastMessage(context);
    });
  }
}
