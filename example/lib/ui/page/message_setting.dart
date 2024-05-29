import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/ui/page/firend_list_page.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

//消息设置页面
class MessageSettingsPage extends StatefulWidget {
  const MessageSettingsPage({super.key});

  @override
  State<MessageSettingsPage> createState() => _MessageSettingsPageState();
}

class _MessageSettingsPageState extends State<MessageSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(IMLocalizations.of(context).currentLocalization.settings),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          List<Widget> widgets = [];
          widgets.add(SizedBox(
            width: YTUtils.iPadSize(constraints),
            child: Center(
                child: Container(
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 30),
                      children: [
                        const Divider(),
                        ListTile(
                          title: Text(IMLocalizations.of(context).currentLocalization.friendManager),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                              return const FriendListPage(
                                type: FirendListType.manager,
                              );
                            }));
                          },
                        ),
                        const Divider(),
                        // ListTile(
                        //   title: Text("投稿公開範囲設定"),
                        //   trailing: const Icon(Icons.keyboard_arrow_right),
                        // ),
                        // const Divider(),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ));

          return SafeArea(
            child: Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
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

  @override
  void dispose() {
    super.dispose();
  }
}
