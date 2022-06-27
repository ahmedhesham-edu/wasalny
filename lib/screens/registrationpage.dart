import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/datamodels/user.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/screens/cardetails.dart';
import 'package:wasalny/screens/loginpage.dart';
import 'package:wasalny/screens/mainpage.dart';
import 'package:wasalny/screens/otp.dart';
import 'package:wasalny/utils.dart';
import 'package:wasalny/widgets/ProgressDialog.dart';
import 'package:wasalny/widgets/taxibutton.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegistrationPage extends StatefulWidget {
  static const String routName='registrationPage';


  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>  {

  String dropdownValue = 'Chose car type.....';
  final items=['Automatic','Manual'];

  String? value;
  DropdownMenuItem<String> buildMenuItem(String item)=> DropdownMenuItem(child: Text(item),value: item,);

  bool isObscure = true;
  var fullNameController=TextEditingController();
  var phoneController=TextEditingController();
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  var nationalIdController=TextEditingController();
  var creditCardController=TextEditingController();
  var carLicenceNumberController=TextEditingController();

  File? identityVarification;
  final ImagePicker picker = ImagePicker();
  Future<void> getImage() async {
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        identityVarification = File(pickedFile.path);
      });

    } else {
      print('No Image Selected');
    }
    // final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    // if(result==null){
    //   final path=result!.files.single.path;
    //   setState(() {
    //     identityVarification=File(path!);
    //   });
    // }
  }
  customerClearImage() {
    identityVarification = null;
  }


  final GlobalKey<ScaffoldState> scaffoldKey= new GlobalKey<ScaffoldState>();
  void showSnackBar(String title){
    final snackbar =SnackBar(content: Text(title,textAlign: TextAlign.center,style: TextStyle(fontSize: 15),)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }



  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();

  void registerUser() async{
    showDialog(context: context,
        builder: (BuildContext context)=>ProgressDialog(status: 'Registering you ....'),
        barrierDismissible: false
    );
    //_auth.createUserWithEmailAndPassword(email: email, password: password);
    var user=(await _auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text).catchError((ex){
      //check error and display error
      Navigator.pop(context);
      PlatformException thisEx=ex;
      showSnackBar(thisEx.message!);
    })).user;
    Navigator.pop(context);
    /*try{
      showLoading(context);
      var result=user;
      hideLoading(context);
      if(user !=null){
        showMessage('user registered successfully', context);
      }
    }catch(error){
      hideLoading(context);
      showMessage(error.toString(), context);

    }*/
    //check if user registration is successful
    if(user!=null){
      DatabaseReference newUserRef=FirebaseDatabase.instance.ref().child('user/${user.uid}');
      final imagesRef = storageRef.child("rider/${user.uid}");
      //prepare data to saved on users table
      Map useMap={
        'fullName':fullNameController.text,
        'email':emailController.text,
        'phone':phoneController.text,
        'nationalId':nationalIdController.text,
        'creditCard':creditCardController.text,
        'carNumber':carLicenceNumberController.text,
        'idPhoto':identityVarification!.path,
      };
      newUserRef.set(useMap);

      uploadImage();
      //currentFireBaseUser=user as FirebaseAuth?;
      //take user to main page
      //Navigator.pushNamed(context, OTPController(phone: phoneController.text).routName);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>OTPController(phone: phoneController.text) ));
    }
  }

  updateProfile(BuildContext context) async {
    Map<String, dynamic> map = Map();
    if (identityVarification != null) {
      String url = await uploadImage();
      map['profileImage'] = url;
    }
    map['name'] = 'ahmed';

    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(FirebaseAuth.instance.currentUser.uid)
    //     .update(map);
    await FirebaseDatabase.instance.ref().child('user').update(map);

    Navigator.pop(context);
  }
  Future<String> uploadImage() async {
    String? basename=identityVarification!.path;
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("profile/ID Photo")
        .child(
        FirebaseAuth.instance.currentUser!.uid + "_" + 'rider/${_auth.currentUser!.uid}/photo')
        .putFile(identityVarification!);

    return taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        key: scaffoldKey,
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 70,),
                /*Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage('assets/images/logo.png'),
                ),*/
                SizedBox(height: 70,),

                Text('Create a an account',
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
                      //full name
                      TextField(
                        controller:fullNameController ,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person,color: BrandColors.colorYellow,),
                            labelText: 'Full name',
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
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 10,),

                      //email
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

                      //phone
                      TextField(
                        controller: phoneController,
                        maxLength: 11,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone number',
                            labelStyle: TextStyle(
                              fontSize: 14,
                                color: BrandColors.colorBlack
                            ),
                            hintStyle: TextStyle(
                              color: BrandColors.colorLightGray,
                              fontSize: 10,
                            ),
                          prefixIcon: Icon(Icons.phone,color: BrandColors.colorYellow,),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: BrandColors.colorGray),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      //SizedBox(height: 10,),

                      //password
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
                      SizedBox(height: 15,),
                      //nationalId
                      TextFormField(
                        maxLength: 14,
                        controller: nationalIdController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(MdiIcons.cardAccountDetails,color: BrandColors.colorYellow,),
                          labelText: 'National id',
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
                      ),

                      //SizedBox(height: 10,),

                      //CreditCard
                      TextFormField(
                        maxLength: 16,
                        controller: creditCardController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.credit_card,color: BrandColors.colorYellow,),
                          labelText: 'Credit card',
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
                      ),

                      //SizedBox(height: 10,),

                      //carLicenceNumber
                      // TextFormField(
                      //   controller: carLicenceNumberController,
                      //   keyboardType: TextInputType.text,
                      //   decoration: InputDecoration(
                      //     prefixIcon: Icon(MdiIcons.car,color: BrandColors.colorYellow,),
                      //     labelText: 'Car licence number',
                      //     labelStyle: TextStyle(
                      //         fontSize: 14,
                      //         color: BrandColors.colorBlack
                      //     ),
                      //     hintStyle: TextStyle(
                      //       color: BrandColors.colorLightGray,
                      //       fontSize: 10,
                      //     ),
                      //     focusedBorder: UnderlineInputBorder(
                      //       borderSide: BorderSide(color: BrandColors.colorGray),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(height: 20,),
                      Column(
                        children: [
                          Text(
                            'Please Upload a Picture of Identity Verification ',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Center(
                            child: identityVarification == null
                                ? Text('No Image Yet')
                                : CircleAvatar(
                              radius: 60.0,
                              backgroundImage: FileImage(identityVarification!),
                            ),
                          ),
                          identityVarification == null ? IconButton(
                            iconSize: 50.0,
                            icon: CircleAvatar(
                              backgroundColor: BrandColors.colorDimText,
                              radius: 60.0,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16.0,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (identityVarification == null)
                                  getImage();
                              });
                            },
                          ): IconButton(
                              onPressed: () {
                               setState(() {
                                 customerClearImage();
                               });
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      SizedBox(height: 20,),

                      ElevatedButton(
                        onPressed: () async {

                          //check network availability

                          var connectivityResult=await Connectivity().checkConnectivity();
                          if(connectivityResult!= ConnectivityResult.mobile && connectivityResult!= ConnectivityResult.wifi)
                            {
                              showSnackBar('No internet connectivity');
                              return;
                            }


                          if(fullNameController.text.length<3){
                            showSnackBar('Please enter valid full name');
                            return;
                          }
                          if(!emailController.text.contains('@')){
                            showSnackBar('Please enter a valid email');
                            return;
                          }
                          if(phoneController.text.length<11){
                            showSnackBar('Please enter valid phone number');
                            return;
                          }
                          if(passwordController.text.length<8){
                            showSnackBar('Password must be at least 8 characters');
                            return;
                          }
                          if(nationalIdController.text.length<14){
                            showSnackBar('please check your national id it must be 14 numbers');
                            return;
                          }
                          if(creditCardController.text.length<16){
                            showSnackBar('Please check your credit card number');
                            return;
                          }
                          registerUser();
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
                              'REGISTER',
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
                    Text('Already have a Rider account?'),
                    TextButton(
                      onPressed:(){Navigator.pushNamed(context, LoginPage.routName);},
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

/*class TaxiButton extends StatelessWidget {
  const TaxiButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        Navigator.pushNamed(context, LoginPage.routName);
      }, child: Text('Login'),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(BrandColors.colorOrange)
      ),
    );
  }
}*/
bool validateEmail(String value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(value);
}
