import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/screens/cardetails.dart';
import 'package:wasalny/screens/mainpage.dart';

class OTPController extends StatefulWidget {
  late String phone;
  OTPController({
    required this.phone
});

  @override
  State<OTPController> createState() => _OTPControllerState();
}

class _OTPControllerState extends State<OTPController> {
  final GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();
  final TextEditingController pinOTPCodeController=TextEditingController();
  final FocusNode pinOTPFocus=FocusNode();
  String? VarificationCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyPhoneNumber();
  }
  verifyPhoneNumber()async{
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+2-${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential)async{
          FirebaseAuth.instance.signInWithCredential(credential).then(
                  (value) =>{
                    if(value.user != null)
                      {
                        Navigator.pushNamed(context, MainPage.routName)
                      }
                  }
          );
        },
        verificationFailed: (FirebaseAuthException e){
          SnackBar(
            content:Text(e.message.toString()),
            duration: Duration(seconds: 3),
          );
        },
        codeSent: (String vID,int? resendToken){
          setState(() {
            VarificationCode=vID;
          });
        },
        codeAutoRetrievalTimeout: (String vID){
          setState(() {
            VarificationCode=vID;
          });
        },
      timeout: Duration(seconds: 60)

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.all(8),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Center(
              child: GestureDetector(
                onTap: (){
                  verifyPhoneNumber();
                },
                child: Text(
                  'Verifying : +2-${widget.phone}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(40),
            child: Pinput(
              length: 6,
              focusNode: pinOTPFocus,
              controller: pinOTPCodeController,
              pinAnimationType: PinAnimationType.rotation,
              onSubmitted: (pin) async {
                try{
                  await FirebaseAuth.instance.signInWithCredential(
                    PhoneAuthProvider.credential(verificationId: VarificationCode!, smsCode: pin))
                      .then((value) => {
                     if(value.user != null)
                       {
                         Navigator.pushNamed(context, CarInfoPage.routName)
                       }
                  });
                }
                catch(e){
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:Text('invalid OTP'),
                      duration: Duration(seconds: 3),
                    )
                  );
                }
              },

            ),
          ),
          ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, CarInfoPage.routName);
              },
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(BrandColors.colorYellow)
            ),
          )
        ],
      ),
    );
  }
}
