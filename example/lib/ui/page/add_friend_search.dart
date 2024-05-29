import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim_example/ui/view/search_view.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';

//搜索添加好友
class AddFriendSearchPage extends StatefulWidget {
  const AddFriendSearchPage({super.key});

  @override
  State<AddFriendSearchPage> createState() => _AddFriendSearchPageState();
}

class _AddFriendSearchPageState extends State<AddFriendSearchPage> {
  List<IMUser> _items = [];
  bool isHasData = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text(IMLocalizations.of(context).currentLocalization.addFriend)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: YTUtils.iPadSize(constraints),
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchBarView(
                    constraints: constraints,
                    onSearchTap: (value) {
                      YTIM().searchFriend(value, context,(value) {
                          if (mounted) {
                            setState(() {
                              _items = value;
                              if (_items.isNotEmpty) {
                                isHasData = true;
                              } else {
                                isHasData = false;
                              }
                            });
                          }
                        }
                      );
                    },
                  ),
                  _items.isEmpty
                      ? (isHasData
                          ? Container()
                          : Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height / 3),
                                child: Text(IMLocalizations.of(context).currentLocalization.noData),
                              ),
                            ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return IMUserCell(
                                _items[index],
                                isAddFriend: true,
                                onAddFirendTap: (value) {
                                  YTIM().addFriend(value.userId ?? "", (value) {
                                    Map<String, dynamic> obj =
                                    json.decode(value);
                                    if (obj['code'] == 200) {
                                      //添加申请已发送
                                      if (mounted) {
                                        setState(() {
                                          _items[index].firendStatus = 1;
                                        });
                                      }
                                    } else {
                                      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddFirendReqErrorTip, maskType: EasyLoadingMaskType.none);
                                    }
                                  });
                                },
                              );
                            },
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
}
