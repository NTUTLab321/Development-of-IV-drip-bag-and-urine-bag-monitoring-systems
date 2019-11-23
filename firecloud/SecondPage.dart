import 'package:flutter/material.dart';
//import 'PageSetting/Pagesetting.dart';
import 'Pagebluetooth/bluetooth.dart';

class SecondPagewise extends StatefulWidget {
 
 /* SecondPagewise({
      @required this.time,
      this.condition,
      this.soundsetting,
      this.virbationsetting,
      this.blue,
      }); //使用該字段的類型並初始化
  final time;
  final condition;
  final soundsetting;
  final virbationsetting;
  final blue;*/
  @override
  _SecondPagewise createState() => _SecondPagewise();
}

class _SecondPagewise extends State<SecondPagewise> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(tabs: [
              Tab(text: '藍芽'),         
         //     Tab(text: '設定'),
            ]),
          ),
          body: TabBarView(
            children: [
              PageBluetooth(),
         //     PageSetting(time: widget.time,condition: widget.condition,
        //      soundsetting: widget.soundsetting,
         //     virbationsetting: widget.virbationsetting,),             
            ],
          )),
    );
  }
}
