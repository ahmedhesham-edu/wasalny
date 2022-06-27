import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:outline_material_icons_tv/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:outline_material_icons_tv/outline_material_icons.dart';
import 'package:wasalny/datamodels/directiondetails.dart';
import 'package:wasalny/datamodels/driver.dart';
import 'package:wasalny/datamodels/nearbyDriver.dart';
import 'package:wasalny/datamodels/user.dart';
import 'package:wasalny/dataprovider/appdata.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/helpers/firehelper.dart';
import 'package:wasalny/helpers/helpermethods.dart';
import 'package:wasalny/rideVariables.dart';
import 'package:wasalny/screens/searchpage.dart';
import 'package:wasalny/styles/styles.dart';
import 'package:wasalny/widgets/BrandDivider.dart';
import 'package:wasalny/widgets/CollectPaymentDialog.dart';
import 'package:wasalny/widgets/NoDriverDialog.dart';
import 'dart:io';

import 'package:wasalny/widgets/ProgressDialog.dart';
import 'package:wasalny/widgets/taxibutton.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  static const String routName='mainPage';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>with TickerProviderStateMixin {


  List<LatLng> polylineCoordinates=[];
  Set<Polyline> _polylines={};
  Set<Marker> _Markers={};
  Set<Circle> _Circle={};


  BitmapDescriptor? nearbyIcon;


  GlobalKey<ScaffoldState> scaffoldKey= new GlobalKey<ScaffoldState>();

  double searchSheetHeight= (Platform.isIOS) ? 300 : 275;
  double rideDetailsSheet=0;//  (Platform.isIOS) ? 300 : 275

  double requestingSheetHeight=0;//  (Platform.isIOS) ? 195 : 220
  double tripSheetHeight=0;


  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  double mapBottomPadding=0;

  var geoLocator=Geolocator();
  late Position currentPosition;

  DirectionDetails? tripDirectionDetail;

  String appState='NORMAL';

  bool drawerCanOpen=true;

  late DatabaseReference rideRef;

   StreamSubscription<DatabaseEvent>? rideSubscription;

  late List<NearByDriver> availableDrivers;

  bool nearbyDriverKeysLoaded=false;

  bool isRequestingLocationDetails=false;
  //String Status='';

  //DatabaseReference statusRef=FirebaseDatabase.instance.ref().child('drivers/${driver.key}/status');




  void setupPositionLocator()async{
    Position position=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    currentPosition=position;

    LatLng pos=LatLng(position.latitude, position.latitude);
    CameraPosition cp= new CameraPosition(target: pos,zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    var address=HelperMethods.findCordinateAddress(position,context);
    print(address);
    startGeofireListener();
  }


  void showDetailsSheet()async{
    await getDirection();
    setState(() {
      searchSheetHeight=0;
      rideDetailsSheet=(Platform.isAndroid) ? 235 : 260;
      mapBottomPadding=(Platform.isAndroid) ? 240 : 230;
      drawerCanOpen=false;
    });
  }

  void showRequestingSheet()async{
    setState(() {
      rideDetailsSheet=0;
      requestingSheetHeight=(Platform.isAndroid)?195:220;
      mapBottomPadding=(Platform.isAndroid) ? 240 : 230;

      drawerCanOpen=true;
    });
    createRideRequest();
  }

  void showTripSheet(){
    setState(() {
      rideDetailsSheet=0;
      tripSheetHeight=(Platform.isAndroid)?250:300;
      mapBottomPadding=(Platform.isAndroid)?240:300;
    });
  }

  void createMarker(){
    if(nearbyIcon == null){
      ImageConfiguration imageConfiguration =createLocalImageConfiguration(context,size: Size(5, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration,'assets/images/person_pin.png').then((icon){
        setState(() {
          nearbyIcon =icon;
        });
      });
      
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();

  }
  @override
  Widget build(BuildContext context) {

    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding:EdgeInsets.all(0),
            children: [
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/user_icon.png',height: 60,width: 60,),
                      SizedBox(width: 15,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ahmed hesham',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),maxLines: 3,),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.phone),
                              SizedBox(width: 5,),
                              Text('01012989922')
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BranDivider(),

              SizedBox(height: 10,),

              ListTile(
                leading: Icon(Icons.contact_support,color: BrandColors.colorYellow,),
                title: Text('Support',style: kDrawerItemStyle,),
              ),
              ListTile(
                leading: Icon(Icons.info_outline,color: BrandColors.colorYellow,),
                title: Text('About',style: kDrawerItemStyle,),
              ),
              SizedBox(height: 500),
              TaxiButton(title: 'Logout', onPressed: (){}, color: Colors.red)



            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _Markers,
            circles: _Circle,
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
              mapController=controller;

              setState(() {
                mapBottomPadding=(Platform.isAndroid) ? 290:270;
              });

              setupPositionLocator();
            },
          ),

          ///MenuButton
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: (){
                if(drawerCanOpen)
                  {
                    scaffoldKey.currentState!.openDrawer();
                  }
                else{
                  resetApp();
                }
              },
              child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black26,
                     blurRadius: 5,
                     spreadRadius: 0.5,
                     offset: Offset(
                       0.7,
                       0.7,
                     )
                   ),
                 ],
               ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon((drawerCanOpen)?Icons.menu:Icons.arrow_back,color: BrandColors.colorYellow,),
                ),
              ),
            ),
          ),

          ///SearchSheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),),
                  boxShadow: [BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,

                  )
                  )
                  ]
                ),
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text('Nice to see you!',style: TextStyle(fontSize: 10),),
                      Text('Where are you going ?',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: ()async{
                          var response = await Navigator.pushNamed(context, SearchPage.routName);
                          if(response=='getDirection'){
                           showDetailsSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius:5,
                                spreadRadius: 0.5,
                                offset: Offset(
                                 0.7,
                                 0.7,
                                )
                              )
                            ]
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search,color: BrandColors.colorYellow,),
                                SizedBox(width: 10,),
                                Text('Search Destination'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                      Row(
                        children: [
                          Icon(Icons.home_outlined,color: BrandColors.colorDimText,),
                          SizedBox(width:12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Home'),
                              SizedBox(height: 3,),
                              Text('Your residential address',
                                style: TextStyle(fontSize: 11,color: BrandColors.colorDimText ),)
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      BranDivider(),
                      SizedBox(height: 16,),

                      Row(
                        children: [
                          Icon(Icons.work_outline,color: BrandColors.colorDimText,),
                          SizedBox(width:12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Work'),
                              SizedBox(height: 3,),
                              Text('Your office address',
                                style: TextStyle(fontSize: 11,color: BrandColors.colorDimText ),)
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ///RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight:Radius.circular(15) ),
                  boxShadow: [BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    )
                  )],
                ),
                height: rideDetailsSheet,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      Container(
                        width:double.infinity,
                        color: Colors.black12,
                        child: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset('assets/images/taxi.png',height: 70,width: 70,),
                              SizedBox(width: 16,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Driver name',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                  Text((tripDirectionDetail != null) ? tripDirectionDetail!.distanceText:'',style: TextStyle(fontSize: 16,color: BrandColors.colorDimText),),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetail != null) ?
                                '${HelperMethods.estimateFair(tripDirectionDetail!)}'
                                    :'empty'
                                ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),


                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyBill,size: 18,color: BrandColors.colorTextLight,),
                            SizedBox(width: 16,),
                            Text('Cash'),
                            SizedBox(width: 5,),
                            Icon(Icons.keyboard_arrow_down,color: BrandColors.colorTextLight,size: 16,),
                            SizedBox(height: 22,),
                          ],
                        ),
                      ),
                      SizedBox(height: 22,),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: (){
                            setState(() {
                              appState='REQUESTING';
                            });
                            showRequestingSheet();

                            availableDrivers=FireHelper.nearByDriverList;

                            findDriver();
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
                                'Request Driver ',
                                style: TextStyle(fontSize: 18,fontFamily: 'Brand-Bold',color: Colors.black),
                              ),
                            ),
                          ),
                          //child: Text('Request Driver'),

                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          ///Requesting ride Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: requestingSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),),
                    boxShadow: [BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,

                        )
                    )
                    ]
                ),
                child:
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 18,horizontal: 24 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),

                      DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('Requesting a Driver'),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,

                        ),
                      ),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: (){
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1,color: BrandColors.colorLightGrayFair),

                          ),
                          child: Icon(Icons.close,size: 25,),
                        ),
                      ),

                      SizedBox(height: 15,),

                      Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),

                    ],
                  ),
                ) ,
              ),
            ),
          ),

          ///Trip Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: tripSheetHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),),
                    boxShadow: [BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,

                        )
                    )
                    ]
                ),
                child:
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 18,horizontal: 24 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text(tripStatusDisplay,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                        ),
                        ],
                      ),

                      SizedBox(height: 15,),

                      BranDivider(),

                      SizedBox(height: 20,),

                    //Text('driverCarDetails', style: TextStyle(color: BrandColors.colorTextLight),),

                      Text((driverData==null)?'empty':
                        driverData!.fullName, style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.left,
                      ),

                      SizedBox(height: 20,),

                      BranDivider(),

                      SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
                                ),
                                child: Icon(Icons.call),
                              ),

                              SizedBox(height: 10,),

                              Text('Call'),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
                                ),
                                child: Icon(Icons.list),
                              ),

                              SizedBox(height: 10,),

                              Text('Details'),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular((25))),
                                  border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
                                ),
                                child: Icon(Icons.clear),
                              ),

                              SizedBox(height: 10,),

                              Text('Cancel'),
                            ],
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

   Future<void> getDirection()async{
    var pickup=Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination=Provider.of<AppData>(context,listen: false).destinationAddress;

    var pickLatLng=LatLng(pickup!.latitude, pickup.longitude);
    var destinationLatLng=LatLng(destination!.latitude, destination.longitude);

    showDialog(context: context, builder: (BuildContext context)=>ProgressDialog(status: 'please wait....'));

    var thisDetails=await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {

      tripDirectionDetail =thisDetails;

    });
    Navigator.pop(context);


    PolylinePoints polylinePoints=PolylinePoints();
    List<PointLatLng> results=polylinePoints.decodePolyline(thisDetails!.encodingPoints);

    polylineCoordinates.clear();
    if(results.isNotEmpty){
      //loop through all pointLatLng points and convert them
      //to list of LatLng required by polyLines
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude,point.longitude));
      });


    }
    _polylines.clear();
    setState(() {
      Polyline polyLine=Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyLine);

    });
    
    //make polyline to fit in the map
    
    LatLngBounds bounds;

    if(pickLatLng.latitude>destinationLatLng.latitude&& pickLatLng.longitude>destinationLatLng.longitude){
      bounds=LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    }
    else if(pickLatLng.longitude>destinationLatLng.longitude){
      bounds =LatLngBounds(
          southwest: LatLng(pickLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,pickLatLng.longitude)
      );
    }
    else if(pickLatLng.latitude>destinationLatLng.latitude){

      bounds =LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude,destinationLatLng.longitude)
      );

    }
    else{
      bounds =LatLngBounds(
          southwest: pickLatLng,
          northeast: destinationLatLng,
      );
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker=Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: pickup.placeName,snippet: 'My Location'),
    );
    Marker destinationMarker=Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: pickup.placeName,snippet: 'Destination'),
    );
    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });
    
    Circle pickupCircle=Circle(
        circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.green
    );
    Circle destinationCircle=Circle(
        circleId: CircleId('destination'),
        strokeColor: Colors.blueAccent,
        strokeWidth: 3,
        radius: 12,
        center: pickLatLng,
        fillColor: Colors.blueAccent
    );
    setState(() {
      _Circle.add(pickupCircle);
      _Circle.add(destinationCircle);
    });
  }

  void startGeofireListener() {
    Geofire.initialize('driversAvailable');
    Geofire.queryAtLocation(currentPosition.latitude,currentPosition.longitude, 5)?.listen(
            (map) {
      //.print('sheeeeeeeeeeeeeeeeeeeeeeeesh $map');
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:

            NearByDriver nearByDriver=NearByDriver(key: map['key'], latitude:map['latitude'], longitude: map['longitude']);

            FireHelper.nearByDriverList.add(nearByDriver);
            if(nearbyDriverKeysLoaded){
              updateDriverOnMap();
            }

            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriverOnMap();
            break;

          case Geofire.onKeyMoved:
          // Update your key's location
            NearByDriver nearByDriver=NearByDriver(key: map['key'], latitude:map['latitude'], longitude: map['longitude']);

            FireHelper.updateNearByLocation(nearByDriver);
            updateDriverOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyDriverKeysLoaded=true;
            updateDriverOnMap();
            break;
        }
      }
    });
  }
  Future<void> updateDriverOnMap() async {

    setState(() {
      _Markers.clear();
    });

    Set<Marker> tempMarkers=Set<Marker>();
    for(NearByDriver driver in FireHelper.nearByDriverList){
      
      LatLng driverPosition=LatLng(driver.latitude, driver.longitude);
      
      Marker thisMarker=Marker(markerId: MarkerId('driver${driver.key}'),
      position: driverPosition,
        icon: nearbyIcon!,
        rotation:HelperMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _Markers=tempMarkers;
    });
  }


  void createRideRequest() async{
    rideRef=FirebaseDatabase.instance.ref().child('rideRequest').push();

    var pickup=Provider.of<AppData>(context,listen: false).pickupAddress;
    var destination=Provider.of<AppData>(context,listen: false).destinationAddress;

    Map pickupMap={
      'latitude':pickup!.latitude.toString(),
      'longitude':pickup.longitude.toString(),
    };
    Map destinationMap={
      'latitude':destination!.latitude.toString(),
      'longitude':destination.longitude.toString(),
    };

    Map rideMap={
      'created_at':DateTime.now().toString(),
      'rider_name':users!.fullName,
      'rider_phone':users!.phone,
      'pickup_address':pickup.placeName,
      'destination_address':destination.placeName,
      'location':pickupMap,
      'destination':destinationMap,
      'payment_method':'card',
      'driver_id':'waiting',
    };
    rideRef.set(rideMap);



    rideSubscription=rideRef.onValue.listen((DatabaseEvent event) async{

      if(event.snapshot.value == null){
        print('no event');
        return;
      }
      final driverSnap = await FirebaseDatabase.instance.ref().child('rideRequest/${rideRef.key}/status').get();
      status2=driverSnap.value.toString();

      final driverlatSnap = await FirebaseDatabase.instance.ref().child('rideRequest/${rideRef.key}/driver_location/latitude').get();
      final driverlongSnap = await FirebaseDatabase.instance.ref().child('rideRequest/${rideRef.key}/driver_location/longitude').get();
      driverlat=driverlatSnap.value.toString();
      driverlong=driverlongSnap.value.toString();



      print('status22222 = ${driverData!.fullName}');
      print('$driverlat ----- $driverlong');


      if(status2 == 'accepted'){
        showTripSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }

      if(driverlat !=null && driverlong != null){
        double driverLat=double.parse(driverlat);
        double driverLong=double.parse(driverlong);
        LatLng driverLocation=LatLng(driverLat,driverLong);

        if(status2 == 'accepted'){
          updateToPickup(driverLocation);
        }
        else if(status2=='onTrip'){
          updateToDestination(driverLocation);
        }
        else if(status2=='arrived'){
          setState(() {
            tripStatusDisplay='Driver has arrived';
          });
        }
      }
      if(status2 == 'ended') {
        final fares = await FirebaseDatabase.instance.ref().child('rideRequest/${rideRef.key}/fares').get();
        int fare=int.parse(fares.value.toString());
        if (fare !=null) {

          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                CollectPayment(paymentMethod: 'cash', fares: fare,),
          );

          if (response == 'close') {
            rideRef.onDisconnect();
            rideSubscription?.cancel();
            rideSubscription = null;
            resetApp();
          }
        }
      }

    });

  }
  void removeGeofireMarkers(){
    setState(() {
      _Markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }
  void updateToPickup(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var positionLatLng = LatLng(
          currentPosition.latitude, currentPosition.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(
          driverLocation, positionLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }
  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var destination=Provider.of<AppData>(context,listen: false).destinationAddress;
      var destinationLatLng=LatLng(destination!.latitude, destination.longitude);
      var thisDetails = await HelperMethods.getDirectionDetails(driverLocation, destinationLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void cancelRequest(){
    rideRef.remove();
    setState(() {
      appState='NORMAL';
    });
  }

  resetApp(){
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circle.clear();
      rideDetailsSheet=0;
      tripSheetHeight=0;
      requestingSheetHeight=0;
      searchSheetHeight=(Platform.isAndroid)? 275:300;
      mapBottomPadding=(Platform.isAndroid)?280:300;
      drawerCanOpen=true;

      status2='';
      driverData?.fullName='';
      driverData?.phone='';
      tripStatusDisplay='Driver is Arriving';


    });


    setupPositionLocator();


  }

  void noDriverFound(){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context)=>NoDriverDialog()
    );
  }

  void findDriver(){

    if(availableDrivers.length==0){
      cancelRequest();
      resetApp();
      noDriverFound();

      return;
    }

    var driver = availableDrivers[0];

    notifyDriver(driver);

    availableDrivers.removeAt(0);

    print('driver key = ${driver.key}');

  }

  void notifyDriver(NearByDriver driver)async{
    final statusRef=FirebaseDatabase.instance.ref();
    // DatabaseReference status= FirebaseDatabase.instance.ref().child('drivers/${driver.key}/status');
    // driverStatus=status.toString();
    // print('sheeeeeeeeeeeeeesh driver $driverStatus');
    DatabaseReference driverTripRef = FirebaseDatabase.instance.ref().child('drivers/${driver.key}/newtrip');

    //driver data
    final driverFullNameSnap = await FirebaseDatabase.instance.ref().child('drivers/${driver.key}/fullName').get();
    final driverPhoneSnap = await FirebaseDatabase.instance.ref().child('drivers/${driver.key}/phone').get();
    driverData= Driver(fullName: driverFullNameSnap.value.toString(), phone: driverPhoneSnap.value.toString(),key: driver.key);

    driverTripRef.set(rideRef.key);

    // get and notify driver using token
    DatabaseReference tokenRef=FirebaseDatabase.instance.ref().child('drivers/${driver.key}/token');

    tokenRef.once().then((DatabaseEvent databaseEvent) {
      if(databaseEvent.snapshot.value != null){
        String token=databaseEvent.snapshot.value.toString();
        
        //send notification to driver
        HelperMethods.sendNotification(token, context, rideRef.key!);
      }
      else{
        return;
      }

      const oneSecTick=Duration(seconds: 1);

      var timer=Timer.periodic(oneSecTick, (timer) {

        // stop timer when ride request is cancelled
        if(appState != 'REQUESTING'){
          driverTripRef.set('cancelled');
          timer.cancel();
          driverRequestTimeout=30;
        }

        //timer count for tell us how many seconds that the request has been open for
        driverRequestTimeout --;

        // value event listener for driver accepting trip request
        driverTripRef.ref.onValue.listen((event) {
          if(event.snapshot.value.toString() == 'accept'){
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeout=30;
          }
          status=event.snapshot.value.toString();

        }

        );
        if(driverRequestTimeout==0){
          //tell the driver that ride has timed out
          driverTripRef.set('timeOut');
          driverTripRef.onDisconnect();
          driverRequestTimeout=30;
          timer.cancel();

          //select the next closes driver
          findDriver();

        }

      });

    });

  }

}
