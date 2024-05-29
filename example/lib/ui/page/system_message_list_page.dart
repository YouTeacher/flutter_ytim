import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_sys_msg.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/page/system_message_detail.dart';
import 'package:flutter_ytim_example/ui/view/chat_sys_msg_cell.dart';
import 'package:flutter_ytim_example/ui/widget/im_empty_view.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:provider/provider.dart';

//系统消息列表
class SystemMessageListPage extends StatefulWidget {
  const SystemMessageListPage({super.key});
  @override
  State<SystemMessageListPage> createState() => _SystemMessageListPageState();
}

class _SystemMessageListPageState extends State<SystemMessageListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<IMSysMessage> _sysMessage = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _sysMessage = context.watch<IMStore>().sysMessages;
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Container(
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _sysMessage.isNotEmpty
                        ? ListView.builder(
                            itemCount: _sysMessage.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                    return SystemMessageDetailPage(
                                        model: _sysMessage[index]);
                                  }));
                                },
                                child: ChatSysMessageCell(
                                  _sysMessage[index],
                                  onTap: () {
                                    _readSysMessageApi(
                                        _sysMessage[index].messageId!);
                                  },
                                ),
                              );
                            },
                          )
                        : const IMEmptyView(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _readSysMessageApi(String messageId) {
    print('aaaaaaaa');
    YTIM().setMessageRead(MessageTypeRead.sysMsg, messageId, (value) {
      IMUtils.removeSysMsgByMessageId(context, messageId);
    });
  }
}
