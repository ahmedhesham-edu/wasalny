import 'package:wasalny/datamodels/nearbyDriver.dart';

class FireHelper{
  static List<NearByDriver> nearByDriverList=[];


  static void removeFromList(String key){
    int index=nearByDriverList.indexWhere((element) => element.key==key);
    nearByDriverList.remove(index);

  }
  static void updateNearByLocation(NearByDriver driver){
    int index=nearByDriverList.indexWhere((element) => element.key==driver.key);
    nearByDriverList[index].longitude=driver.longitude;
    nearByDriverList[index].latitude=driver.latitude;

  }
}