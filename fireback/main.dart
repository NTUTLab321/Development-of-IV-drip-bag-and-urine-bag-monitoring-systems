import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
    );
    subscription = Connectivity().onConnectivityChanged.listen(
          (ConnectivityResult result) {
        check();
      },
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('NTUTLab321點滴、尿袋智慧監控系統'),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: SwitchListTile(
                    title: Text('鈴聲開關'),
                    value: ring,
                    onChanged: (bool value) {
                      setState(
                            () {
                          ring = value;
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuDivider(height: 1.0),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('編號排序'),
                    value: lists.number,
                    groupValue: choose,
                    onChanged: (lists value) {
                      setState(
                            () {
                          choose = value;
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('狀態排序'),
                    value: lists.state,
                    groupValue: choose,
                    onChanged: (lists value) {
                      setState(
                            () {
                          choose = value;
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                PopupMenuItem(
                  child: RadioListTile(
                    title: Text('電量排序'),
                    value: lists.battery,
                    groupValue: choose,
                    onChanged: (lists value) {
                      setState(
                            () {
                          choose = value;
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
        body: Center(
          child: Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream(choose),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('連接中...');
                  default:
                    return ListView(
                      children: <Widget>[
                        DataTable(
                          columnSpacing: 1.0,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text('設備編號'),
                            ),
                            DataColumn(
                              label: Text('模式'),
                            ),
                            DataColumn(
                              label: Text('狀態'),
                            ),
                            DataColumn(
                              label: Text('電量'),
                            ),
                            DataColumn(
                              label: Text('光譜圖'),
                            ),
                            DataColumn(
                              label: Text('工作狀態'),
                            ),
                            DataColumn(
                              label: Text('資料刪除'),
                            )
                          ],
                          rows: createRows(snapshot.data),
                        ),
                      ],
                    );
                }
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.alarm_off),
          onPressed: () {
            FlutterRingtonePlayer.stop();
          },
        ),
      ),
    );
  }

  List<DataRow> createRows(QuerySnapshot snapshot) {
    List<DataRow> list = snapshot.documents.map(
          (DocumentSnapshot documentSnapshot) {
        return DataRow(
          cells: [
            DataCell(
              Text(
                documentSnapshot['title'],
              ),
            ),
            DataCell(
              Text(
                documentSnapshot['modedescription'],
              ),
            ),
            DataCell(
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: getColor1(
                    documentSnapshot['change'],
                  ),
                ),
              ),
            ),
            DataCell(
              ListTile(
                leading: CircleAvatar(
                  child: Text(
                    documentSnapshot['power'],
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: getColor2(
                    documentSnapshot['power'],
                  ),
                ),
              ),
            ),
            DataCell(
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () {},
              ),
            ),
            DataCell(
              Text(
                documentSnapshot['time'],
              ),
            ),
            DataCell(
              GestureDetector(
                child: Icon(Icons.delete),
                onTap: () {
                  return showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('刪除確認'),
                      content: Text('確定刪除此資料?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('否'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text('是'),
                          onPressed: () {
                            Firestore.instance
                                .collection('NTUTLab321')
                                .document(documentSnapshot.documentID)
                                .delete();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
                onLongPress: () {
                  _delete();
                },
              ),
            )
          ],
        );
      },
    ).toList();
    return list;
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
              FlutterRingtonePlayer.stop();
              Navigator.of(context).pop(true);
            },
          )
        ],
      ),
    );
  }

  Future<bool> _delete() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('格式化警告'),
        content: Text('確定刪除全部資料?'),
        actions: <Widget>[
          FlatButton(
            child: Text('否'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('是'),
            onPressed: () {
              Firestore.instance.collection('NTUTLab321').getDocuments().then(
                    (snapshot) {
                  for (DocumentSnapshot documentSnapshot
                  in snapshot.documents) {
                    documentSnapshot.reference.delete();
                  }
                },
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

enum lists { number, state, battery }
lists choose = lists.number;
var subscription;
int powered;
bool ring = true;

Stream<QuerySnapshot> _stream(var change) {
  switch (change) {
    case lists.state:
      return Firestore.instance
          .collection('NTUTLab321')
          .orderBy('change', descending: true)
          .snapshots();
    case lists.battery:
      return Firestore.instance
          .collection('NTUTLab321')
          .orderBy('power', descending: false)
          .snapshots();
    default:
      return Firestore.instance
          .collection('NTUTLab321')
          .orderBy('title', descending: false)
          .snapshots();
  }
}

Color getColor1(String selector) {
  switch (selector) {
    case '0':
      return Colors.greenAccent;
    case '1':
      judge(ring);
      return Colors.redAccent;
    default:
      return Colors.black12;
  }
}

Color getColor2(String power) {
  powered = int.parse(power);
  if (powered > 50 && powered < 101) {
    return Colors.green;
  } else if (powered > 25 && powered < 51) {
    return Colors.yellow;
  } else if (powered > 0 && powered < 26) {
    if (powered == 25) {
      judge(ring);
    }
    return Colors.red;
  } else {
    return Colors.black12;
  }
}

void judge(bool ring) {
  if (ring == true) {
    FlutterRingtonePlayer.playAlarm();
  } else {
    FlutterRingtonePlayer.stop();
  }
}