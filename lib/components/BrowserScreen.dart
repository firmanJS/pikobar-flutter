 import 'package:flutter/material.dart';
 import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pikobar_flutter/constants/Dictionary.dart';

 class BrowserScreen extends StatefulWidget {
   final String url;

   BrowserScreen({
     Key key,
     @required this.url,
   });

   @override
   _BrowserScreenState createState() => _BrowserScreenState();
 }

 class _BrowserScreenState extends State<BrowserScreen> {
   double progress = 0.0;
   InAppWebViewController webView;

   @override
   void initState() {
     super.initState();
   }

   @override
   void dispose() {
     super.dispose();
   }

   @override
   Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: _exitWebView,
       child: Scaffold(
         appBar: AppBar(
           title: Text(Dictionary.appName),
         ),
         body: Column(
           children: <Widget>[
             Container(
                 padding: progress < 1.0 ? EdgeInsets.symmetric(vertical: 5.0) : null,
                 child: progress < 1.0
                     ? LinearProgressIndicator(value: progress)
                     : Container()),
             Expanded(
               child: Container(
                 child: InAppWebView(
                   initialUrl: widget.url,
                   initialHeaders: {},
                   initialOptions: InAppWebViewWidgetOptions(
                       inAppWebViewOptions: InAppWebViewOptions(
                         userAgent: 'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19',
                         debuggingEnabled: true,
                       )
                   ),
                   onWebViewCreated: (InAppWebViewController controller) {
                     webView = controller;
                   },
                   onProgressChanged: (InAppWebViewController controller, int progress) {
                     setState(() {
                       this.progress = progress / 100;
                     });
                   },
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }

   Future<bool> _exitWebView() async {
     if (await webView.canGoBack()) {
       webView.goBack();
       return Future.value(false);
     } else {
       Navigator.of(context).pop();
       return Future.value(true);
     }
   }
 }
