//import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_firecloud/Pagebluetooth/bluetooth.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner:false,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen(
          (ConnectivityResult result) {
        check();
      },
    );
  }
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('退出提醒'),
        content: Text('確定退出此應用程式?'),
        actions: <Widget>[
          FlatButton(
            child: Text('否'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text('是'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }
  @override

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
       child: Scaffold(
    //      appBar: AppBar(
     //       title: Text('點滴、尿袋液面高度與光譜感智慧監控系統'),
     //     ),
          body:
          PageBluetooth(),
          ),
    );


  }
  void check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('網路狀態警告'),
          content: Text('請確認網路是否連接。'),
          actions: <Widget>[
            FlatButton(
              child: Text('確認'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}
var subscription;