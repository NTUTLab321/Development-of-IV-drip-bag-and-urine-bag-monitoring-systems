import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';


Color getColor(var mode,var state,var sound,var vibration) {
  if (mode=='尿袋') //狀態選擇:尿袋
  {
    if(state == '0'){  //液面狀態:空 -->正常
    return Colors.greenAccent;}
    else if (state=='1'){
    return Colors.redAccent;  //液面狀態:滿 -->需更換
    }
    else{
      return Colors.black12;
    }
  } else {                //狀態選擇:點滴
     if(state == '0'){
      //液面狀態:空 -->需更換
    return Colors.redAccent;}
    else{
    return Colors.greenAccent;  //液面狀態:滿 -->正常
    }
    
  }
}


Color getColor1(int selector,var sound,var vibration) {
  if ( selector>51){
    return Colors.green;
  }
  else if (selector>25){
    return Colors.yellow;
  }
  else if(selector>1){
    return Colors.red;
  }
  else{
    return Colors.black12;
  }
}
/*
Color getColor2(var selector, var selector1,var selector2,var count) {
  if (selector1 + selector2 == '01') {
    return Colors.green;
    
  } else {
      Vibration.vibrate(pattern: [1000,5000,50000]);
    /*  Fluttertoast.showToast(  
        msg: selector+"需要注意",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 30,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 30.0
    );*/
    FlutterRingtonePlayer.play(
     android: AndroidSounds.alarm,
     ios: IosSounds.glass,
     looping: true,
     volume: 0.3,);
    return Colors.red;
  }
}
/*Vibration getVirbration (var count,var patientnumber)
{
    while(count==0){

}
return null;
}
data(var newValues){
  var j=0;
  var i='patient0';

        while(newValues!=i)
        {
          j++;
          i='patient'+j.toString();        
        }
        return j.toString();

}*/*/