import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/datamodels/prediction.dart';
import 'package:wasalny/dataprovider/appdata.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/helpers/requesthelper.dart';
import 'package:wasalny/widgets/BrandDivider.dart';
import 'package:wasalny/widgets/predictiontile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
  static const String routName='serachpage';

}

class _SearchPageState extends State<SearchPage> {
  var pickupController=TextEditingController();
  var destinationController=TextEditingController();

  var focusDestination=FocusNode();

  bool focused=false;
  void setFocus(){
    if(!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused=true;
    }
  }

  List<Prediction> destinationPredictionList=[];

  void searchPlace(String placeName) async{
    if(placeName.length>1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123254251&components=country:eg';
      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }

    if(response['status']=='OK'){
      var predictionJson=response['predictions'];
      
      var thisList=(predictionJson as List).map((e) => Prediction.fromJson(e)).toList();

      setState(() {
        destinationPredictionList=thisList;
      });

    }
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    var address=Provider.of<AppData>(context).pickupAddress?.placeName ??'';
    pickupController.text=address;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    )
                  )
                ]
              ),
              child: Padding(
                padding:  EdgeInsets.only(left: 24,top: 48,right: 24,bottom: 20),
                child: Column(
                  children: [
                    SizedBox(height: 5,),
                    Stack(
                      children: [
                        GestureDetector(child: Icon(Icons.arrow_back),onTap: (){Navigator.pop(context);},),
                        Center(
                          child: Text('Set Destination',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),

                    SizedBox(height: 18),

                    Row(
                      children: [
                        Image.asset('assets/images/pickicon.png',height: 16,width:16 ,),
                        SizedBox(width: 18,),


                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColors.colorLightGray,
                              borderRadius: BorderRadius.circular(4),

                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(2.0),
                              child: TextField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                  hintText: 'Pickup location',
                                  fillColor: BrandColors.colorLightGray,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10,top: 8,bottom: 8),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: 10,),

                    Row(
                      children: [
                        Image.asset('assets/images/desticon.png',height: 16,width:16 ,),
                        SizedBox(width: 18,),


                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColors.colorLightGray,
                              borderRadius: BorderRadius.circular(4),

                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(2.0),
                              child: TextField(
                                onChanged: (value){
                                  searchPlace(value);
                                },
                                focusNode: focusDestination,
                                controller: destinationController,
                                decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: BrandColors.colorLightGray,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 10,top: 8,bottom: 8),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (destinationPredictionList.length>0)?
            Padding(
              padding:EdgeInsets.symmetric(vertical: 8 ,horizontal:16 ),
              child: ListView.separated(
                padding: EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    return PredictionTile(prediction: destinationPredictionList[index]);
                  },
                  separatorBuilder: (BuildContext context,int index)=>BranDivider(),
                itemCount: destinationPredictionList.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            )
                :Container(child: Text('empty'),),

          ],
        ),
      ),
    );
  }
}


