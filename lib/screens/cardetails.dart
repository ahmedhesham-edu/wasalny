import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/screens/mainpage.dart';
import 'package:wasalny/widgets/ProgressDialog.dart';
import 'package:wasalny/widgets/taxibutton.dart';

class CarInfoPage extends StatefulWidget {
  static const String routName='carInfoPage';
  const CarInfoPage({Key? key}) : super(key: key);

  @override
  State<CarInfoPage> createState() => _CarInfoPageState();
}

class _CarInfoPageState extends State<CarInfoPage> {

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldKey.currentState?.showSnackBar(snackbar);
  }


  void updateProfile(){

    currentFireBaseUser= FirebaseAuth.instance;
    var id=currentFireBaseUser?.currentUser!.uid;
    DatabaseReference driverRef=FirebaseDatabase.instance.ref().child('user/$id/vehicle_details');

    Map map={
      'car_color':carColorController.text,
      'car_model':carModelController.text,
      'vehicle_number':vehicleNumberController.text,
    };
    driverRef.set(map);


    //show please wait dialog

    Navigator.pushNamed(context, MainPage.routName);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/wasalny.jpeg',height: 200,width: 250,),
              Padding(
                padding:  EdgeInsets.fromLTRB(30,30,30,30),
                child: Column(
                    children: <Widget>[

                      SizedBox(height: 10,),

                      Text('Enter vehicle details', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),),

                      SizedBox(height: 25,),

                      TextField(
                        controller: carModelController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Car model',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: BrandColors.colorBlack
                          ),
                          hintStyle: TextStyle(
                            color: BrandColors.colorLightGray,
                            fontSize: 10,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),

                      SizedBox(height: 10.0),

                      TextField(
                        controller: carColorController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Car color',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: BrandColors.colorBlack
                          ),
                          hintStyle: TextStyle(
                            color: BrandColors.colorLightGray,
                            fontSize: 10,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          )
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),

                      SizedBox(height: 10.0),

                      TextField(
                        controller: vehicleNumberController,
                        keyboardType: TextInputType.text,
                        maxLength: 11,
                        decoration: InputDecoration(
                            labelText: 'Vehicle number',
                            labelStyle: TextStyle(
                                fontSize: 14,
                                color: BrandColors.colorBlack
                            ),
                          hintStyle: TextStyle(
                            color: BrandColors.colorLightGray,
                            fontSize: 10,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0),
                      ),

                      SizedBox(height: 40.0),


                      ElevatedButton(
                        onPressed: () async {
                          if(carModelController.text.length<3){
                            showSnackBar('Please provide a valid model');
                            return;
                          }
                          if(carColorController.text.length<3){
                            showSnackBar('Please provide a valid color');
                            return;
                          }
                          if(vehicleNumberController.text.length<3){
                            showSnackBar('Please provide a valid vehicle number');
                            return;
                          }

                          updateProfile();

                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(BrandColors.colorYellow),
                          textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                        ),
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Proceed',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold',color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      ]
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
