import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:saver_gallery/saver_gallery.dart';

class FullScreenImageGallery extends StatelessWidget {
  final List<IMBaseMessage>? messages;

  const FullScreenImageGallery(
      {super.key, this.messages});

  @override
  Widget build(BuildContext context) {

    int currentIndex = 0;

    return Scaffold(
        body: Stack(
          children: [
            InkWell(
              child: PhotoViewGallery.builder(
                itemCount: messages!.length,
                builder: (context, index) {
                  if (messages![index].content != null) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: CachedNetworkImageProvider(
                          messages![index].content ?? ""),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  } else {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                      FileImage(File(messages![index].filePath ?? "")),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  }
                },
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  currentIndex = index;
                },
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Positioned(
                bottom: 30,
                right: 30,
                child: GestureDetector(
                  child:Icon(Icons.download,size: 25,color: whiteColor,),
                  onTap: () {
                    if (messages![currentIndex].content != null) {
                      _saveImage(messages![currentIndex].content ?? "", context);
                    }
                  },
                ))
          ],
        ));
  }

  _saveImage(String url, BuildContext context) async {
    var response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    String picturesPath = IMUtils.getTimestamp();
    debugPrint(picturesPath);
    final result = await SaverGallery.saveImage(
      Uint8List.fromList(response.data),
      quality: 60,
      name: picturesPath,
      androidRelativePath: "Pictures/appName/xx",
      androidExistNotSave: false,
    );
    if (context.mounted) {
      EasyLoading.showToast(IMLocalizations.of(context).currentLocalization.imgSaveSuccessTip, maskType: EasyLoadingMaskType.none);
    }
    debugPrint(result.toString());
  }
}
