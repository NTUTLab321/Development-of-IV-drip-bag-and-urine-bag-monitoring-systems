import 'package:flutter/material.dart';

class PageSetting extends StatefulWidget {
  PageSetting({
      @required this.time,
      this.condition, 
      this.soundsetting,
      this.virbationsetting,
      }); //使用該字段的類型並初始化
  final time;
  final condition;
  final soundsetting;
  final virbationsetting;
  
  @override
  _PageSetting createState() => _PageSetting();
}

class _PageSetting extends State<PageSetting> {
  bool _condition=true;  //預設都為開
  bool _condition1=true;
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child:
            SwitchListTile(
            value: _condition,
            title:Text('聲響設定',style:TextStyle(color: Colors.black, fontSize: 16.0)),
            subtitle: Text(_condition ? '聲響開':'聲響關',
            style:TextStyle(color: Colors.black, fontSize: 16.0)),
            onChanged: (bool value){
              setState(() {
             _condition=value;
            });},
          )
          ),
          Card(
            child:
            SwitchListTile(
            value: _condition1,
            title:Text('震動設定'),
            subtitle: Text(_condition1 ? '震動開':'震動關',
            style:TextStyle(color: Colors.black, fontSize: 16.0)),          
            onChanged: (bool value){
              setState(() {
             _condition1=value;
            });},
          )
          ),
           RaisedButton(
            child: Text('HomePage'),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            onPressed: () { 
           //   widget.time.insert(0, new DateTime.now());
              if(_condition1==true){ 
                 widget.time.insert(0, new DateTime.now());              
               widget.condition.insert(0,'震動開');  
               widget.virbationsetting.insert(0,'震動開');          
             }
             else{
                widget.time.insert(0, new DateTime.now());
               widget.condition.insert(0,'震動關');
               widget.virbationsetting.insert(0,'震動關'); 
             }
             if(_condition==true){    
                widget.time.insert(0, new DateTime.now());           
               widget.condition.insert(0,'聲響開');
               widget.soundsetting.insert(0,'聲響開');            
             }
             else{
                widget.time.insert(0, new DateTime.now());
               widget.condition.insert(0,'聲響關');
               widget.soundsetting.insert(0,'聲響關'); 
             }
              Navigator.pop(context);}       
          ),       
          ]
          ),
          );
          }
          }