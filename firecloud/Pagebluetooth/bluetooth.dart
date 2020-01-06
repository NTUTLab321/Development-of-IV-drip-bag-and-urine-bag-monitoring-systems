// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'widgets.dart';
import 'package:cron/cron.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PageBluetooth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state, //Obtain an instance
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            //開啟藍芽，顯示尋找裝置
            return FindDevicesScreen();
          }
          return BluetoothOffScreen(); //沒開啟時顯示藍芽未開啟
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatefulWidget {
  @override
  _BluetoothOffScreen createState() => _BluetoothOffScreen();
}

class _BluetoothOffScreen extends State<BluetoothOffScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue, //將背景設為藍色
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled, //顯示藍芽未開啟的圖案
              size: 100.0,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreen createState() => _FindDevicesScreen();
}

class _FindDevicesScreen extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'NTUTLab321點滴、尿袋智慧監控系統',
            style: TextStyle(fontSize: 19.4),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => FlutterBlue.instance.startScan(
            timeout: Duration(seconds: 4),
          ), //開始搜尋，持續4秒
          child: SingleChildScrollView(
            //建立一個能捲動的Widget
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  //列出藍芽裝置
                  stream: Stream.periodic(
                    Duration(seconds: 2),
                  ).asyncMap((_) => FlutterBlue.instance.connectedDevices),
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map(
                          (d) => ListTile(
                        title: Text(d.name), //藍芽名稱
                        subtitle: Text(
                          d.id.toString(),
                        ), //藍芽ID
                        trailing: StreamBuilder<BluetoothDeviceState>(
                          stream: d.state,
                          initialData: BluetoothDeviceState.disconnected,
                          builder: (c, snapshot) {
                            if (snapshot.data == //如果已經連上了，就顯示OPEN的按鈕
                                BluetoothDeviceState.connected) {
                              return RaisedButton(
                                child: Text('OPEN'),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DeviceScreen(device: d),
                                  ),
                                ),
                              );
                            }
                            return Text(
                              snapshot.data.toString(),
                            );
                          },
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: FlutterBlue.instance.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map(
                          (r) => ScanResultTile(
                        result: r,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              r.device.connect();
                              return DeviceScreen(device: r.device);
                            },
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance.startScan(
                  timeout: Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ),
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
}

class DeviceScreen extends StatefulWidget {
  DeviceScreen({@required this.device, Key key}); //使用該字段的類型並初始化
  final BluetoothDevice device;
  @override
  _DeviceScreen createState() => _DeviceScreen(device: device);
}

class _DeviceScreen extends State<DeviceScreen> {
  _DeviceScreen({@required this.device, Key key}); //使用該字段的類型並初始化
  final BluetoothDevice device;
  //列出所有的服務
  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    List<String> message = [];
    message.insert(0, '1');
    List<DateTime> _events = [];
    var alarm = 25;
    return services
        .map(
          (s) => ServiceTile(
        service: s,
        characteristicTiles: s.characteristics.map(
              (c) {
            if ('0x${c.uuid.toString().toUpperCase().substring(4, 8)}' == '0x1514' ||
                '0x${c.uuid.toString().toUpperCase().substring(4, 8)}' ==
                    '0x1504' ||
                '0x${c.uuid.toString().toUpperCase().substring(4, 8)}' ==
                    '0x1505') {
              c.setNotifyValue(true);
            }
            if ('0x${c.uuid.toString().toUpperCase().substring(4, 8)}' ==
                '0x1504') {
              //檢測液面是否滿
              var cron = new Cron();
              cron.schedule(
                new Schedule.parse('*/1 * * * *'),
                    () async {
                  print('every one minutes');
                  Future update1() async {
                    List<int> value = await c.read();
                    _events.insert(
                      0,
                      new DateTime.now(),
                    );
                    if (value.toString().substring(1, 2) == '1') {
                      message.insert(0, '需更換');
                    } else if (value.toString().substring(1, 2) == '0') {
                      message.insert(0, '不需更換');
                    }
                    if (message[1] == null ||
                        (message[1] != message[0] && message[1] != null)) {
                      Firestore.instance
                          .collection('NTUTLab321')
                          .document('${c.deviceId.toString()}')
                          .updateData(
                        {
                          'change': value.toString().substring(1, 2),
                          'time': DateFormat("yyyy-MM-dd HH:mm:ss")
                              .format(_events[0]) +
                              message[0]
                        },
                      );
                    }
                  }

                  update1();
                },
              );
              //檢測使用模式
              if ('0x${c.uuid.toString().toUpperCase().substring(4, 8)}' ==
                  '0x1505') {
                var cron = new Cron();
                cron.schedule(
                  new Schedule.parse('*/1 * * * *'),
                      () async {
                    Future update1() async {
                      List<int> value = await c.read();
                      _events.insert(
                        0,
                        new DateTime.now(),
                      );
                      if (value.toString().substring(1, 2) == '1') {
                        message.insert(0, '點滴模式');
                        if (message[1] == null ||
                            (message[1] != message[0] &&
                                message[1] != null)) {
                          Firestore.instance
                              .collection('NTUTLab321')
                              .document('${c.deviceId.toString()}')
                              .updateData(
                            {
                              'modedescription': '點滴',
                              'time': DateFormat("yyyy-MM-dd HH:mm:ss")
                                  .format(_events[0]) +
                                  message[0]
                            },
                          );
                        }
                      } else if (value.toString().substring(1, 2) == '0') {
                        message.insert(0, '尿袋模式');
                        if (message[1] == null ||
                            (message[1] != message[0] &&
                                message[1] != null)) {
                          Firestore.instance
                              .collection('NTUTLab321')
                              .document('${c.deviceId.toString()}')
                              .updateData(
                            {
                              'modedescription': '尿袋',
                              'time': DateFormat("yyyy-MM-dd HH:mm:ss")
                                  .format(_events[0]) +
                                  message[0]
                            },
                          );
                        }
                      }
                    }

                    update1();
                  },
                );
              }
            }
            if ('0x${c.uuid.toString().toUpperCase().substring(4, 8)}' ==
                '0x1514') {
              var cron = new Cron();
              cron.schedule(
                new Schedule.parse('*/1 * * * *'),
                    () async {
                  //電量每五分鐘上傳一次
                  Future update1() async {
                    List<int> value = await c.read();
                    if (10 >= value[0] && alarm > value[0]) {
                      //放電
                      Firestore.instance
                          .collection('NTUTLab321')
                          .document('${c.deviceId.toString()}')
                          .updateData(
                        {
                          'alarm': '1',
                          'power': value.toString().substring(1, 2)
                        },
                      ); //設置後端響鈴
                      alarm = value[0];
                    } else if (25 >= value[0] && alarm > value[0]) {
                      //放電
                      Firestore.instance
                          .collection('NTUTLab321')
                          .document('${c.deviceId.toString()}')
                          .updateData(
                        {
                          'alarm': '1',
                          'power': value.toString().substring(1, 3)
                        },
                      ); //設置後端響鈴
                      alarm = value[0];
                    } else if (alarm < value[0]) {
                      Firestore.instance
                          .collection('NTUTLab321')
                          .document('${c.deviceId.toString()}')
                          .updateData(
                        {
                          'alarm': '0',
                          'power': value.toString().substring(1, 3)
                        },
                      );
                      alarm = value[0];
                    }
                  }

                  update1();
                },
              );
            }
            return CharacteristicTile(
              characteristic: c,
              onReadPressed: () => c.read(),
              onWritePressed: () => c.write([13, 24]),
              onNotificationPressed: () => c.setNotifyValue(!c.isNotifying),
              descriptorTiles: c.descriptors
                  .map(
                    (d) => DescriptorTile(
                  descriptor: d,
                  onReadPressed: () => d.read(),
                  onWritePressed: () => d.write([11, 12]),
                ),
              )
                  .toList(),
            );
          },
        ).toList(),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          device.name,
          style: TextStyle(fontSize: 19.9),
        ),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () {
                    Firestore.instance
                        .collection('NTUTLab321')
                        .document('${device.id.toString()}')
                        .delete();
                    device.disconnect();
                  };
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return FlatButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: true,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          Firestore.instance
                              .collection('NTUTLab321')
                              .document('${device.id.toString()}')
                              .setData({
                            'change': 'X',
                            'modedescription': '初始資料',
                            'power': '0',
                            'time': 'XXXX',
                            'title': '00-00',
                            'alarm': '0'
                          }, merge: true);
                          device.discoverServices();
                        },
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}