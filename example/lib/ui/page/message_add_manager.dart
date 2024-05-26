import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/add_friend_search.dart';
import 'package:flutter_ytim_example/ui/page/add_group_search.dart';
import 'package:flutter_ytim_example/ui/page/group_create_page.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

//新增管理 好友 群组 公开
class MessageAddManagerPage extends StatefulWidget {
  const MessageAddManagerPage({super.key});

  @override
  State<MessageAddManagerPage> createState() => _MessageAddManagerPageState();
}

class _MessageAddManagerPageState extends State<MessageAddManagerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(IMLocalizations.of(context).currentLocalization.settings)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const Divider(),
                        ListTile(
                          title: Text(IMLocalizations.of(context).currentLocalization.addFriend),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                            return const AddFriendSearchPage();
                          })),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(IMLocalizations.of(context).currentLocalization.addGroup),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                            return const AddGroupSearchPage();
                          }))
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(IMLocalizations.of(context).currentLocalization.addGroupTitle),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                            return const GroupCreatePage();
                          }))
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
