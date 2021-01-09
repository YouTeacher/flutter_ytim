# flutter_ytim
## 概要
YouTeacher IM 快速开发SDK.

## 功能
- IM账号自动注册/登陆
- 联系人列表
- 未读消息红点显示
- 最后一条消息展示
- 1v1聊天
- 未读/已读状态显示
- 自己的消息撤回
- 被踢下线回调
- 内置UI组件国际化支持

## TODO
- UI定制

## 截屏
| 联系人列表 | 1v1聊天 |
|:---:|:---:|
| ![](arts/user_list.png) | ![](arts/chat_1v1.png) |

## 使用方法
### 添加依赖
```
dependencies:
  flutter_ytim: ^1.0.1
```
### 导包
```
import 'package:flutter_ytim/flutter_ytim.dart';
```
### 快速集成
```
// 0. 国际化
MaterialApp(
  localizationsDelegates: [
    // 这一行很重要，YTIM内置界面的文字国际化。
    YTIMLocalizations.delegate,
  ],
  home: HomePage(),
)
```
```
// 1.初始化
YTIM().init(
  imAppID: '8C5FA707436E824363ECF0172F408F2D',
  imAppSecret: '42C213D8A378EDA8034598CDF840823D',
  imAccount: 'and2long@gmail.com',
  imUsername: 'and2long',
  imUserCreatedCallback: (IMUser value) {
    print(value);
    // 创建IM用户成功，将IM用户信息与你自己的用户系统关联起来。
  },
  imLoginSuccessCallback: (IMUser value) {
    // IM用户登陆成功，取联系人列表。
    YTIM().getUserList(order: '4');
  },
);
```
```
// 2. 在程序回到前台时，检查IM连接状态。
YTIM().checkConnectStatus();
```
```
// 3. 断开连接，释放资源。
YTIM().release();
```
## 示例代码
[example project](https://github.com/and2long/flutter_ytim/tree/master/example)