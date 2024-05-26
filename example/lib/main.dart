import 'package:flutter/material.dart';
import 'package:flutter_ytim/flutter_ytim.dart';
import 'package:flutter_ytim_example/ui/page/im_home_page.dart';
import 'package:flutter_ytim_example/values/localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => IMStore({}, {}, {}, [], [], [], [])),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          IMLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: [Locale('zh'), Locale('ja')],
        locale: Locale('zh'),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('IM Example'),
          ),
          body: const IMHomePage(),
        ),
      ),
    );
  }
}
