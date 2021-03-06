import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/bean/im_store.dart';
import 'package:flutter_ytim/src/ui/im_user_list_page.dart';
import 'package:provider/provider.dart';

/// IM 联系人列表界面。
/// 使用 StatefulWidget 包裹一下，在界面切换时保持保持内部数据不丢失。
class IMContactsPage extends StatefulWidget {
  /// [SliverPersistentHeader] or [AppBar]
  final Widget header;
  final String? order;

  const IMContactsPage({
    Key? key,
    required this.header,
    this.order,
  }) : super(key: key);

  @override
  _IMContactsPageState createState() => _IMContactsPageState();
}

class _IMContactsPageState extends State<IMContactsPage>
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
      child: IMUserListPage(header: widget.header, order: widget.order),
    );
  }
}
