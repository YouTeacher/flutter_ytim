import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/yt_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final String? url, title;
  final bool isShare;
  const WebPage(
      {super.key, required this.url, this.title = '', this.isShare = false});

  @override
  WebPageState createState() => WebPageState();
}

class WebPageState extends State<WebPage> {
  bool loading = true;
  late final WebViewController controllerWeb;

  @override
  void initState() {
    super.initState();
    if (widget.url == '') {
      Navigator.pop(context);
    }
    controllerWeb = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title!,
            ),
            actions: widget.isShare ? [_buildShareActionButton(context)] : [],
          ),
          body: Center(
            child: SizedBox(
              width: YTUtils.iPadSize(constraints),
              child: Stack(
                children: [
                  WebViewWidget(controller: controllerWeb),
                  Positioned(
                    top: 0,
                    child: Offstage(
                      offstage: !loading,
                      child: SizedBox(
                        height: 3,
                        width: MediaQuery.of(context).size.width,
                        child: const LinearProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildShareActionButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.share,
        size: 20.0,
        color: Colors.black87,
      ),
      onPressed: () {},
    );
  }
}
