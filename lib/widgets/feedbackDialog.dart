import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasalny/brand_colors.dart';
import 'package:wasalny/datamodels/nearbyDriver.dart';
import 'package:wasalny/globalVariables.dart';
import 'package:wasalny/widgets/BrandDivider.dart';
import 'package:wasalny/widgets/taxibutton.dart';

class FeedbackDialog extends StatelessWidget {
  static const String routName='feedbackRout';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: 20,),

            Text('Feedback'),

            SizedBox(height: 20,),

            BranDivider(),

            SizedBox(height: 16.0,),

            TextFormField(
              controller: feedbackController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Write your feedback',
                labelStyle: TextStyle(
                    fontSize: 14,
                    color: BrandColors.colorBlack
                ),
                hintStyle: TextStyle(
                  color: BrandColors.colorLightGray,
                  fontSize: 10,
                ),
                prefixIcon: Icon(Icons.feedback_outlined,color: BrandColors.colorYellow,),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: BrandColors.colorGray),
                ),
              ),
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Write you feedback about the driver', textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30,),

            Container(
              width: 230,
              child: TaxiButton(
                title: 'Send Feedback',
                color: BrandColors.colorYellow,
                onPressed: ()async{

                  Navigator.pop(context,'close');
                  DatabaseReference feedback= await FirebaseDatabase.instance.ref().child('drivers/${driverData?.key}/feedbacks');
                  feedback.set(feedbackController);
                },
              ),
            ),

            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}
