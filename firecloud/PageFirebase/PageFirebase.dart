import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firecloud/SecondPage.dart';
import 'package:intl/intl.dart';
import 'color.dart';

class PageFirebase extends StatefulWidget {
  @override
  _PageFirebase createState() => _PageFirebase();
}

class _PageFirebase extends State<PageFirebase> {
  
  //String myPatientnumber;
 bool soundsetting=true,vibrationsetting=true;
 String title;
 String modedescription,statedescription; //模式跟狀態
 List<String> message=[],soundcondition=['聲響開'],vibcondition=['震動開'];
 List<DateTime> _events = [];
 var selectItemValue,selectItemValue1,selectItemValue2;
 var blue;
 int power=0,i=0;
  @override

  Widget build(BuildContext context) {
     //     Firestore.instance.collection('tests').document('1')
      //      .updateData({'power': '10' });
     /*         Firestore.instance.collection('tests').document('1')
              .get().then((DocumentSnapshot) {
                print(DocumentSnapshot.data['power']);
          title=(DocumentSnapshot.data['title'].toString());
        //  power=DocumentSnapshot.data['power'];
          power=int.parse(DocumentSnapshot.data['power']);
          statedescription=(DocumentSnapshot.data['statedescription'].toString());         
          modedescription= (DocumentSnapshot.data['modedescription'].toString());});
          */
                Future update1() async {                       
                Firestore.instance.collection('NTUTLab321').document('1')
              .get().then((DocumentSnapshot) {
                print(DocumentSnapshot.data['power']);
          title=(DocumentSnapshot.data['title'].toString());
        //  power=DocumentSnapshot.data['power'];
          power=int.parse(DocumentSnapshot.data['power']);
          statedescription=(DocumentSnapshot.data['statedescription'].toString());         
          modedescription= (DocumentSnapshot.data['modedescription'].toString());});                     
          if(modedescription=='尿袋'){
            selectItemValue2='0';
             _events.insert(0, new DateTime.now());
               message.insert(0,'尿袋模式');
          }
          else{
            selectItemValue2='1';
             _events.insert(0, new DateTime.now());
               message.insert(0,'點滴模式');
            }
       /*     if(modedescription+statedescription=='尿袋1'||
          modedescription+statedescription=='點滴0'){
             Firestore.instance.collection('tests').document('1')
            .updateData({'change': '1' });  //change為1代表需要更換顯示紅色
          }
          else{
             Firestore.instance.collection('tests').document('1')
            .updateData({'change': '0' }); //change為0代表不需要更換顯示綠色
          }       */               
          }

          update1();      



         //  if(i==1){
          
        //    }//設定為尿袋或點滴模式,由硬體組開關決定

          

      //   i++;
         
      return Scaffold(
        
      appBar: AppBar(
        title:  Text('NTUTLab321 尿袋/點滴袋 智慧監控系統',
        style:TextStyle(color: Colors.black, fontSize: 14.0)),
        actions: <Widget>[
          IconButton(
          icon: Icon(Icons.menu),
          onPressed: (){
          Navigator.push(
                  //進到新畫面
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondPagewise(
             /*         time:_events,condition:message,
                      soundsetting: soundcondition,
                      virbationsetting: vibcondition,
                      blue:blue,*/
                    ),
                  ),  
        );},     
      ),
      ],),
      body:ListView(     
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
           if(selectItemValue!=null&&selectItemValue1!=null){
            Firestore.instance.collection('NTUTLab321').document('1')
            .updateData({'title': selectItemValue+'-'+selectItemValue1 });}
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
            Firestore.instance.collection('NTUTLab321').document('1')
            .updateData({'title': selectItemValue+'-'+selectItemValue1 });}
          });
        },
      ),
    );
  }),
            ])
            ),        
          ),

            Card(
            child: 
            Card(
              child: 
            Row(       
              children:<Widget>[
                Text('設備模式   ',
                style:TextStyle(color: Colors.black, fontSize: 20.0)),
          Builder(
        builder: (BuildContext context) {
      return DropdownButtonHideUnderline(
      child: new DropdownButton(
        hint: new Text('尿袋/點滴'),
        value: selectItemValue2,
        items: generateItemList2(),
        onChanged: (T){
          setState(() {
          });
        },
      ),
    );
  }),
  
            ])
            ),        
          ),
          Card(
              child: 
            Row(
              children:<Widget>[
         Expanded( 
          child: 
          Row(
            children: <Widget>[
          Chip(label: Text('液面高度',
          style:TextStyle(color: Colors.black, fontSize: 20.0)),),
          Container(
              width: 100,
              height: 20,
            color: getColor( modedescription,statedescription,
            soundcondition[0],vibcondition[0]),
              ),   

                       ])
            ),],),
          
          ),
          Card(
            child: 
            Card(child: 
            Row(children:<Widget>[
            Chip(label: Text("剩餘電力",
            style:TextStyle(color: Colors.black, fontSize: 20.0)),),
            Container(
              width: 100,
              height: 20,
          //  color: getColor1(power),
            )
            ])
            ),
          
          ),
          Card(
            child: ListTile(
              title: Text('光譜圖',
              style:TextStyle(color: Colors.black, fontSize: 20.0)),
            ),
          ),
         Container(
           margin: const EdgeInsets.all(20),
           color: Colors.black12,
           height: 400,
           child: new ListView.builder(
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime timestamp = _events[index];
                String message2=message[index];         
               Firestore.instance
              .collection("NTUTLab321")
              .document('1')
             .updateData({'time': DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp)+message[0] });
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
        ],
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
