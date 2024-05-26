import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ytim/src/utils/im_utils.dart';
import 'package:flutter_ytim_example/ui/view/chat_edit_text.dart';
import 'package:flutter_ytim_example/ui/view/voice_widget.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';
import 'package:flutter_ytim_example/utils/response_body.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:flutter_ytim_example/utils/ythttp.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_ytim/src/ytim.dart';
import 'package:flutter_ytim/src/ytimapi.dart';
import 'package:flutter_ytim/src/model/im_group.dart';
import 'package:flutter_ytim/src/model/im_group_message.dart';
import 'package:flutter_ytim/src/model/im_message.dart';
import 'package:flutter_ytim/src/model/im_store_message.dart';
import 'package:flutter_ytim/src/model/im_user.dart';
import 'package:flutter_ytim/src/utils/yt_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ChatInputForm extends StatefulWidget {
  const ChatInputForm({
    super.key,
    this.chatType,
    this.toGroup,
    this.toUser,
    this.onMessageSuccessCallback,
    this.onGroupMessageSuccessCallback,
    this.onStoreMessageSuccessCallback,
  });

  final ChatType? chatType;
  final IMUser? toUser;
  final IMGroup? toGroup;
  final SendMessageCallback<IMMessage>? onMessageSuccessCallback;
  final SendMessageCallback<IMGroupMessage>? onGroupMessageSuccessCallback;
  final SendMessageCallback<IMStoreMessage>? onStoreMessageSuccessCallback;

  @override
  ChatInputFormState createState() => ChatInputFormState();
}

class ChatInputFormState extends State<ChatInputForm> {
  String tag = '_ChatInputForm';

  TextEditingController messController = TextEditingController();
  VideoPlayerController? _videoPlayerController;

  GlobalKey formKey = GlobalKey<FormState>();

  bool canSend = false;
  bool micShow = false;
  bool isMicing = false; //是否录音中

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              _buildInputPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // IconButton(
          //   icon: Assets.image.imIcons.add.image(width: 20),
          //   onPressed: () {
          //     CommonUtils.hideKeyboard(context);
          //   },
          // ),
          Container(
            margin: const EdgeInsets.only(right: 20, left: 15),
            child: GestureDetector(
              child: Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: darkColor,
              ),
              onTap: () {
                _showVideoPicker();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              child: Icon(
                Icons.photo_album,
                size: 20,
                color: darkColor,
              ),
              onTap: () {
                YTUtils.hideKeyboard(context);
                _showImagePicker();
              },
            ),
          ),
          Expanded(
            child: micShow
                ? VoiceWidget(
                    startRecord: startRecord,
                    stopRecord: stopRecord,
                    // 加入定制化Container的相关属性
                    margin: const EdgeInsets.all(0),
                    height: 38.0,
                  )
                : IMChatEditText(
                    noBorder: true,
                    hintText:
                        '${IMLocalizations.of(context).currentLocalization.imSendTo} ',
                    controller: messController,
                    onReturnOnTap: () {
                      YTUtils.hideKeyboard(context);
                      String content = messController.text.trim();
                      if (content.isNotEmpty) {
                        final uuid = IMUtils.getTimestamp(); //用来替换发送成功的服务器数据
                        if (widget.chatType == ChatType.user) {
                          //消息发送成功
                          IMMessage msg = IMMessage(
                            chatType: widget.chatType!,
                              uuid: uuid,
                              time: uuid,
                              content: content,
                              to: widget.toUser?.userId,
                              type: "1",
                              from: YTIM().mUser.userId,
                              status: '1');
                          widget.onMessageSuccessCallback!(
                              msg, IMMessageSendState.sending);
                        } else if (widget.chatType == ChatType.groups) {
                          IMGroupMessage msg = IMGroupMessage(
                              chatType: widget.chatType!,
                              uuid: uuid,
                              time: uuid,
                              groupId: widget.toGroup?.groupId,
                              content: content,
                              type: "1",
                              from: YTIM().mUser.userId,
                              status: '1');
                          msg.from = YTIM().mUser.userId;
                          widget.onGroupMessageSuccessCallback!(
                              msg, IMMessageSendState.sending);
                        } else if (widget.chatType == ChatType.store) {
                          IMStoreMessage msg = IMStoreMessage(
                              chatType: widget.chatType!,
                              uuid: uuid,
                              storeId: widget.toUser?.userId,
                              time: uuid,
                              content: content,
                              type: "1",
                              from: YTIM().mUser.userId,
                              status: '1');
                          msg.from = YTIM().mUser.userId;
                          widget.onStoreMessageSuccessCallback!(
                              msg, IMMessageSendState.sending);
                        }

                        _sendMsg(content, "1", uuid);
                      }
                    },
                    onChanged: validateInput,
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: GestureDetector(
              child: micShow
                  ? const Icon(Icons.keyboard, color: darkColor)
                  : const Icon(Icons.mic, color: darkColor),
              onTap: () {
                YTUtils.hideKeyboard(context);
                if (mounted) {
                  setState(() {
                    micShow = !micShow;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    messController.dispose();
    _videoPlayerController?.dispose();
  }

  void validateInput(String test) {
    setState(() {
      canSend = test.isNotEmpty;
    });
  }

  void _sendMsg(String content, String type, String uuid) {
    if (!canSend && type == "1") {
      return;
    }
    if (widget.chatType == ChatType.user) {
      YTIM().sendChatMessage(
          ChatType.user, widget.toUser?.userId ?? "", content, type, uuid,
          userName: widget.toUser?.username, (value) {
        Map<String, dynamic> obj = json.decode(value);
        //消息发送成功
        IMMessage msg = IMMessage.fromJson(obj['data'],widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = obj['uuid'];
        msg.status = '0';
        widget.onMessageSuccessCallback!(msg, IMMessageSendState.sendSuccess);
      }, (error) {
        IMMessage msg = IMMessage(chatType: widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = error["uuid"];
        msg.status = '2';
        widget.onMessageSuccessCallback!(msg, IMMessageSendState.sendError);
      });

      // 保证在组件build的第一帧时才去触发取消清空内容
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messController.clear();
      });
    } else if (widget.chatType == ChatType.groups) {
      YTIM().sendChatMessage(ChatType.groups, widget.toGroup?.groupId.toString() ?? '', content, type, uuid, (value) {
        Map<String, dynamic> obj = json.decode(value);
        //消息发送成功
        IMGroupMessage msg = IMGroupMessage.fromJson(obj['data'],widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = obj['uuid'].toString();
        widget.onGroupMessageSuccessCallback!(
            msg, IMMessageSendState.sendSuccess);
      }, (error) {
        IMGroupMessage msg = IMGroupMessage(chatType: widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = error["uuid"];
        msg.status = '2';
        widget.onGroupMessageSuccessCallback!(
            msg, IMMessageSendState.sendError);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messController.clear();
      });
    } else if (widget.chatType == ChatType.store) {
      YTIM().sendChatMessage(ChatType.store, widget.toUser?.userId.toString() ?? '', content, type, uuid, (value) {
        Map<String, dynamic> obj = json.decode(value);
        //消息发送成功
        IMStoreMessage msg = IMStoreMessage.fromJson(obj['data'],widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = obj['uuid'].toString();
        widget.onStoreMessageSuccessCallback!(
            msg, IMMessageSendState.sendSuccess);
      }, (error) {
        IMStoreMessage msg = IMStoreMessage(chatType: widget.chatType!);
        msg.from = YTIM().mUser.userId;
        msg.uuid = error["uuid"];
        msg.status = '2';
        widget.onStoreMessageSuccessCallback!(
            msg, IMMessageSendState.sendError);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messController.clear();
      });
    }
    if (type == "1") {
      setState(() {
        canSend = false;
      });
    }
  }

  void _showImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      //弹出确认页面
      if (mounted) {
        YTUtils.showIMAlertWidget(context, File(pickedFile.path),
            okStr: IMLocalizations.of(context).currentLocalization.send,
            okCallBack: () {
          Navigator.pop(context);
          uploadFileAction(pickedFile.path, "2");
        });
      }
    }
  }

  void _showVideoPicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Handle the selected video
      // _initializeVideoPlayer(pickedFile.path);
      uploadFileAction(pickedFile.path, "2");
    }
  }

  // void _initializeVideoPlayer(String videoPath) {
  //   _videoPlayerController?.dispose();
  //   _videoPlayerController = VideoPlayerController.file(File(videoPath))
  //     ..initialize().then((_) {
  //       setState(() {
  //         // Play the video
  //         _videoPlayerController?.play();
  //       });
  //     });
  // }

  //录制语音结束
  startRecord() {
    YTLog.d(tag, "开始录制");
  }

  //录制语音结束
  stopRecord(String path, double audioTimeLength) {
    YTLog.d(tag, "结束束录制");
    YTLog.d(tag, "音频文件位置$path");
    YTLog.d(tag, "音频录制时长${audioTimeLength.toString()}");
    uploadFileAction(path, '3');
    // updateFile(path);
  }

  bool working = false;

  Future<String> getTemporaryDirectoryPath() async {
    final Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  //上传文件并发送给IM type:1文本 2图片 3语音 4视频 5其他 6地图
  void uploadFileAction(
    String path,
    String type,
  ) async {
    final uuid = IMUtils.getTimestamp(); //用来替换发送成功的服务器数据

    if (widget.chatType == ChatType.user) {
      IMMessage msg = IMMessage(
        chatType: widget.chatType!,
          uuid: uuid,
          time: uuid,
          filePath: path,
          type: type,
          from: YTIM().mUser.userId,
          status: '1');
      msg.from = YTIM().mUser.userId;
      widget.onMessageSuccessCallback!(msg, IMMessageSendState.sending);
    } else if (widget.chatType == ChatType.groups) {
      IMGroupMessage msg = IMGroupMessage(
        chatType: widget.chatType!,
          uuid: uuid,
          time: uuid,
          filePath: path,
          type: type,
          from: YTIM().mUser.userId,
          status: '1');
      msg.from = YTIM().mUser.userId;
      widget.onGroupMessageSuccessCallback!(msg, IMMessageSendState.sending);
    } else if (widget.chatType == ChatType.store) {
      IMStoreMessage msg = IMStoreMessage(
        chatType: widget.chatType!,
          uuid: uuid,
          time: uuid,
          filePath: path,
          type: type,
          from: YTIM().mUser.userId,
          status: '1');
      widget.onStoreMessageSuccessCallback!(msg, IMMessageSendState.sending);
    }
    try {
      YTUtils.hideKeyboard(context);
      ResponseData response =
          await YTHttp.uploadImage('/api/basis/upload', path);

      if (response.code == 200) {
        if (mounted) {
          String fileUrl = response.data?["url"];
          _sendMsg(fileUrl, type, uuid);
        }
      } else {
        EasyLoading.showToast(response.message ?? '',
            maskType: EasyLoadingMaskType.none);
      }
    } catch (e) {
      YTLog.d('uploadFileAction', '$e');
      IMGroupMessage msg = IMGroupMessage(
        chatType: widget.chatType!,
          uuid: uuid,
          time: uuid,
          filePath: path,
          type: type,
          from: YTIM().mUser.userId,
          status: '2');
      msg.from = YTIM().mUser.userId;
      widget.onGroupMessageSuccessCallback!(msg, IMMessageSendState.sendError);
    }
  }
}
