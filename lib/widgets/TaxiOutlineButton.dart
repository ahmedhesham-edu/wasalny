import 'package:flutter/material.dart';
import 'package:wasalny/brand_colors.dart';

class TaxiOutlineButton extends StatelessWidget {

  final String title;
  var onPressed;
  final Color color;

  TaxiOutlineButton({required this.title, required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        //borderSide: MaterialStateProperty.all(BorderSide(color: color),)
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0),
        ),
        ),
        textStyle: MaterialStateProperty.all(TextStyle(
          color: color
        )),
          overlayColor: MaterialStateProperty.all(BrandColors.colorGray)
      ),


        onPressed: onPressed,
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: BrandColors.colorText)),
          ),
        )
    );
  }
}


