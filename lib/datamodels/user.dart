import 'package:firebase_database/firebase_database.dart';
import 'package:wasalny/globalVariables.dart';

class Users{
  late String? fullName;
  late String? email;
  late String? phone;
  late String? id;
  Users({
    required this.email,
    required this.fullName,
    required this.phone,
    required this.id,
});

}