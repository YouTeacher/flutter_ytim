import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_chat_model.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/utils/im_store.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim_example/ui/view/chat_avatar.dart';
import 'package:flutter_ytim_example/ui/widget/im_custom_textfield.dart';
import 'package:flutter_ytim_example/ui/widget/im_field_lable.dart';
import 'package:flutter_ytim_example/utils/im_event_bus.dart';
import 'package:flutter_ytim_example/utils/im_show_imagepicker.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/response_body.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/utils/ythttp.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//编辑群组
class GroupsEditPage extends StatefulWidget {
  final IMGroup group;
  const GroupsEditPage({super.key, required this.group});

  @override
  State<GroupsEditPage> createState() => _GroupsEditPageState();
}

class _GroupsEditPageState extends State<GroupsEditPage> {
  final String _tag = '_GroupsEditPage';

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDesController = TextEditingController();
  IMGroup? group;
  File? _groupImage;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    group = widget.group;
    _groupNameController.text = group?.name ?? '';
    _groupDesController.text = group?.desc ?? '';
    avatarUrl = group?.avatar ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = (YTUtils.iPadSize(constraints) - 80) / 5;
        return Scaffold(
          appBar: AppBar(
            title: Text(IMLocalizations.of(context).currentLocalization.editGroupTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: IconButton(
                  onPressed: () {
                    _handleEditGroup();
                  },
                  icon: const Icon(
                    Icons.save,
                    color: darkColor,
                    size: 27,
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(15),
                width: YTUtils.iPadSize(constraints),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IMCustomTextField(
                      labelText: IMLocalizations.of(context).currentLocalization.groupNameTitel,
                      placeholderText: IMLocalizations.of(context).currentLocalization.groupNamePlh,
                      textController: _groupNameController,
                      keyboardType: TextInputType.name,
                      mandatory: false,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: IMFieldTitleLabel(
                        text: IMLocalizations.of(context).currentLocalization.groupDesTitle,
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
                          hintText: IMLocalizations.of(context).currentLocalization.groupDesPlh,
                        ),
                      ),
                    ),
                    Text(
                      IMLocalizations.of(context).currentLocalization.groupHeaderImg,
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
                          : IMCustomCircleAvatar(
                              type: IMAvatarType.user,
                              avatarUrl: avatarUrl,
                              size: width,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _showImagePickerModal(BuildContext context) {
    IMShowImagePicker.imShowImagePickerModal(
      context,
      onPressedCamera: () async{
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
      ResponseData response = await YTHttp.uploadImage(
          '/api/basis/uploadAvatar', _groupImage!.path);
      EasyLoading.dismiss();
      if (response.code == 200) {
        if (mounted) {
          avatarUrl = response.data?["url"].toString();
        } else {
          EasyLoading.showToast(response.message,maskType: EasyLoadingMaskType.none);
        }
      }
    } catch (e) {
      YTLog.d(_tag, "$e");
      EasyLoading.dismiss();
    }
  }

  void _handleEditGroup() {
    if (_groupNameController.text.isEmpty) {
      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddGroupNameNilTip,maskType: EasyLoadingMaskType.none);
      return;
    }
    if (_groupDesController.text.isEmpty) {
      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddGroupDesNilTip,maskType: EasyLoadingMaskType.none);
      return;
    }

    if (avatarUrl == null) {
      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imAddGroupAvatarNilTip,maskType: EasyLoadingMaskType.none);
      return;
    }

    YTUtils.hideKeyboard(context);
    EasyLoading.show();

    YTIM().setGroupInfo(context, group!, _groupNameController.text, avatarUrl!, (value) {
      EasyLoading.dismiss();
      // 更新会话页面信息
      imEventBus
          .fire(IMEventCommand(IMEventCommandType.updateGroupInfo, group: value));

      //更新群详情信息
      Navigator.pop(context, group);
    }, (error) {
      EasyLoading.dismiss();
      YTLog.d(_tag, "$error");
    },desc:_groupDesController.text );
  }
}
