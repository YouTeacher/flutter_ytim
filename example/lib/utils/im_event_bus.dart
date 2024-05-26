import 'package:event_bus_plus/res/app_event.dart';
import 'package:event_bus_plus/res/event_bus.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim/src/model/im_group.dart';

EventBus imEventBus = EventBus();

class IMEventCommand extends AppEvent {
  final IMEventCommandType type;
  final IMGroup? group; // 群组信息修改
  final IMBaseMessage? message;
  final IMCommand? command;
  const IMEventCommand(this.type,  {this.group,this.message, this.command,});

  @override
  List<Object?> get props => throw UnimplementedError();
}

enum IMEventCommandType {
  // 监听登录
  login,
  // 退出登录
  logout,
  // 更新组信息
  updateGroupInfo,
  // 重置数据
  resetData,
  // 通知IM总列表更新
  imTotalList,
  // 刷新首页数据
  refreshHome,
  /// 消息已读的事件
  readMsg,
  /// 聊天消息的事件
  chatMsg,
  /// 消息撤回的事件
  revokeMsg,
}
