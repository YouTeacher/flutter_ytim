import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';
import 'package:flutter_ytim_example/ui/page/firend_list_page.dart';
import 'package:flutter_ytim_example/ui/page/group_chat_page.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_botton_bar.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_textfield.dart';
import 'package:flutter_ytim_example/ui/widget/im_field_lable.dart';
import 'package:flutter_ytim_example/utils/im_show_imagepicker.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/response_body.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/utils/ythttp.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:provider/provider.dart';

//创建群组
class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final String _tag = '_GroupCreatePage';

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDesController = TextEditingController();

  File? _groupImage;
  List<IMUser> _selectedUsers = [];
  String? avatarUrl;

  //每个个数宽度
  double itemWidth = 44;

  //显示个数
  int gridCount = 5;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    EdgeInsets safePadding = MediaQuery.of(context).padding;

    // 计算不包括安全区域的可用高度
    double availableHeight =
        screenHeight - safePadding.top - safePadding.bottom - kToolbarHeight;
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = (YTUtils.iPadSize(constraints) - 80) / 5;
        return Scaffold(
          appBar: AppBar(
            title: Text(
                IMLocalizations.of(context).currentLocalization.addGroupTitle),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                width: YTUtils.iPadSize(constraints),
                height: availableHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IMCustomTextField(
                      labelText: IMLocalizations.of(context)
                          .currentLocalization
                          .groupNameTitel,
                      placeholderText: IMLocalizations.of(context)
                          .currentLocalization
                          .groupNamePlh,
                      textController: _groupNameController,
                      keyboardType: TextInputType.name,
                      mandatory: false,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: IMFieldTitleLabel(
                        text: IMLocalizations.of(context)
                            .currentLocalization
                            .groupDesTitle,
                        mandatory: false,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10, left: 0, right: 0, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: grey02Color,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _groupDesController,
                        maxLines: 4,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(500)
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: InputBorder.none,
                          hintText: IMLocalizations.of(context)
                              .currentLocalization
                              .groupDesPlh,
                        ),
                      ),
                    ),
                    Text(
                      IMLocalizations.of(context)
                          .currentLocalization
                          .groupHeaderImg,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        YTUtils.hideKeyboard(context);
                        _showImagePickerModal(context);
                      },
                      child: _groupImage != null
                          ? CircleAvatar(
                              radius: width / 2,
                              backgroundImage: FileImage(_groupImage!),
                            )
                          : CircleAvatar(
                              radius: width / 2,
                              backgroundColor: grey02Color,
                              child: const Icon(
                                Icons.camera_alt,
                                color: greyColor,
                              ),
                            ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            IMLocalizations.of(context)
                                .currentLocalization
                                .groupUsers,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: width / (width + 30),
                        ),
                        itemCount: _selectedUsers.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _selectedUsers.length) {
                            // 最后一项是添加的图标
                            return _buildAddMemberItem(width);
                          } else {
                            // 其他项是已选择的成员
                            return _buildMemberItem(
                                _selectedUsers[index], width);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: IMCustomBottomNavigationBar(
            onTap: () {
              _handleCreateGroup();
            },
            title: IMLocalizations.of(context).currentLocalization.ok,
          ),
        );
      },
    );
  }

  _buildMemberItem(IMUser user, double width) {
    return SizedBox(
      width: width,
      height: width + 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffe4e4e4),
                width: 1,
              ),
              borderRadius: BorderRadius.all(Radius.circular(width / 2)),
            ),
            child: IMCustomCircleAvatar(
              decoration: false,
              type: IMAvatarType.user,
              avatarUrl: user.avatar,
              size: width,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: width,
            child: Text(
              textAlign: TextAlign.center,
              user.nickname ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  _buildAddMemberItem(double width) {
    return GestureDetector(
      child: SizedBox(
          width: width,
          height: width,
          child: Column(
            children: [
              CircleAvatar(
                radius: width / 2,
                backgroundColor: grey02Color,
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: greyColor,
                ),
              ),
            ],
          )),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return FriendListPage(
            type: FirendListType.select,
            users: _selectedUsers,
          );
        })).then((value) {
          if (mounted) {
            setState(() {
              if (value != null) {
                _selectedUsers = value;
              }
            });
          }
        });
      },
    );
  }

  _showImagePickerModal(BuildContext context) {
    IMShowImagePicker.imShowImagePickerModal(
      context,
      onPressedCamera: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          // 选择成功，可以在这里处理选择的图片
          // pickedFile.path 包含了选择的图片的本地路径
          // 例如：pickedFile.path
          final croppedFile = await ImageCropper().cropImage(
              sourcePath: pickedFile.path, // 选择的图像路径
              aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 裁剪比例
              compressQuality: 100, // 压缩质量（0-100）
              uiSettings: [
                // 裁剪后的最大高度
                AndroidUiSettings(
                  toolbarColor: Colors.blue, // Android裁剪工具栏颜色
                  toolbarWidgetColor: Colors.white, // Android裁剪工具栏图标颜色
                ),
              ]);

          if (croppedFile != null) {
            File selectedImage = File(croppedFile.path);
            img.Image? originalImage =
                img.decodeImage(selectedImage.readAsBytesSync());
            img.Image resizedImage =
                img.copyResize(originalImage!, width: 300, height: 300);
            List<int> resizedBytes = img.encodePng(resizedImage);
            File croppedImage =
                File(selectedImage.path.replaceAll('.png', '_cropped.png'));
            await croppedImage.writeAsBytes(resizedBytes);
            if (mounted) {
              setState(() {
                _groupImage = croppedImage;
                _uploadImageAction();
              });
            }
          }
        }
      },
      onPressedPhoto: () {
        Navigator.pop(context);
        _pickImage(ImageSource.gallery);
      },
    );
  }

  //相机图片处理
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // 选择成功，可以在这里处理选择的图片
      // pickedFile.path 包含了选择的图片的本地路径
      // 例如：pickedFile.path
      final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path, // 选择的图像路径
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 裁剪比例
          compressQuality: 100, // 压缩质量（0-100）
          uiSettings: [
            // 裁剪后的最大高度
            AndroidUiSettings(
              toolbarColor: Colors.blue, // Android裁剪工具栏颜色
              toolbarWidgetColor: Colors.white, // Android裁剪工具栏图标颜色
            ),
          ]);

      if (croppedFile != null) {
        File selectedImage = File(croppedFile.path);
        img.Image? originalImage =
            img.decodeImage(selectedImage.readAsBytesSync());
        img.Image resizedImage =
            img.copyResize(originalImage!, width: 300, height: 300);
        List<int> resizedBytes = img.encodePng(resizedImage);
        File croppedImage =
            File(selectedImage.path.replaceAll('.png', '_cropped.png'));
        await croppedImage.writeAsBytes(resizedBytes);
        if (mounted) {
          setState(() {
            _groupImage = croppedImage;
            _uploadImageAction();
          });
        }
      }
    }
  }

  //上传图片
  _uploadImageAction() async {
    try {
      YTUtils.hideKeyboard(context);
      EasyLoading.show();
      ResponseData response = await YTHttp.uploadImage('/api/basis/uploadAvatar', _groupImage!.path);
      EasyLoading.dismiss();
      if (response.code == 200) {
        if (mounted) {
          avatarUrl = response.data?["url"].toString();
        } else {
          EasyLoading.showToast(response.message,
              maskType: EasyLoadingMaskType.none);
        }
      }
    } catch (e) {
      YTLog.d(_tag, "$e");
      EasyLoading.dismiss();
    }
  }

  _handleCreateGroup() {
    if (_groupNameController.text == "") {
      EasyLoading.showToast(
          IMLocalizations.of(context).currentLocalization.imAddGroupNameNilTip,
          maskType: EasyLoadingMaskType.none);
      return;
    }
    if (_groupDesController.text == "") {
      EasyLoading.showToast(
          IMLocalizations.of(context).currentLocalization.imAddGroupDesNilTip,
          maskType: EasyLoadingMaskType.none);
      return;
    }

    if (avatarUrl == null) {
      EasyLoading.showToast(
          IMLocalizations.of(context)
              .currentLocalization
              .imAddGroupAvatarNilTip,
          maskType: EasyLoadingMaskType.none);
      return;
    }

    EasyLoading.show();
    YTIM().createGroup(_groupNameController.text, avatarUrl ?? "", (data) {
      EasyLoading.dismiss();
      List<String> userIds = [];
      for (IMUser user in _selectedUsers) {
        userIds.add(user.userId!);
      }
      YTIM().groupUsersOperations(data.groupId!, userIds, 0, (value) {

        Map<String, dynamic> groupAddUserObj = json.decode(value);
        if (groupAddUserObj['code'] == 200) {

          //读取群组详细信息
          YTIM().getGroupInfo(context, data.groupId!, 1, (value) {

            YTIM().currentGroupId = value.groupId ?? "";
            //添加成功 进入会话页面
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return GroupChatPage(
                    group: value,
                    chatType: ChatType.groups,
                  );
                })).then((value) {
              YTIM().currentGroupId = "";
            });
          });
        }
      });
    }, (error) {
      EasyLoading.dismiss();
      YTLog.d(_tag, "$error");
    },desc:_groupDesController.text);
  }
}
