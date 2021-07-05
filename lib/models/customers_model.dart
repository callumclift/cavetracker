//import 'package:flutter/material.dart';
//import 'dart:convert';
//import 'dart:async';
//import 'package:http/http.dart' as http;
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:connectivity/connectivity.dart';
//import 'package:caving_app/services/navigation_service.dart';
//import '../locator.dart';
//import '../shared/global_config.dart';
//import '../shared/global_functions.dart';
//import '../utils/database_helper.dart';
//import './authentication_model.dart';
//import '../shared/strings.dart';
//import '../constants/route_paths.dart' as routes;
//
//class CustomersModel extends ChangeNotifier {
//
//  AuthenticationModel authenticationModel = AuthenticationModel();
//  final NavigationService _navigationService = locator<NavigationService>();
//
//
//  CustomersModel(this.authenticationModel);
//
//  bool _isLoading = false;
//  bool _shouldUpdateCustomers = false;
//  List<Customer> _customers = [];
//  String _selCustomerId;
//  String _uploadingMessage = '';
//  String _searchControllerValue = '';
//
//  bool get isLoading => _isLoading;
//  bool get shouldUpdateCustomers => _shouldUpdateCustomers;
//  String get selectedCustomerId => _selCustomerId;
//  String get uploadingMessage => _uploadingMessage;
//  String get searchControllerValue => _searchControllerValue;
//
//
//  List<Customer> get allCustomers {
//    return List.from(_customers);
//  }
//
//  int get selectedCustomerIndex {
//    return _customers.indexWhere((Customer customer) {
//      return customer.documentId == _selCustomerId;
//    });
//  }
//
//  Customer get selectedCustomer {
//    if (_selCustomerId == null) {
//      return null;
//    }
//    return _customers.firstWhere((Customer customer) {
//      return customer.documentId == _selCustomerId;
//    });
//  }
//
//  void setShouldUpdateCustomers(bool value){
//    _shouldUpdateCustomers = value;
//  }
//
//  void setSearchControllerValue(String value){
//    _searchControllerValue = value;
//  }
//
//  void selectCustomer(String customerId) {
//    _selCustomerId = customerId;
//    if (customerId != null) {
//      notifyListeners();
//    }
//  }
//
//  void changeUploadingMessage(String message) {
//    _uploadingMessage = message;
//    if (uploadingMessage != null) {
//      notifyListeners();
//    }
//  }
//
//
//
//
//
//
//  Future<void> addEditCustomer(bool edit, String prefix, String firstName, String lastName, String address, String postcode, String telephone,
//      String mobile, String email) async {
//
//    _isLoading = true;
//    notifyListeners();
//    bool hasDataConnection = await GlobalFunctions.hasDataConnection('No data connection, unable to ${edit ? 'edit' : 'add'} Customer');
//
//    if(hasDataConnection) {
//
//      //Check the expiry time on the token before making the request
//      bool isTokenExpired = GlobalFunctions.isTokenExpired();
//      bool authenticated = true;
//
//      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();
//
//      if(authenticated){
//
//        try {
//
//          if(firstName.length == 1){
//            firstName = firstName.toUpperCase();
//          } else if(firstName.length > 1) {
//            firstName = firstName.trim();
//            firstName = '${firstName[0].toUpperCase()}${firstName.substring(1)}';
//          }
//
//          if(lastName.length == 1){
//            lastName = lastName.trim();
//            lastName = lastName.toUpperCase();
//          } else if(lastName.length > 1){
//            lastName = '${lastName[0].toUpperCase()}${lastName.substring(1)}';
//          }
//
//
//          Map<String, dynamic> customerInfo = {
//            Strings.organisationId : user.organisationId,
//            Strings.prefix: prefix,
//            Strings.firstName: firstName,
//            Strings.firstNameLowercase: firstName.toLowerCase(),
//            Strings.lastName: lastName,
//            Strings.lastNameLowercase: lastName.toLowerCase(),
//            Strings.fullName: firstName + ' ' + lastName,
//            Strings.fullNameLowercase: firstName.toLowerCase() + ' ' + lastName.toLowerCase(),
//            Strings.address : address,
//            Strings.postCode : postcode,
//            Strings.telephone : telephone,
//            Strings.mobile : mobile,
//            Strings.email : email,
//            Strings.customerJobOutstanding : false,
//          };
//
//          DocumentReference ref;
//
//          if(edit){
//
//            await FirebaseFirestore.instance.collection('customers').doc(selectedCustomer.documentId).update(customerInfo).timeout(Duration(seconds: 60));
//            await addUpdateCustomerLocally(selectedCustomer.documentId, customerInfo);
//
//          } else {
//
//            ref = await FirebaseFirestore.instance.collection('customers').add(customerInfo).timeout(Duration(seconds: 60));
//            DocumentSnapshot snapshot = await ref.get();
//            Map<String, dynamic> snapshotData = snapshot.data();
//            await addUpdateCustomerLocally(snapshot.id, snapshotData);
//
//          }
//
//          GlobalFunctions.showToast('Customer ${edit ? 'edited' : 'added'} Successfully');
//
//          _navigationService.goBack();
//          if(edit){
//            _navigationService.goBack();
//
//          } else {
//            _navigationService.navigateTo(routes.CustomersRoute);
//
//          }
//          getCustomers();
//          selectCustomer(null);
//
//        } on TimeoutException catch (_) {
//
//          GlobalFunctions.showToast('Network Timeout communicating with the server, unable to ${edit ? 'edit' : 'add'} Customer');
//          _navigationService.goBack();
//
//
//        } catch(e){
//          print(e);
//          GlobalFunctions.showToast('Something went wrong. Please try again');
//          _navigationService.goBack();
//
//        }
//
//      }
//
//    } else {
//      _navigationService.goBack();
//
//    }
//
//    _isLoading = false;
//    notifyListeners();
//
//  }
//
//
//  Future<void> getCustomers() async{
//
//    print('getting customets');
//
//    _isLoading = true;
//    notifyListeners();
//    _shouldUpdateCustomers = false;
//
//    List<Customer> _fetchedCustomersList = [];
//    DatabaseHelper databaseHelper = DatabaseHelper();
//
//    try {
//
//      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
//
//      if (connectivityResult == ConnectivityResult.none) {
//
//        int localChecklistCount;
//
//        localChecklistCount = await databaseHelper.getRowCountWhere(Strings.customersTable, Strings.organisationId, user.organisationId);
//
//        if (localChecklistCount > 0) {
//
//          List<Map<String, dynamic>> localRecords = [];
//
//          localRecords = await databaseHelper.getCustomersLocally(user.organisationId);
//
//          if(localRecords.length >0){
//
//            for (Map<String, dynamic> localRecord in localRecords) {
//              final Customer customer = getLocalCustomer(localRecord);
//              _fetchedCustomersList.add(customer);
//
//            }
//
//            _fetchedCustomersList.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//
//            _fetchedCustomersList.forEach((Customer cust){
//              print(cust.fullName);
//            });
//
//            if(_fetchedCustomersList.length <= 20){
//              _customers = _fetchedCustomersList;
//
//            } else {
//              _customers = _fetchedCustomersList.sublist(0, 20);
//
//            }
//
//            GlobalFunctions.showToast('No data connection, unable to fetch latest Customers');
//
//          }
//
//        } else {
//          GlobalFunctions.showToast('No Customers available, please try again when you have a data connection');
//          _customers = [];
//        }
//      } else {
//
//        bool isTokenExpired = GlobalFunctions.isTokenExpired();
//        bool authenticated = true;
//
//        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();
//
//        if(authenticated){
//
//          QuerySnapshot snapshot;
//
//          try {
//            snapshot =
//            await FirebaseFirestore.instance.collection('customers').where(
//                'organisation_id',
//                isEqualTo: user.organisationId).orderBy('full_name', descending: false).limit(20)
//                .get()
//                .timeout(Duration(seconds: 90));
//          } catch(e) {
//            print(e);
//          }
//
//          Map<String, dynamic> snapshotData = {};
//
//          if(snapshot.docs.length < 1){
//
//            GlobalFunctions.showToast('No Customers found');
//
//          } else {
//            for (DocumentSnapshot snap in snapshot.docs) {
//              snapshotData = snap.data();
//              final Customer customer = getFirebaseCustomer(snap.id, snapshotData);
//              _fetchedCustomersList.add(customer);
//              await addUpdateCustomerLocally(snap.id, snapshotData);
//            }
//
//            _fetchedCustomersList.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//
//            _customers = _fetchedCustomersList;
//          }
//
//        }
//
//      }
//
//    } on TimeoutException catch (_) {
//      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Customers');
//    } catch(e){
//      print(e);
//      GlobalFunctions.showToast('Something went wrong. Please try again');
//    }
//
//    _isLoading = false;
//    notifyListeners();
//    _selCustomerId = null;
//
//  }
//
//  Future<void> getMoreCustomers() async{
//
//    notifyListeners();
//    List<Customer> _fetchedCustomersList = [];
//    DatabaseHelper databaseHelper = DatabaseHelper();
//
//
//    try {
//
//
//      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
//
//      if (connectivityResult == ConnectivityResult.none) {
//
//        int localChecklistCount = await databaseHelper.getRowCountWhere(Strings.customersTable, Strings.organisationId, user.organisationId);
//
//        if (localChecklistCount == _customers.length) {
//
//          GlobalFunctions.showToast('No more Customers to fetch');
//
//        } else if (localChecklistCount > 0) {
//
//          List<Map<String, dynamic>> localRecords = [];
//
//          localRecords = await databaseHelper.getCustomersLocally(user.organisationId);
//
//          if(localRecords.length > 0){
//
//            for (Map<String, dynamic> localRecord in localRecords) {
//
//              final Customer customer = getLocalCustomer(localRecord);
//
//              _fetchedCustomersList.add(customer);
//
//            }
//
//            _fetchedCustomersList.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//
//            List<Customer> _currentCustomers = _fetchedCustomersList;
//            List<Customer> _newCustomers = _currentCustomers;
//
//            _currentCustomers.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//
//            _customers = _newCustomers;
//
//          } else {
//            GlobalFunctions.showToast('No more Customers to fetch');
//          }
//
//        } else {
//
//          GlobalFunctions.showToast('No Customers available, please try again when you have a data connection');
//        }
//      } else {
//
//        //Check the expiry time on the token before making the request
//        bool isTokenExpired = GlobalFunctions.isTokenExpired();
//        bool authenticated = true;
//
//        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();
//
//        if(authenticated){
//
//          QuerySnapshot snapshot;
//          int currentLength = _customers.length;
//
//          String latestCustomer = _customers[currentLength - 1].fullName;
//
//          try {
//            snapshot =
//            await FirebaseFirestore.instance.collection('customers').where(
//                'organisation_id',
//                isEqualTo: user.organisationId).orderBy('full_name', descending: false).startAfter([latestCustomer]).limit(20)
//                .get()
//                .timeout(Duration(seconds: 20));
//          } on TimeoutException catch (_) {
//            GlobalFunctions.showToast('Network Timeout communicating with the server, please try again');
//          } catch(e) {
//            print(e);
//          }
//
//
//          Map<String, dynamic> snapshotData = {};
//
//          if(snapshot.docs.length < 1){
//            GlobalFunctions.showToast('No more Customers to fetch');
//          } else {
//
//            for (DocumentSnapshot snap in snapshot.docs) {
//              snapshotData = snap.data();
//              final Customer customer = getFirebaseCustomer(snap.id, snapshotData);
//              _fetchedCustomersList.add(customer);
//              await addUpdateCustomerLocally(snap.id, snapshotData);
//            }
//
//            _fetchedCustomersList.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//            _customers.addAll(_fetchedCustomersList);
//
//          }
//
//        }
//
//      }
//
//
//    } on TimeoutException catch (_) {
//      // A timeout occurred.
//      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Customers');
//    } catch(e){
//      print(e);
//      GlobalFunctions.showToast('Something went wrong. Please try again');
//
//    }
//
//    notifyListeners();
//    _selCustomerId = null;
//
//  }
//
//
//
//  Future<void> deleteCustomer() async{
//
//    _isLoading = true;
//    notifyListeners();
//
//    bool hasDataConnection = await GlobalFunctions.hasDataConnection('No data connection, unable to delete Customer');
//
//    if(hasDataConnection){
//
//      bool isTokenExpired = GlobalFunctions.isTokenExpired();
//      bool authenticated = true;
//
//      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();
//
//      if(authenticated){
//
//        try {
//
//          await FirebaseFirestore.instance.collection('customers').doc(selectedCustomerId).delete();
//
//          DatabaseHelper databaseHelper = DatabaseHelper();
//          int queryResult = await databaseHelper.delete(Strings.customersTable, selectedCustomerId);
//
//          if(queryResult != 0){
//            GlobalFunctions.showToast('Customer Deleted');
//            await getCustomers();
//          }
//
//
//
//        } on TimeoutException catch (_) {
//
//          GlobalFunctions.showToast('Network Timeout communicating with the server, unable to delete Customer');
//
//        } catch (error) {
//          print(error);
//        }
//
//      }
//
//    }
//
//    _isLoading = false;
//    notifyListeners();
//
//  }
//
//
//
//  Future<void> searchCustomers() async{
//
//    _isLoading = true;
//    notifyListeners();
//    String searchString;
//
//    List<Customer> _fetchedCustomersList = [];
//    DatabaseHelper databaseHelper = DatabaseHelper();
//
//    try {
//
//      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
//
//      if (connectivityResult == ConnectivityResult.none) {
//
//        int localChecklistCount = await databaseHelper.getRowCountWhere(Strings.customersTable, Strings.organisationId, user.organisationId);
//
//        if (localChecklistCount > 0) {
//
//          List<Map<String, dynamic>> localRecords = [];
//
//          localRecords = await databaseHelper.getCustomersLocally(user.organisationId);
//
//          if(localRecords.length > 0){
//
//            for (Map<String, dynamic> localRecord in localRecords) {
//
//              final Customer customer = getLocalCustomer(localRecord);
//              if(customer.fullName.toLowerCase().contains(_searchControllerValue.toLowerCase())) _fetchedCustomersList.add(customer);
//            }
//
//            _fetchedCustomersList.sort((Customer b,
//                Customer a) =>
//                b.fullName.compareTo(a.fullName));
//
//
//            if(_fetchedCustomersList.length <= 20){
//              if(_shouldUpdateCustomers) _customers = _fetchedCustomersList;
//
//            } else {
//              if(_shouldUpdateCustomers) _customers = _fetchedCustomersList.sublist(0, 20);
//
//            }
//
//            GlobalFunctions.showToast('No data connection, unable to fetch latest Customers');
//
//          }
//
//        } else {
//          GlobalFunctions.showToast('No Customers available, please try again when you have a data connection');
//          if(_shouldUpdateCustomers) _customers = [];
//        }
//      } else {
//
//        //Check the expiry time on the token before making the request
//        bool isTokenExpired = GlobalFunctions.isTokenExpired();
//        bool authenticated = true;
//
//        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();
//
//        if(authenticated){
//
//          QuerySnapshot firstNameSnapshot;
//          QuerySnapshot lastNameSnapshot;
//          QuerySnapshot fullNameSnapshot;
//          searchString = _searchControllerValue.toLowerCase();
//
//            try {
//              firstNameSnapshot =
//              await FirebaseFirestore.instance.collection('customers').where(
//                  'organisation_id',
//                  isEqualTo: user.organisationId).where('first_name_lowercase', isGreaterThanOrEqualTo: searchString).where('first_name_lowercase', isLessThanOrEqualTo: searchString + '\uf8ff').limit(20)
//                  .get()
//                  .timeout(Duration(seconds: 90));
//            } catch(e) {
//              print(e);
//            }
//            try {
//              lastNameSnapshot =
//              await FirebaseFirestore.instance.collection('customers').where(
//                  'organisation_id',
//                  isEqualTo: user.organisationId).where('last_name_lowercase', isGreaterThanOrEqualTo: searchString).where('last_name_lowercase', isLessThanOrEqualTo: searchString + '\uf8ff').limit(20)
//                  .get()
//                  .timeout(Duration(seconds: 90));
//            } catch(e) {
//              print(e);
//            }
//            try {
//              fullNameSnapshot =
//              await FirebaseFirestore.instance.collection('customers').where(
//                  'organisation_id',
//                  isEqualTo: user.organisationId).where('full_name_lowercase', isGreaterThanOrEqualTo: searchString).where('full_name_lowercase', isLessThanOrEqualTo: searchString + '\uf8ff').limit(20)
//                  .get()
//                  .timeout(Duration(seconds: 90));
//            } catch(e) {
//              print(e);
//            }
//
//
//            if(firstNameSnapshot.docs.length < 1 && lastNameSnapshot.docs.length < 1 && fullNameSnapshot.docs.length < 1){
//
//              if(_shouldUpdateCustomers) _customers = [];
//
//            } else {
//
//              if(firstNameSnapshot.docs.length > 0) {
//
//                for (DocumentSnapshot snap in firstNameSnapshot.docs) {
//
//                  final Customer customer = getFirebaseCustomer(snap.id, snap.data());
//                  _fetchedCustomersList.add(customer);
//
//                }
//              }
//              if(lastNameSnapshot.docs.length > 0) {
//                for (DocumentSnapshot snap in lastNameSnapshot.docs) {
//
//                  int exists = _fetchedCustomersList.indexWhere((
//                      Customer customer) {
//                    return customer.documentId == snap.id;
//                  });
//
//                  if (exists == -1) {
//                    final Customer customer = getFirebaseCustomer(snap.id, snap.data());
//                    _fetchedCustomersList.add(customer);
//
//                  }
//                }
//              }
//
//              if(fullNameSnapshot.docs.length > 0) {
//
//                for (DocumentSnapshot snap in fullNameSnapshot.docs) {
//
//                  int exists = _fetchedCustomersList.indexWhere((
//                      Customer customer) {
//                    return customer.documentId == snap.id;
//                  });
//
//                  if (exists == -1) {
//                    final Customer customer = getFirebaseCustomer(snap.id, snap.data());
//                    _fetchedCustomersList.add(customer);
//                  }
//                }
//              }
//
//              _fetchedCustomersList.sort((Customer b,
//                  Customer a) =>
//                  b.fullName.compareTo(a.fullName));
//
//              if(searchString == _searchControllerValue.toLowerCase() && _shouldUpdateCustomers) _customers = _fetchedCustomersList;
//
//            }
//        }
//
//      }
//
//    } on TimeoutException catch (_) {
//      GlobalFunctions.showToast('Network Timeout communicating with the server, unable to fetch latest Customers');
//    } catch(e){
//      print(e.toString());
//      GlobalFunctions.showToast('Something went wrong. Please try again');
//
//    }
//
//    _isLoading = false;
//    notifyListeners();
//    _selCustomerId = null;
//
//  }
//
//
//
//
//  Future<void> addUpdateCustomerLocally(String documentId, Map<String, dynamic> snapshotData) async{
//
//    Map<String, dynamic> localData = {
//    Strings.documentId: documentId,
//    Strings.organisationId : snapshotData[Strings.organisationId],
//    Strings.prefix: snapshotData[Strings.prefix],
//    Strings.firstName: GlobalFunctions.encryptString(snapshotData[Strings.firstName]),
//    Strings.lastName: GlobalFunctions.encryptString(snapshotData[Strings.lastName]),
//    Strings.fullName: GlobalFunctions.encryptString(snapshotData[Strings.fullName]),
//    Strings.address : GlobalFunctions.encryptString(snapshotData[Strings.address]),
//    Strings.postCode : GlobalFunctions.encryptString(snapshotData[Strings.postCode]),
//    Strings.telephone : GlobalFunctions.encryptString(snapshotData[Strings.telephone]),
//    Strings.mobile : GlobalFunctions.encryptString(snapshotData[Strings.mobile]),
//    Strings.email : GlobalFunctions.encryptString(snapshotData[Strings.email]),
//    Strings.customerJobOutstanding : GlobalFunctions.boolToTinyInt(snapshotData[Strings.customerJobOutstanding]),
//    };
//
//    DatabaseHelper databaseHelper = DatabaseHelper();
//    int existingRow = await databaseHelper.checkCustomerExists(documentId);
//
//    if(existingRow == 0){
//      await databaseHelper.add(Strings.customersTable, localData);
//    } else {
//      await databaseHelper.updateRow(Strings.customersTable, localData, Strings.documentId, documentId);
//    }
//
//  }
//
//  Customer getLocalCustomer(Map<String, dynamic> localRecord) {
//    return Customer(
//      documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
//      organisationId : GlobalFunctions.databaseValueString(localRecord[Strings.organisationId]),
//      prefix: GlobalFunctions.databaseValueString(localRecord[Strings.prefix]),
//      firstName: GlobalFunctions.decryptString(localRecord[Strings.firstName]),
//      lastName: GlobalFunctions.decryptString(localRecord[Strings.lastName]),
//      fullName: GlobalFunctions.decryptString(localRecord[Strings.fullName]),
//      address : GlobalFunctions.decryptString(localRecord[Strings.address]),
//      postCode : GlobalFunctions.decryptString(localRecord[Strings.postCode]),
//      telephone : GlobalFunctions.decryptString(localRecord[Strings.telephone]),
//      mobile : GlobalFunctions.decryptString(localRecord[Strings.mobile]),
//      email : GlobalFunctions.decryptString(localRecord[Strings.email]),
//      customerJobOutstanding : GlobalFunctions.tinyIntToBool(localRecord[Strings.customerJobOutstanding]),
//    );
//  }
//
//
//  Customer getFirebaseCustomer(String documentId, Map<String, dynamic> snapshotData) {
//
//    return Customer(
//      documentId: documentId,
//      organisationId: GlobalFunctions.databaseValueString(snapshotData[Strings.organisationId]),
//      prefix: GlobalFunctions.databaseValueString(snapshotData[Strings.prefix]),
//      firstName: GlobalFunctions.databaseValueString(snapshotData[Strings.firstName]),
//      lastName: GlobalFunctions.databaseValueString(snapshotData[Strings.lastName]),
//      fullName: GlobalFunctions.databaseValueString(snapshotData[Strings.fullName]),
//      address: GlobalFunctions.databaseValueString(snapshotData[Strings.address]),
//      postCode: GlobalFunctions.databaseValueString(snapshotData[Strings.postCode]),
//      telephone: GlobalFunctions.databaseValueString(snapshotData[Strings.telephone]),
//      mobile: GlobalFunctions.databaseValueString(snapshotData[Strings.mobile]),
//      email: GlobalFunctions.databaseValueString(snapshotData[Strings.email]),
//      customerJobOutstanding: GlobalFunctions.databaseValueBool(snapshotData[Strings.customerJobOutstanding]),
//    );
//
//  }
//
//
//
//}
//
//
//class Customer {
//  final String documentId;
//  final String organisationId;
//  final String prefix;
//  final String firstName;
//  final String lastName;
//  final String fullName;
//  final String address;
//  final String postCode;
//  final String email;
//  final String telephone;
//  final String mobile;
//  final bool customerJobOutstanding;
//
//
//  Customer(
//      {
//        @required this.documentId,
//        @required this.organisationId,
//        @required this.prefix,
//        @required this.firstName,
//        @required this.lastName,
//        @required this.fullName,
//        @required this.address,
//        @required this.postCode,
//        @required this.email,
//        @required this.telephone,
//        @required this.mobile,
//        this.customerJobOutstanding = false,
//      });
//}