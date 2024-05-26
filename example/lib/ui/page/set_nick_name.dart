import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim_example/ui/widget/gen_button.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_textfield.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

///设置备注
class SetNickNamePage extends StatefulWidget {
  final String userId;
  final String? nickname;
  const SetNickNamePage({super.key, this.nickname, required this.userId});

  @override
  State<SetNickNamePage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<SetNickNamePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.nickname ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        Navigator.pop(context, _nameController.text);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
                title: Text(IMLocalizations.of(context).currentLocalization.settings + IMLocalizations.of(context).currentLocalization.notes)),
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: YTUtils.iPadSize(constraints),
                  child: _buildBody(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _buildBody() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: IMCustomTextField(
            labelText: IMLocalizations.of(context).currentLocalization.notes,
            // 输入框标题
            placeholderText: IMLocalizations.of(context).currentLocalization.inputNote,
            textController: _nameController,
            keyboardType: TextInputType.name,
            mandatory: false,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: GenButton(
            borderColor: themeColor,
            bgColor: themeColor,
            textColor: Colors.white,
            fontSize: 18,
            borderRadius: 40,
            text: IMLocalizations.of(context).currentLocalization.save,
            onBackPressed: () {
              YTUtils.hideKeyboard(context);
              YTIM().setFriendNickName(widget.userId, _nameController.text, (value) {
                Navigator.pop(context, _nameController.text);
              });
            },
          ),
        ),
      ],
    );
  }
}
