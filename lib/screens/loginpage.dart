import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/screens/mainpage.dart';
import 'package:wasalny/screens/registrationpage.dart';
import 'package:wasalny/widgets/ProgressDialog.dart';
import 'package:wasalny/widgets/taxibutton.dart';

class LoginPage extends StatefulWidget {
  static const String routName='loginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;

  var emailController=TextEditingController();
  var passwordController=TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey= new GlobalKey<ScaffoldState>();
  void showSnackBar(String title){
    final snackbar =SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  final FirebaseAuth _auth=FirebaseAuth.instance;

  void Login()async{
    //show please wait dialog
    showDialog(context: context,
      builder: (BuildContext context)=>ProgressDialog(status: 'Logging you in'),
      barrierDismissible: false
    );

    var user=(await _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text).
    catchError((ex){
      //check error and display error
      Navigator.pop(context);
      PlatformException thisEx=ex;
      showSnackBar(thisEx.message!);
    })).user;

    if (user!= null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
    Navigator.pushNamed(context, MainPage.routName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              children: [
                //SizedBox(height: 10,),
                Image(
                  alignment: Alignment.center,
                  height: 300,
                  width: 300,
                  image: AssetImage('assets/images/wasalny.jpeg'),
                ),
                SizedBox(height: 70,),

                Text('Sign in as Rider',
                textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Brand-Bold'
                  ),
                ),

                Padding(
                  padding:  EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: BrandColors.colorBlack
                          ),
                          hintStyle: TextStyle(
                            color: BrandColors.colorLightGray,
                            fontSize: 10,
                          ),
                          prefixIcon: Icon(Icons.email_sharp,color: BrandColors.colorYellow,),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),


                      SizedBox(height: 10,),

                      TextFormField(
                        controller: passwordController,
                        obscureText: isObscure,//show/hide password
                        decoration: InputDecoration(
                          label: Text('Password'),
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: BrandColors.colorBlack
                          ),
                          prefixIcon: Icon(Icons.lock,color: BrandColors.colorYellow,),
                          suffixIcon: IconButton(
                            icon: isObscure ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                            onPressed:() {
                              setState(() {isObscure = !isObscure;});
                            },
                            color:BrandColors.colorYellow ,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          ),
                        ),
                      ),

                      SizedBox(height: 40,),

                      ElevatedButton(
                        onPressed: ()async{
                          //check network availability
                          var connectivityResult=await Connectivity().checkConnectivity();
                          if(connectivityResult!= ConnectivityResult.mobile && connectivityResult!= ConnectivityResult.wifi)
                          {
                            showSnackBar('No internet connectivity');
                            return;
                          }
                          if(!emailController.text.contains('@')){
                            showSnackBar('Please enter a valid email');
                            return;
                          }
                          if(passwordController.text.length<8){
                            showSnackBar('Password must be at least 8 characters');
                            return;
                          }
                          Login();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(BrandColors.colorYellow),
                          textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))

                          ),
                        ),
                        child: Container(
                          height: 50,
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold',color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account,'),
                    TextButton(
                      onPressed:(){Navigator.pushNamed(context, RegistrationPage.routName);},
                      child: Text('Register'),
                      style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(BrandColors.colorOrange)
                      ),
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
