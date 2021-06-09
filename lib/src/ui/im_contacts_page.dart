import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/bean/im_store.dart';
import 'package:flutter_ytim/src/ui/im_user_list_page.dart';
import 'package:provider/provider.dart';

/// IM 联系人列表界面。
/// 使用 StatefulWidget 包裹一下，在界面切换时保持保持内部数据不丢失。
class IMContactsPage extends StatefulWidget {
  /// header: 头布局 [SliverPersistentHeader] or [AppBar] or 其他类型组件
  final Widget? header;
  final String? order;
  final double? widthInPad;

  const IMContactsPage({
    Key? key,
    this.header,
    this.order,
    this.widthInPad,
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
      child: Scaffold(
        appBar: widget.header is AppBar ? widget.header as AppBar : null,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            Widget child = IMUserListPage(
              header: widget.header,
              order: widget.order,
              widthInPad: widget.widthInPad,
            );
            if (constraints.maxWidth > 600) {
              if (widget.widthInPad == null) {
                return child;
              } else {
                return Center(
                  child: Container(
                    color: Colors.white,
                    width: widget.widthInPad,
                    child: child,
                  ),
                );
              }
            } else {
              return child;
            }
          },
        ),
      ),
    );
  }
}
