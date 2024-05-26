import 'package:flutter/material.dart';
import 'package:flutter_ytim/src/model/im_sys_msg.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/widget/gen_button.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

// 历史会话列表 系统消息cell
class ChatSysMessageCell extends StatelessWidget {
  final IMSysMessage imSysMessage;
  final void Function()? onTap;

  const ChatSysMessageCell(
    this.imSysMessage, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: Divider.createBorderSide(context,
                color: sepColor.withOpacity(0.7))),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IMCustomCircleAvatar(
            type: IMAvatarType.logo,
            margin: EdgeInsets.only(right: 10),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imSysMessage.fromName ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  imSysMessage.content ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            height: 30,
            width: 70,
            child: GenButton(
              text: IMLocalizations.of(context).currentLocalization.imMessageIgnore,
              borderColor: grey02Color,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              textColor: darkColor,
              onBackPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
