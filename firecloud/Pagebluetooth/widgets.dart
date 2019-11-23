// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
//import 'package:flutter_firecloud/Pagebluetooth/bluetooth.dart';
//import "package:flutter_firecloud/Pagefirebase/color.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
//import 'package:vibration/vibration.dart';
//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/services.dart';
//import 'package:cron/cron.dart';

void startServiceInPlatform() async {
  if (Platform.isAndroid) {
    var methodChannel = MethodChannel("decide background");
    String data = await methodChannel.invokeMethod("startService");
    debugPrint(data);
  }
}
class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;
//result.device.name.length > 0&&
  Widget _buildTitle(BuildContext context) {
    if (result.device.name=='NTUT_LAB321_Product') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    }
    else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if(result.device.name=='NTUT_LAB321_Product'){  //只顯現固定裝置

      return ExpansionTile(
        title: _buildTitle(context),
        leading: Text(result.rssi.toString()),
        trailing:
        RaisedButton(
          child: Text('CONNECT'),
          color: Colors.black,
          textColor: Colors.white,
          onPressed: (result.advertisementData.connectable) ? onTap : null,
        ),
        children: <Widget>[
          _buildAdvRow(
              context, 'Complete Local Name', result.advertisementData.localName),
          _buildAdvRow(context, 'Tx Power Level',
              '${result.advertisementData.txPowerLevel ?? 'N/A'}'),
          _buildAdvRow(
              context,
              'Manufacturer Data',
              getNiceManufacturerData(
                  result.advertisementData.manufacturerData) ??
                  'N/A'),
          _buildAdvRow(
              context,
              'Service UUIDs',
              (result.advertisementData.serviceUuids.isNotEmpty)
                  ? result.advertisementData.serviceUuids.join(', ').toUpperCase()
                  : 'N/A'),
          _buildAdvRow(context, 'Service Data',
              getNiceServiceData(result.advertisementData.serviceData) ?? 'N/A'),
        ],
      );}
    else{
      return   Container(width: 0,height: 0,);

    }
  }
}

class ServiceTile extends StatefulWidget{
  ServiceTile({
    @required this.service,
    this.characteristicTiles,
    Key key
  });

  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  @override
  _ServiceTile createState() => _ServiceTile(service: service,
      characteristicTiles: characteristicTiles);
}

class _ServiceTile extends State<ServiceTile> {
  _ServiceTile({
    @required this.service,
    this.characteristicTiles,
    Key key
  });
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;


  var selectItemValue,selectItemValue1,selectItemValue2;int power=0;
  @override
  Widget build(BuildContext context) {
    startServiceInPlatform();

    if('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'==
        '0x1801'||'0x${service.uuid.toString().toUpperCase().substring(4, 8)}'==
        '0x1523'){
      return Container(height: 0.0,);
    }
    if('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'==
        '0x1800'){

      return   ListView(
          shrinkWrap: true,
          children: <Widget>[
            Card(
              child:
              Card(
                  child:
                  Row(
                      children:<Widget>[
                        Text('下拉選單請選擇室、床號 ',
                            style:TextStyle(color: Colors.black, fontSize: 16.0)),
                        Builder(
                            builder: (BuildContext context) {

                              return DropdownButtonHideUnderline(
                                child: new DropdownButton(
                                  hint: new Text('室'),
                                  //設置這個value之後，選中對應位置的item,
                                  //再次呼出下拉菜單，會自動定位item位置在當前按鈕顯示的位置處
                                  value: selectItemValue,
                                  items: generateItemList(),
                                  onChanged: (T){
                                    setState(() {
                                      selectItemValue=T;
                                      //依照deviceID上傳對應firebase的documentID
                                      if(selectItemValue!=null&&selectItemValue1!=null){
                                        Firestore.instance.collection('NTUTLab321').document('${service.deviceId.toString()}')
                                            .updateData({'title': selectItemValue+'-'+selectItemValue1 });
                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                        Builder(
                            builder: (BuildContext context) {

                              return DropdownButtonHideUnderline(
                                child: new DropdownButton(
                                  hint: new Text('床號'),
                                  value: selectItemValue1,
                                  items: generateItemList1(),
                                  onChanged: (T){
                                    setState(() {
                                      selectItemValue1=T;
                                      if(selectItemValue!=null&&selectItemValue1!=null){

                                        Firestore.instance.collection('NTUTLab321').document('${service.deviceId.toString()}')
                                            .updateData({'title': selectItemValue+'-'+selectItemValue1 });

                                      }
                                    });
                                  },
                                ),
                              );
                            }),
                      ])),
            ),]
      );}

    if (characteristicTiles.length > 0
    ) {

      return ExpansionTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text('Service'),
            Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}',
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Theme.of(context).textTheme.caption.color))
          ],
        ),
        children: characteristicTiles,
        initiallyExpanded: true,
      );
    } else {
      return ListTile(
        title: Text('Service'),
        subtitle:
        Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }

  }
}

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;
  final VoidCallback onNotificationPressed;

  const CharacteristicTile(
      {Key key,
        this.characteristic,
        this.descriptorTiles,
        this.onReadPressed,
        this.onWritePressed,
        this.onNotificationPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<String> message=[];
    List<DateTime> _events = [];
    return StreamBuilder<List<int>>(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;

        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}'==
            '0x1504'){
          if(value.toString()=='[1]'){
            _events.insert(0, new DateTime.now());
            message.insert(0,'需更換');
            Firestore.instance.collection('NTUTLab321').document('${characteristic.deviceId.toString()}')
                .updateData({'change':value.toString().substring(1,2)});
            return
              ListView(
                shrinkWrap: true,
                children:<Widget>[
                  Card(
                    child: Row(
                        children: <Widget>[
                          Chip(label: Text('液面高度',
                              style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                          Container(
                              width: 100,
                              height: 20,
                              color: Colors.red
                          ),])
                    ,),
                  Container(
                    margin: const EdgeInsets.all(5),
                    color: Colors.black12,
                    height: 50,
                    child: new ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime timestamp = _events[index];
                        String message2=message[index];
                        Firestore.instance
                            .collection("NTUTLab321")
                            .document('${characteristic.deviceId.toString()}')
                            .updateData({'time': DateFormat("yyyy-MM-dd hh:mm:ss").format(_events[0])+message[0] });
                        return InputDecorator(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                                labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                                labelText: message2
                            ),
                            child: new Text(new DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp), style: TextStyle(color: Colors.black, fontSize: 16.0))
                        );
                      },
                    ),
                  ),
                ],);
          }else if(value.toString()=='[0]'){
            Firestore.instance.collection('NTUTLab321').document('${characteristic.deviceId.toString()}')
                .updateData({'change':value.toString().substring(1,2)});
            _events.insert(0, new DateTime.now());
            message.insert(0,'不需更換');
            return

              ListView(
                shrinkWrap: true,
                children:<Widget>[
                  Card(
                    child: Row(
                        children: <Widget>[
                          Chip(label: Text('液面高度',
                              style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                          Container(
                              width: 100,
                              height: 20,
                              color: Colors.green
                          ),])
                    ,),
                  Container(
                    margin: const EdgeInsets.all(5),
                    color: Colors.black12,
                    height: 50,
                    child: new ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime timestamp = _events[index];
                        String message2=message[index];
                        Firestore.instance
                            .collection("NTUTLab321")
                            .document('${characteristic.deviceId.toString()}')
                            .updateData({'time': DateFormat("yyyy-MM-dd hh:mm:ss").format(_events[0])+message[0] });
                        return InputDecorator(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                                labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                                labelText: message2
                            ),
                            child: new Text(new DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp), style: TextStyle(color: Colors.black, fontSize: 16.0))
                        );
                      },
                    ),
                  ),
                ],);
          }
          else{



          }

        }
        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}'==
            '0x1505'){
          if(value.toString()=='[1]'){
            _events.insert(0, new DateTime.now());
            message.insert(0,'點滴模式');
            Firestore.instance.collection('NTUTLab321').document('${characteristic.deviceId.toString()}')
                .updateData({'modedescription':"點滴"});
            return


              ListView(
                shrinkWrap: true,
                children:<Widget>[
                  Card(
                    child:
                    Row(
                        children: <Widget>[
                          Chip(label: Text('設備模式',
                              style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                          Container(
                            width: 100,
                            height: 20,
                            child:  Text('點滴模式'),
                          ),]
                    ),),
                  Container(
                    margin: const EdgeInsets.all(5),
                    color: Colors.black12,
                    height: 50,
                    child: new ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime timestamp = _events[index];
                        String message2=message[index];
                        Firestore.instance
                            .collection("NTUTLab321")
                            .document('${characteristic.deviceId.toString()}')
                            .updateData({'time': DateFormat("yyyy-MM-dd hh:mm:ss").format(_events[0])+message[0] });
                        return InputDecorator(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                                labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                                labelText: message2
                            ),
                            child: new Text(new DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp), style: TextStyle(color: Colors.black, fontSize: 16.0))
                        );
                      },
                    ),
                  ),
                ],);

          }else if(value.toString()=='[0]'){
            _events.insert(0, new DateTime.now());
            message.insert(0,'尿袋模式');
            Firestore.instance.collection('NTUTLab321').document('${characteristic.deviceId.toString()}')
                .updateData({'modedescription':"尿袋"});
            return
              ListView(
                shrinkWrap: true,
                children:<Widget>[
                  Card(
                    child:
                    Row(
                        children: <Widget>[
                          Chip(label: Text('設備模式',
                              style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                          Container(
                            width: 100,
                            height: 20,
                            child:  Text('尿袋模式'),
                          ),]
                    ),),
                  Container(
                    margin: const EdgeInsets.all(5),
                    color: Colors.black12,
                    height: 50,
                    child: new ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime timestamp = _events[index];
                        String message2=message[index];
                        Firestore.instance
                            .collection("NTUTLab321")
                            .document('${characteristic.deviceId.toString()}')
                            .updateData({'time': DateFormat("yyyy-MM-dd hh:mm:ss").format(_events[0])+message[0] });
                        return InputDecorator(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                                labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                                labelText: message2
                            ),
                            child: new Text(new DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp), style: TextStyle(color: Colors.black, fontSize: 16.0))
                        );
                      },
                    ),
                  ),
                ],);
          }
        }
        if ('0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}'==
            '0x1514'){

          return

            Card(
              child: Row(
                  children: <Widget>[
                    Chip(label: Text('剩餘電力',
                        style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                    Container(
                        width: 100,
                        height: 20,
                        color: Colors.green
                    ),])
              ,);

          //  }
          /*      if(value.toString()=='[85]'){
           //     if(power==85){
          //      Firestore.instance.collection('tests').document('1')
           //         .updateData({'power':value.toString().substring(1,3)});}
                return

                      Card(
                        child: Row(
                            children: <Widget>[
                              Chip(label: Text('剩餘電力',
                                  style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                              Container(
                                  width: 100,
                                  height: 20,
                                  color: Colors.yellow
                              ),])
                        ,);
              }
              if(value.toString()=='[81]'){

           //     Firestore.instance.collection('tests').document('1')
          //          .updateData({'power':value.toString().substring(1,3)});
                return

                      Card(
                        child: Row(
                            children: <Widget>[
                              Chip(label: Text('剩餘電力',
                                  style:TextStyle(color: Colors.black, fontSize: 20.0)),),
                              Container(
                                  width: 100,
                                  height: 20,
                                  color: Colors.red
                              ),])
                        ,);
              }*/
        }
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Characteristic'),
                Text(
                    '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                    style: Theme.of(context).textTheme.body1.copyWith(
                        color: Theme.of(context).textTheme.caption.color))
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.file_download,
                  color: Theme.of(context).iconTheme.color.withOpacity(0.5),
                ),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(Icons.file_upload,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                onPressed: onWritePressed,
              ),
              IconButton(
                icon: Icon(
                    characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.5)),
                onPressed: onNotificationPressed,
              )
            ],
          ),
          children: descriptorTiles,
        );
      },
    );
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback onReadPressed;
  final VoidCallback onWritePressed;

  const DescriptorTile(
      {Key key, this.descriptor, this.onReadPressed, this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Descriptor'),
          Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Theme.of(context).textTheme.caption.color)),
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.play_arrow,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}

class AdapterStateTile extends StatelessWidget {
  const AdapterStateTile({Key key, @required this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: ListTile(
        title: Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }
}

List<DropdownMenuItem> generateItemList() {
  List<DropdownMenuItem> items = new List();
  for(int i=1,j=1;i<=10;i++,j++){
    DropdownMenuItem i = new DropdownMenuItem(
        value:'0'+j.toString(), child: new Text(j.toString()+'室'));
    items.add(i);
  }
  return items;
}
List<DropdownMenuItem> generateItemList1() {
  List<DropdownMenuItem> items1 = new List();
  for(int k=1,m=1;k<=10;k++,m++){
    DropdownMenuItem k = new DropdownMenuItem(
        value: '0'+m.toString(), child: new Text(m.toString()+'床'));
    items1.add(k);
  }
  return items1;
}

List<DropdownMenuItem> generateItemList2() {
  List<DropdownMenuItem> items2 = new List();
  DropdownMenuItem item1 = new DropdownMenuItem(
      value: '0', child: new Text('尿袋'));
  DropdownMenuItem item2 = new DropdownMenuItem(
      value: '1', child: new Text('點滴'));

  items2.add(item1);
  items2.add(item2);
  return items2;
}                   