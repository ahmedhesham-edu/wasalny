import 'package:flutter/material.dart';

bool validateEmail(String value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(value);
}
void showMessage(String message,BuildContext context){
  showDialog(context: context, builder: (buildContext){
    return AlertDialog(content: Text(message),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('Ok'))
      ],);
  });
}
void showLoading(BuildContext context){
  showDialog(context: context, builder: (BuildContext){
    return AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 12),
          Text('Loading....')
        ],
      ),
    );
  },
    barrierDismissible: false,
  );
}
void hideLoading(BuildContext context){
  Navigator.pop(context);
}