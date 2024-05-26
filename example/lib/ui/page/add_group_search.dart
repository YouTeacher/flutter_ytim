import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim_example/ui/view/search_view.dart';
import 'package:flutter_ytim_example/ui/view/user_cell.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';

//搜索群
class AddGroupSearchPage extends StatefulWidget {
  const AddGroupSearchPage({super.key});

  @override
  State<AddGroupSearchPage> createState() => _AddGroupSearchPageState();
}

class _AddGroupSearchPageState extends State<AddGroupSearchPage> {
  List<IMGroup> _items = [];
  bool isHasData = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(title: Text(IMLocalizations.of(context).currentLocalization.addGroup)),
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
                      YTIM().searchGroup(value, context, (value) {
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
                      });
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
                              return IMGroupCell(
                                _items[index],
                                isAddGroup: true,
                                onAddGroupTap: (value) {
                                  YTIM().addGroup(value.groupId ?? "", (value) {
                                    Map<String, dynamic> obj =
                                    json.decode(value);
                                    if (obj['code'] == 200) {
                                      //添加申请已发送
                                      if (mounted) {
                                        setState(() {
                                          _items[index].groupdStatus = 1;
                                        });
                                      }
                                    } else {
                                      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddGroupReqErrorTip,maskType:EasyLoadingMaskType.none);
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
