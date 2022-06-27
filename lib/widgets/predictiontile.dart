import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/datamodels/address.dart';
import 'package:wasalny/datamodels/prediction.dart';
import 'package:wasalny/dataprovider/appdata.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/helpers/requesthelper.dart';
import 'package:wasalny/widgets/ProgressDialog.dart';

class PredictionTile extends StatelessWidget {
  late final Prediction prediction;
  PredictionTile({required this.prediction});

  Future<void> getPlaceDetails(String placeId,context) async {

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context)=>ProgressDialog(status: 'Please wait .....')
    );

    String url='https://maps.googleapis.com/maps/api/place/details/json?placeid=${placeId}&key=$mapKey';

    var response = await  RequestHelper.getRequest(url);
    Navigator.pop(context);


    if(response=='failed'){
      return;
    }

    if(response['status']=='OK'){
      Address thisPlace=Address(placeName: response['result']['name'], latitude: response['result']['geometry']['location']['lat'], longitude: response['result']['geometry']['location']['lng'], placeId: placeId, placeFormattedAddress: '');
      Provider.of<AppData>(context,listen: false).updateDestinationAddress(thisPlace);
      print(thisPlace.placeName);

      Navigator.pop(context,'getDirection');

    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8,),
            Row(
              children: [
                Icon(Icons.location_on_outlined,color: BrandColors.colorDimText,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prediction.mainText,overflow:TextOverflow.ellipsis ,maxLines:1 ,style: TextStyle(fontSize: 16,color: BrandColors.colorBlack)),
                      SizedBox(height: 2,),
                      Text(prediction.secondaryText,overflow:TextOverflow.ellipsis ,maxLines:1,style: TextStyle(fontSize: 12,color: BrandColors.colorDimText),),

                    ],
                  ),
                )

              ],
            ),
            SizedBox(height: 8,)
          ],
        ),
      ),
    );
  }
}