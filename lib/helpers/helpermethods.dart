import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/datamodels/address.dart';
import 'package:wasalny/datamodels/directiondetails.dart';
import 'package:wasalny/datamodels/user.dart';
import 'package:wasalny/dataprovider/appdata.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/helpers/requesthelper.dart';
import 'package:http/http.dart'as http;

class HelperMethods{

  static void getCurrentUserInfo()async{
    currentFireBaseUser= FirebaseAuth.instance;
   // var userUid=currentFireBaseUser?.currentUser!.uid;
    var userUid=currentFireBaseUser?.currentUser?.uid;
    final userRef=FirebaseDatabase.instance.ref();

    final fullNameSnap= await userRef.child('user/$userUid/fullName').get();
    final emailSnap= await userRef.child('user/$userUid/email').get();
    final phoneSnap= await userRef.child('user/$userUid/phone').get();
    final idSnap= await userRef.child('user/$userUid').get();
    fullNameSnap!=fullName;
    users =Users(email: emailSnap.value.toString(), fullName: fullNameSnap.value.toString(), phone: phoneSnap.value.toString(), id: idSnap.value.toString() );


    userRef.once().then((DatabaseEvent databaseEvent){
      if(databaseEvent.snapshot != null){
        print('sheeeeeeeeeeeeeeesh ${users!.fullName}');
      }
    });
  }

  static Future<String> findCordinateAddress(Position position,context)async{
   var placeAddress='address22';
   var connectivityResult=await Connectivity().checkConnectivity();
   if(connectivityResult!= ConnectivityResult.mobile && connectivityResult!= ConnectivityResult.wifi)
   {
     return placeAddress;
   }
   String url='https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
   var response = await RequestHelper.getRequest(url);
   if(response!='failed'){
     placeAddress= response['results'][0]['formatted_address'];
     Address pickupAddress=Address(latitude: position.latitude,longitude: position.longitude,placeName: placeAddress,placeFormattedAddress: '',placeId: '');

     Provider.of<AppData>(context,listen: false).updatePickupAddress(pickupAddress);
   }
   return placeAddress;
  }

  static Future<DirectionDetails?> getDirectionDetails(LatLng startPosition,LatLng endPosition)async{
   String url='https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';
   var response = await RequestHelper.getRequest(url);

   if(response=='failed'){
     return null;
   }
   
   DirectionDetails directionDetails=DirectionDetails(
       distanceText: response['routes'][0]['legs'][0]['distance']['text'],
       durationValue: response['routes'][0]['legs'][0]['distance']['value'],

       durationText: response['routes'][0]['legs'][0]['duration']['text'],
       distanceValue: response['routes'][0]['legs'][0]['duration']['value'],

       encodingPoints: response['routes'][0]['overview_polyline']['points'],
   );
   return directionDetails;
  }

  static int estimateFair(DirectionDetails details){
    // km=0.7
    // time minute=0.5
    // base fare =3
    double baseFare=3;
    double distanceFare=(details.distanceValue/1000)*0.3;
    double timeFare=(details.durationValue/60)*0.2;

    double totalFare=baseFare+timeFare+distanceFare;

    return totalFare.truncate();
  }

  static double generateRandomNumber(int max){

    var randomGenerator=Random();
    int radInt=randomGenerator.nextInt(max);

    return radInt.toDouble();
  }

  static UploadTask? uploadFile(String destination,File file){
    try{
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch(e){
      return null;
    }
  }

  static sendNotification(String token,context,String ride_id)async{
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    Map<String,String> headerMap={
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };
    Map notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination, ${destination!.placeName}'
    };
    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id' : ride_id,
    };
    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };

    var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap,
        body:jsonEncode(bodyMap)
    );

    print(response.body);
  }

}