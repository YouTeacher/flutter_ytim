import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class IMShowImagePicker {
  IMShowImagePicker._();

  static imShowImagePickerModal(BuildContext context,
      {VoidCallback? onPressedPhoto, VoidCallback? onPressedCamera}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: Center(
                  child: Text(
                    IMLocalizations.of(context).currentLocalization.uploadCredentialsAlertTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text(IMLocalizations.of(context).currentLocalization.uploadCredentialsActionAlbum),
                onTap: onPressedPhoto,
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title: Text(IMLocalizations.of(context).currentLocalization.uploadCredentialsActionPicture),
                onTap: onPressedCamera,
              ),
              ListTile(
                title: Center(
                  child: Text(
                    IMLocalizations.of(context).currentLocalization.cancelBtn,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // 关闭底部弹出窗口
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //相机图片处理
  static Future<XFile?> pickImage(
      ImageSource source,
      BuildContext context,
      ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // 选择成功，可以在这里处理选择的图片
      // pickedFile.path 包含了选择的图片的本地路径
      // 例如：pickedFile.path
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path, // 选择的图像路径
        compressQuality: 50, // 压缩质量（0-100）
        uiSettings: [
          // 裁剪后的最大高度
          AndroidUiSettings(
            toolbarColor: Colors.blue, // Android裁剪工具栏颜色
            toolbarWidgetColor: Colors.white, // Android裁剪工具栏图标颜色
          ),
          IOSUiSettings(
            // ignore: use_build_context_synchronously
            doneButtonTitle: IMLocalizations.of(context).currentLocalization.completionReservation,
            // ignore: use_build_context_synchronously
            cancelButtonTitle: IMLocalizations.of(context).currentLocalization.cancel,
          )
        ],
      );
      if (croppedFile != null) {
        var file = XFile(croppedFile.path);
        return file;
      }
    }
    return null;
  }
}
