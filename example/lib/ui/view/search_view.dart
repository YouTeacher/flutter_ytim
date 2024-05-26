import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_textfield.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

class SearchBarView extends StatefulWidget {
  /// 头像点击事件
  final void Function(String) onSearchTap;
  final BoxConstraints constraints;
  const SearchBarView(
      {required this.onSearchTap, super.key, required this.constraints});

  @override
  State<SearchBarView> createState() => _SearchBarViewState();
}

class _SearchBarViewState extends State<SearchBarView> {
  TextEditingController textEditingController = TextEditingController();

  bool enabled = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: YTUtils.iPadSize(widget.constraints) - 70 - 32 - 10,
            child: IMCustomTextField(
              bgColor: Colors.white,
              labelText: IMLocalizations.of(context).currentLocalization.customerAddress,
              placeholderText: IMLocalizations.of(context).currentLocalization.imSearchPlh,
              mandatory: false,
              hasTitleLabel: false,
              keyboardType: TextInputType.text,
              textController: _searchController,
              maxLines: 1,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 15, right: 8),
                child: Icon(
                  Icons.search,
                  color: darkColor,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    enabled = true;
                  } else {
                    enabled = false;
                  }
                });
              },
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(top: 7, left: 10),
              width: 70,
              height: 36,
              decoration: BoxDecoration(
                  color: enabled ? themeColor : const Color(0xff838383),
                  borderRadius: const BorderRadius.all(Radius.circular(4))),
              child: Center(
                child: Text(
                  IMLocalizations.of(context).currentLocalization.addressSearch,
                  style: const TextStyle(color: whiteColor),
                ),
              ),
            ),
            onTap: () {
              YTUtils.hideKeyboard(context);
              if (enabled) {
                widget.onSearchTap(_searchController.text);
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }
}
