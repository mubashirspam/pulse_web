import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pulse_education_web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Arial",
        textTheme: const TextTheme(
          button: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
      ),
      home: const WebViewContainer(),
    );
  }
}

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key});

  @override
  createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.white)
    ..setNavigationDelegate(
      NavigationDelegate(
        // onProgress: (int progress) {
        //   // Update loading bar.
        // },
        // onPageStarted: (String url) {},
        // onPageFinished: (String url) {},

        // onWebResourceError: (WebResourceError error) {},

        onNavigationRequest: (NavigationRequest request) {
          final host = Uri.parse(request.url).host;

          if (!host.contains('https://app.pulseentrance.in/')) {
            launchUrl(
              Uri.parse(request.url),
              mode: LaunchMode.externalNonBrowserApplication,
            );

            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://app.pulseentrance.in/'));

  // WebViewController? webView;
  Future<bool> _onBack() async {
    bool goBack = false;

    var value = await controller.canGoBack(); // check webview can go back

    if (value) {
      controller.goBack(); // perform webview back operation
      return false;
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation ',
              style: TextStyle(color: Colors.green)),

          // Are you sure?

          content: const Text('Do you want exit app ? '),

          // Do you want to go back?

          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);

                setState(() {
                  goBack = false;
                });
              },

              child: const Text("No"), // No
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  goBack = true;
                });
              },

              child: const Text("Yes"), // Yes
            ),
          ],
        ),
      );

      if (goBack) SystemNavigator.pop(); // If user press Yes pop the page
      return goBack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
