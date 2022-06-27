import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/dataprovider/appdata.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/screens/cardetails.dart';
import 'package:wasalny/screens/loginpage.dart';
import 'package:wasalny/screens/mainpage.dart';
import 'package:wasalny/screens/registrationpage.dart';
import 'package:wasalny/screens/searchpage.dart';
import 'package:wasalny/widgets/feedbackDialog.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  user = await FirebaseAuth.instance.currentUser;
  runApp( MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:(context)=>AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          LoginPage.routName:(buildContext)=>LoginPage(),
          RegistrationPage.routName:(buildContext)=>RegistrationPage(),
          MainPage.routName:(buildContext)=>MainPage(),
          SearchPage.routName:(buildContext)=>SearchPage(),
          CarInfoPage.routName:(buildContext)=>CarInfoPage(),
          FeedbackDialog.routName:(buildContext)=>FeedbackDialog(),
        },
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Brand-Regular'
        ),
        initialRoute:(user==null)?LoginPage.routName:
        MainPage.routName
      ),
    );
  }
}

