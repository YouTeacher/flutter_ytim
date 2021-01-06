import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/ui/im_user_list_page.dart';
import 'package:provider/provider.dart';

class ContactsPage extends StatefulWidget {
  final bool showAppBar;

  const ContactsPage({Key key, this.showAppBar = false}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 提取到成员变量，以保存状态。
  IMStore store = IMStore({});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: store,
      child: IMUserListPage(showAppBar: widget.showAppBar),
    );
  }
}
