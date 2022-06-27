

import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {

  final String title;
  final Color color;
  var onPressed;

  TaxiButton({required this.title,required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25)
          ),
        ),
        backgroundColor: MaterialStateProperty.all(color),

      ),

      child: Container(
        height: 50,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold',color: Colors.black),
          ),
        ),
      ),
    );
  }
}
