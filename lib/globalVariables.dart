import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wasalny/datamodels/driver.dart';
import 'package:wasalny/datamodels/user.dart';

String mapKey='AIzaSyBWIR4xpMnYGOx4YtBltOk4MyE0iJGUlw0';
final CameraPosition googlePlex = CameraPosition(
  target: LatLng(29.9970509256,31.1486147071),
  zoom: 14.4746,
);
FirebaseAuth? currentFireBaseUser;
Users? users;
Driver? driverData;
String tripStatusDisplay='Driver is Arriving';

late final driverlatSnap;
late final driverlongSnap;
late String driverlat;
late String driverlong;

var user;

String serverKey='key=AAAAuOqrbGU:APA91bEHzswHTxFOxnxeEfyj4RT-JCjKi8_Hi8_l_lf2PMQRPSqt6GDplxYbEVMdLFGDEqNMhzmz_oo6oTas0fXfNF_jbvc9UUk1SCdsnZ3bB2jbQCdtWi_64NFJ68xZZ7_8twoNkjOD ';

String? driverStatus;

var feedbackController=TextEditingController();
var fullName;
