import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class OrganisationsModel extends ChangeNotifier {
  int _organisations = 0;
  int get organisations => _organisations;

  void login(String username, String password) {
    notifyListeners();
  }
}

class Organisation {
  final String organisationId;
  final String organisationName;
  final String telephone;
  final String email;
  final String contactEmail;
  final int licenses;
  final String address;
  final String postCode;
  final String vatRegNo;
  final double latitude;
  final double longitude;
  final String sortCode;
  final String accountNumber;
  final String accountName;
  final String accountBank;
  String logo;


  Organisation(
      {@required this.organisationId,
        @required this.organisationName,
        @required this.telephone,
        @required this.email,
        @required this.contactEmail,
        @required this.licenses,
        @required this.address,
        @required this.postCode,
        @required this.vatRegNo,
        @required this.latitude,
        @required this.longitude,
        @required this.logo,
        @required this.sortCode,
        @required this.accountNumber,
        @required this.accountName,
        @required this.accountBank,
      });
}
