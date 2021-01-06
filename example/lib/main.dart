import 'package:example/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String tag = '_HomePageState';

  int _tabIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 1. IM初始化
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        // 2. 在程序回到前台时，检查IM连接状态。
        YTIM().checkConnectStatus();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    // 3. 断开连接，释放资源。
    YTIM().release();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: [ContactsPage(showAppBar: true), AboutPage()],
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Container(
                  child: Icon(Icons.message),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 7),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: StreamBuilder<IMUnreadCount>(
                    builder: (BuildContext context,
                        AsyncSnapshot<IMUnreadCount> snapshot) {
                      if (snapshot.hasData) {
                        return UnreadCountView(count: snapshot.data.count);
                      } else {
                        return Container();
                      }
                    },
                    stream: YTIM().on<IMUnreadCount>(),
                  ),
                ),
              ],
            ),
            label: 'IM消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
        currentIndex: _tabIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
