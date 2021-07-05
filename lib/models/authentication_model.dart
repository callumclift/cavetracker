import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/organisations_model.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../shared/strings.dart';
import '../utils/database_helper.dart';
import '../locator.dart';
import '../services/navigation_service.dart';
import '../services/secure_storage.dart';
import '../constants/route_paths.dart' as routes;


class AuthenticationModel extends ChangeNotifier {

  final SecureStorage secureStorage = SecureStorage();
  final NavigationService _navigationService = locator<NavigationService>();
  DatabaseHelper databaseHelper = DatabaseHelper();


  String _loginErrorMessage = '';

  String get loginErrorMessage => _loginErrorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingLogin = false;
  bool get isLoadingLogin => _isLoadingLogin;

  bool _loginButtonEnabled = false;
  bool get loginButtonEnabled => _loginButtonEnabled;

  void setLoadingTrue() {
    _isLoading = true;
    notifyListeners();
  }

  void setLoadingFalse() {
    _isLoading = false;
    notifyListeners();
  }

  void setLoadingLoginTrue() {
    _isLoadingLogin = true;
    notifyListeners();
  }

  void setLoadingLoginFalse() {
    _isLoadingLogin = false;
    notifyListeners();
  }


  void setLoginButtonEnabledTrue() {
    _loginButtonEnabled = true;
    notifyListeners();
  }

  void setLoginButtonEnabledFalse() {
    _loginButtonEnabled = false;
    notifyListeners();
  }




  Future <void> signUp(String email, String password, String username) async {

    bool success = false;
    String message = '';
    GlobalFunctions.showLoadingDialog('Signing up');
    bool hasConnection = await GlobalFunctions.hasDataConnection();
    if(username.length > 1) username = username.trim();

    if(hasConnection){

      try {

        UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
        User firebaseUser = authResult.user;
        IdTokenResult tokenResult = await firebaseUser.getIdTokenResult();
        String token = tokenResult.token;
        firebaseUser.sendEmailVerification();

        if(token != null) {

          Map<String, dynamic> userInfo = {
            Strings.email: email,
            Strings.username: username,
            Strings.usernameLowercase: username.toLowerCase(),
            Strings.clubId: null,
            Strings.clubName: null,
            Strings.clubRole: null,
            Strings.requestedClubId: null,
            Strings.suspended: false,
            Strings.deleted: false,
            Strings.termsAccepted: false,
            Strings.forcePasswordReset: false
          };

          await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set(userInfo).timeout(Duration(seconds: 60));
          success = true;

        }

      } on TimeoutException catch (_) {

        message = 'Network Timeout communicating with the server, please try again';

      } catch (error) {

        String errorMessage = error.toString();

        if(errorMessage.contains('invalid-email')){

          message = 'Invalid Email Address';

        } else if(errorMessage.contains('email-exists')){

          message = 'The email address is already in use by another account.';

        } else if(errorMessage.contains('too-many-requests')){

          message = 'We have blocked all requests from this device due to unusual activity. Try again later.';

        } else if(errorMessage.contains('network-request-failed')){

          message = 'No data connection, please try again when you have a valid connection';

        } else {
          print(errorMessage);
          message = 'Something went wrong. Please try again';
        }

      }
    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) {
      _navigationService.goBack();
      message = 'An email has just been sent to you, Click the link provided to complete registration';
    }
    GlobalFunctions.showToast(message);


  }

  Future <void> login(String email, String password) async {

    _isLoadingLogin = true;
    _loginErrorMessage = '';
    notifyListeners();


    try {


      UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
      User firebaseUser = authResult.user;
      bool emailVerified = firebaseUser.emailVerified;
      IdTokenResult tokenResult = await firebaseUser.getIdTokenResult();
      String token = tokenResult.token;

      if(!emailVerified){
        _loginErrorMessage = 'Please verify your email before signing in';
      } else {
        if(token != null){

          DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
          Map<String, dynamic> snapshotData = snapshot.data();

          print(snapshotData);

          if(snapshotData['suspended'] == false) {

            final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
            final String expiryTimeString = expiryTime.toIso8601String();
            //Store user credentials in secure storage
            secureStorage.writeSecureData('email', email);
            secureStorage.writeSecureData('password', password);
            await createOnlineAuthenticatedUser(uid: firebaseUser.uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
            await createTemporaryForms();
            PurchaserInfo purchaserInfo = await Purchases.identify(user.uid);
            print('here are subs');
            print(purchaserInfo.activeSubscriptions);
            _loginErrorMessage = '';
            _navigationService.navigateToReplacement(routes.HomePageRoute);

          } else {
            _loginErrorMessage = 'Your account has been suspended, please contact your system admininistrator';
          }
        }

      }

    } on TimeoutException catch (_) {

      _loginErrorMessage = 'Network Timeout communicating with the server, please try again';

    } catch (error) {

      String errorMessage = error.toString();

      if(errorMessage.contains('invalid-email')){

        _loginErrorMessage = 'Invalid Email Address';
      } else if(errorMessage.contains('user-not-found')){

        _loginErrorMessage = 'No account exists with the provided credentials';
      } else if(errorMessage.contains('wrong-password')){

        _loginErrorMessage = 'Incorrect Password';

      } else if(errorMessage.contains('user-disabled')){

        _loginErrorMessage = 'Your account has been disabled by an administrator';
      } else if(errorMessage.contains('too-many-requests')){

        _loginErrorMessage = 'Too many unsuccessful login attempts. Please try again in a few minutes';
      } else if(errorMessage.contains('network-request-failed')){

        _loginErrorMessage = 'No data connection, please try again when you have a valid connection';
      } else {
        print(errorMessage);
        _loginErrorMessage = 'Something went wrong. Please try again';
      }


    }

    _isLoadingLogin = false;
    notifyListeners();


  }

  Future <void> autoLogin() async{


    _isLoading = true;
    final bool rememberMe = sharedPreferences.getBool(Strings.rememberMe);
    final bool termsAccepted = sharedPreferences.getBool(Strings.termsAccepted);


    //If remember me is true & terms have been accepted begin auto login otherwise show login screen

    if(rememberMe != null && rememberMe == true) {


      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

      //Check for connection, if present check for active token, otherwise login offline with stored credentials
      if (connectivityResult != ConnectivityResult.none) {

        bool isTokenExpired = GlobalFunctions.isTokenExpired();

        try {

          String token;
          User firebaseUser;
          String uid;
          String email = await secureStorage.readSecureData('email');


          //if token is expired get a new token otherwise user stored token to save getting token unnecessarily
        if (isTokenExpired) {

          String password = await secureStorage.readSecureData('password');
          UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
          firebaseUser = authResult.user;
          IdTokenResult tokenResult = await firebaseUser.getIdTokenResult();
          token = tokenResult.token;
          uid = firebaseUser.uid;

        } else {

          token = sharedPreferences.getString(Strings.token);
          uid = sharedPreferences.getString(Strings.uid);
        }


            if(token != null){

              DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              Map<String, dynamic> snapshotData = snapshot.data();

              if(snapshotData['suspended'] == false) {


                String expiryTimeString = sharedPreferences.getString(Strings.tokenExpiryTime);

                if(isTokenExpired){
                  final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
                  expiryTimeString = expiryTime.toIso8601String();

                }

                await createOnlineAuthenticatedUser(uid: uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
                await createTemporaryForms();


              } else {

                GlobalFunctions.showToast('Your account has been suspended, please contact your system admininistrator');
                sharedPreferences.setBool(Strings.rememberMe, false);
                
              }

            }

          } on TimeoutException catch (_) {

              await getOfflineAuthenticatedUser();


        } catch (error) {

            String errorMessage = error.toString();

            if(errorMessage.contains('invalid-email')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('user-not-found')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('wrong-password')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('user-disabled')){

              GlobalFunctions.showToast('Your account has been suspended, please contact your administrator');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('too-many-requests')){

              GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);


            } else if(errorMessage.contains('network-request-failed')){

              await getOfflineAuthenticatedUser();

            } else {
              print(errorMessage);
              GlobalFunctions.showToast(errorMessage);
              //GlobalFunctions.showToast('Something went wrong. Please login with your email & password');
              sharedPreferences.setBool(Strings.rememberMe, false);
            }

          }

      } else {

        await getOfflineAuthenticatedUser();

      }
    }

    _isLoading = false;
    notifyListeners();
  }


  Future <bool> reAuthenticate() async {

    bool success = false;
    String password = await secureStorage.readSecureData('password');
    String email = await secureStorage.readSecureData('email');

    try{


        UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).timeout(Duration(seconds: 60));
        User firebaseUser = authResult.user;
        IdTokenResult tokenResult = await firebaseUser.getIdTokenResult();
        String token = tokenResult.token;




      if(token != null){

        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
        Map<String, dynamic> snapshotData = snapshot.data();

        if(snapshotData['suspended'] == false) {

          final DateTime expiryTime = DateTime.now().add(Duration(seconds: 3300));
          String expiryTimeString = expiryTime.toIso8601String();
          await createOnlineAuthenticatedUser(uid: firebaseUser.uid, email: email, token: token, tokenExpiryTime: expiryTimeString, snapshotData: snapshotData);
          success = true;

        } else {

          GlobalFunctions.showToast('Your account has been suspended, please contact your system admininistrator');
          await logout();

        }

      } else {
        GlobalFunctions.showToast('Something went wrong. Please try again');
      }

    } on TimeoutException catch (_) {

      await getOfflineAuthenticatedUser();


    } catch (error) {

      String errorMessage = error.toString();

      if(errorMessage.contains('invalid-email')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('user-not-found')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('wrong-password')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('user-disabled')){

        GlobalFunctions.showToast('Your account has been suspended, please contact your administrator');
        await logout();


      } else if(errorMessage.contains('too-many-requests')){

        GlobalFunctions.showToast('Account credentials not found. Please login with a valid email & password');
        await logout();


      } else if(errorMessage.contains('network-request-failed')){

        GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');

      } else {

        GlobalFunctions.showToast('Something went wrong. Please login with your email & password');
        await logout();

      }

    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future <void> logout() async {
    _navigationService.navigateToReplacement(routes.LoginPageRoute);
    user = null;
    organisation = null;
    sharedPreferences.remove(Strings.rememberMe);
    secureStorage.deleteSecureData('email');
    secureStorage.deleteSecureData('password');
    getLocation = true;
    notifyListeners();
  }


  Future<void> getOfflineAuthenticatedUser() async{
    String email = await secureStorage.readSecureData('email');

    user = AuthenticatedUser(
        uid: sharedPreferences.get(Strings.uid),
        email: email,
        token: sharedPreferences.get(Strings.token),
        tokenExpiryTime: sharedPreferences.get(Strings.tokenExpiryTime),
        suspended: sharedPreferences.getBool(Strings.suspended),
        deleted: sharedPreferences.getBool(Strings.deleted),
        termsAccepted: sharedPreferences.getBool(Strings.termsAccepted),
        forcePasswordReset: sharedPreferences.getBool(Strings.forcePasswordReset),
        username: GlobalFunctions.decryptString(sharedPreferences.get(Strings.username)),
        clubId: sharedPreferences.get(Strings.clubId),
        clubName: sharedPreferences.get(Strings.clubName),
        clubRole: sharedPreferences.get(Strings.clubRole),
        requestedClubId: sharedPreferences.get(Strings.requestedClubId),
    );

    organisation = Organisation(
        organisationId: sharedPreferences.get(Strings.usersOrganisationId),
        organisationName: sharedPreferences.get(Strings.organisationName),
        telephone: sharedPreferences.get(Strings.usersOrganisationTelNo),
        email: sharedPreferences.get(Strings.usersOrganisationEmail),
        contactEmail: sharedPreferences.get(Strings.usersOrganisationContactEmail),
        licenses: sharedPreferences.getInt(Strings.usersOrganisationLicenses),
        address: sharedPreferences.get(Strings.usersOrganisationAddress),
        postCode: sharedPreferences.get(Strings.usersOrganisationPostCode),
        vatRegNo: sharedPreferences.get(Strings.usersOrganisationVatRegNo),
        sortCode: sharedPreferences.get(Strings.usersOrganisationSortCode),
        accountNumber: sharedPreferences.get(Strings.usersOrganisationAccountNumber),
        accountName: sharedPreferences.get(Strings.usersOrganisationAccountName),
        accountBank: sharedPreferences.get(Strings.usersOrganisationAccountBank),
        latitude: sharedPreferences.getDouble(Strings.usersOrganisationLatitude),
        longitude: sharedPreferences.getDouble(Strings.usersOrganisationLongitude),
        logo: sharedPreferences.get(Strings.usersOrganisationLogo));
  }



  Future<void> createOnlineAuthenticatedUser ({@required String uid, @required String email, @required String token, @required String tokenExpiryTime, @required Map<String, dynamic> snapshotData}) async {


    user = AuthenticatedUser(
      uid: GlobalFunctions.databaseValueString(uid),
      email: GlobalFunctions.databaseValueString(email),
      username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
      clubId: GlobalFunctions.databaseValueString(snapshotData[Strings.clubId]),
      clubName: GlobalFunctions.databaseValueString(snapshotData[Strings.clubName]),
      clubRole: GlobalFunctions.databaseValueString(snapshotData[Strings.clubRole]),
      requestedClubId: GlobalFunctions.databaseValueString(snapshotData[Strings.requestedClubId]),
      token: GlobalFunctions.databaseValueString(token),
      tokenExpiryTime: GlobalFunctions.databaseValueString(tokenExpiryTime),
      suspended: GlobalFunctions.databaseValueBool(snapshotData[Strings.suspended]),
      deleted: GlobalFunctions.databaseValueBool(snapshotData[Strings.deleted]),
      termsAccepted: GlobalFunctions.databaseValueBool(snapshotData[Strings.termsAccepted]),
      forcePasswordReset: GlobalFunctions.databaseValueBool(snapshotData[Strings.forcePasswordReset]),
    );


    //Store user information in shared preferences
    sharedPreferences.setString(Strings.uid, uid);
    sharedPreferences.setString(Strings.token, token);
    sharedPreferences.setBool(Strings.suspended, user.suspended);
    sharedPreferences.setBool(Strings.deleted, user.deleted);
    sharedPreferences.setBool(Strings.termsAccepted, user.termsAccepted);
    sharedPreferences.setBool(Strings.forcePasswordReset, user.forcePasswordReset);
    sharedPreferences.setString(Strings.username, GlobalFunctions.encryptString(user.username));
    sharedPreferences.setString(Strings.clubId, user.clubId);
    sharedPreferences.setString(Strings.clubName, user.clubName);
    sharedPreferences.setString(Strings.clubRole, user.clubRole);
    sharedPreferences.setString(Strings.requestedClubId, user.requestedClubId);
    sharedPreferences.setString(Strings.tokenExpiryTime, tokenExpiryTime);
    sharedPreferences.setBool(Strings.rememberMe, true);

    //Store user information in local database
    Map<String, dynamic> localData = {
      Strings.uid: GlobalFunctions.databaseValueString(snapshotData[uid]),
      Strings.suspended: GlobalFunctions.boolToTinyInt(snapshotData[Strings.suspended]),
      Strings.deleted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.deleted]),
      Strings.termsAccepted: GlobalFunctions.boolToTinyInt(snapshotData[Strings.termsAccepted]),
      Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(snapshotData[Strings.forcePasswordReset]),
      Strings.username: GlobalFunctions.encryptString(snapshotData[Strings.username]),
      Strings.clubId: GlobalFunctions.databaseValueString(snapshotData[Strings.clubId]),
      Strings.clubName: GlobalFunctions.databaseValueString(snapshotData[Strings.clubName]),
      Strings.clubRole: GlobalFunctions.databaseValueString(snapshotData[Strings.clubRole]),
      Strings.requestedClubId: GlobalFunctions.databaseValueString(snapshotData[Strings.requestedClubId]),
    };

    int existingUser = await databaseHelper.checkAuthenticatedUserExists(user.uid);

    if(existingUser == 0){
      await databaseHelper.add(Strings.authenticationTable, localData);
    } else {
      await databaseHelper.updateRow(Strings.authenticationTable, localData, Strings.uid, user.uid);
    }
  }


  Future <void> createOnlineUserOrganisation (String orgId, Map<String, dynamic> orgSnapshotData) async {

    String logoPath;

    if(orgSnapshotData['logo'] != null){

      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/images${user.uid}/organisationLogos';

      if (!Directory(dirPath).existsSync()) {
        Directory(dirPath).createSync(recursive: true);
      }

      http.Client client = new http.Client();
      var req = await client.get(Uri.parse(orgSnapshotData['logo']));
      var bytes = req.bodyBytes;
      final file = new File('$dirPath/$orgId.jpg');
      file.writeAsBytesSync(bytes);
      logoPath = file.path;


    }


    organisation = Organisation(
        organisationId: orgId,
        organisationName: orgSnapshotData[Strings.organisationName],
        telephone: orgSnapshotData[Strings.telephone],
        email: orgSnapshotData[Strings.email],
        contactEmail: orgSnapshotData[Strings.contactEmail],
        licenses: orgSnapshotData[Strings.licenses],
        address: orgSnapshotData[Strings.address],
        postCode: orgSnapshotData[Strings.postCode],
        vatRegNo: orgSnapshotData[Strings.vatRegNo],
        sortCode: orgSnapshotData[Strings.sortCode],
        accountNumber: orgSnapshotData[Strings.accountNumber],
        accountName: orgSnapshotData[Strings.accountName],
        accountBank: orgSnapshotData[Strings.accountBank],
        latitude: orgSnapshotData[Strings.latitude],
        longitude: orgSnapshotData[Strings.longitude],
        logo: logoPath);

    sharedPreferences.setString(Strings.usersOrganisationId, organisation.organisationId);
    sharedPreferences.setString(Strings.usersOrganisationName, organisation.organisationName);
    sharedPreferences.setString(Strings.usersOrganisationAddress, organisation.address);
    sharedPreferences.setString(Strings.usersOrganisationEmail, organisation.email);
    sharedPreferences.setString(Strings.usersOrganisationContactEmail, organisation.contactEmail);
    sharedPreferences.setInt(Strings.usersOrganisationLicenses, organisation.licenses);
    sharedPreferences.setDouble(Strings.usersOrganisationLatitude, organisation.latitude);
    sharedPreferences.setDouble(Strings.usersOrganisationLongitude, organisation.longitude);
    sharedPreferences.setString(Strings.usersOrganisationPostCode, organisation.postCode);
    sharedPreferences.setString(Strings.usersOrganisationTelNo, organisation.telephone);
    sharedPreferences.setString(Strings.usersOrganisationVatRegNo, organisation.vatRegNo);
    sharedPreferences.setString(Strings.usersOrganisationSortCode, organisation.sortCode);
    sharedPreferences.setString(Strings.usersOrganisationAccountNumber, organisation.accountNumber);
    sharedPreferences.setString(Strings.usersOrganisationAccountName, organisation.accountName);
    sharedPreferences.setString(Strings.usersOrganisationAccountBank, organisation.accountBank);
    sharedPreferences.setString(Strings.usersOrganisationLogo, logoPath);


    Map<String, dynamic> localData = {
      Strings.documentId: organisation.organisationId,
      Strings.organisationName: organisation.organisationName,
      Strings.address: organisation.address,
      Strings.email: organisation.email,
      Strings.contactEmail: organisation.contactEmail,
      Strings.licenses: organisation.licenses,
      Strings.latitude: organisation.latitude,
      Strings.longitude: organisation.longitude,
      Strings.postCode: organisation.postCode,
      Strings.telephone: organisation.telephone,
      Strings.vatRegNo: organisation.vatRegNo,
      Strings.sortCode: organisation.sortCode,
      Strings.accountNumber: organisation.accountNumber,
      Strings.accountName: organisation.accountName,
      Strings.accountBank: organisation.accountBank,
      Strings.logo: organisation.logo,
    };



    int existingUser = await databaseHelper.checkOrganisationExists(user.uid);

    if(existingUser == 0){
    await databaseHelper.add(Strings.organisationTable, localData);
    } else {
    await databaseHelper.updateRow(Strings.organisationTable, localData, Strings.uid, user.uid);
    }
  }

  Future <void> sendPasswordResetEmail(String email) async{

    GlobalFunctions.showLoadingDialog('Sending password reset email');
    bool hasConnection = await GlobalFunctions.hasDataConnection();
    bool error = false;
    String message = '';

    if(hasConnection){



      try {

        await FirebaseAuth.instance.sendPasswordResetEmail(email: email).timeout(Duration(seconds: 30));


      } on TimeoutException catch (_) {


      } catch(e){

        error = true;
        String errorMessage = error.toString();

        if(errorMessage.contains('invalid-email')){

          message = 'Account credentials not found. Please login with a valid email & password';

        } else if(errorMessage.contains('user-not-found')){

          message = 'Account credentials not found. Please enter a registered email';

        } else if(errorMessage.contains('user-disabled')){

          message = 'Your account has been suspended, please contact your administrator';

        } else if(errorMessage.contains('network-request-failed')){

          message = 'No data connection, please try again when you have a valid connection';

        } else {

          message = 'Something went wrong. Please try again';
        }
      }


    } else {
      message = 'No data connection, please try again when you have a valid connection';
    }
    GlobalFunctions.dismissLoadingDialog();
    if(!error) {
      _navigationService.goBack();
      message = 'Reset Password E-mail sent';
    }
    GlobalFunctions.showToast(message);
  }

  Future<bool> changePassword(String newPassword) async {

    String message = '';
    GlobalFunctions.showLoadingDialog('Changing Password...');
    bool success = false;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection) {

      bool authenticated = await reAuthenticate();

      if(authenticated){

        try {

          await FirebaseAuth.instance.currentUser.updatePassword(newPassword).timeout(Duration(seconds: 60));
          secureStorage.writeSecureData('password', newPassword);
          message = 'Password successfully changed';
          success = true;


        } on TimeoutException catch (_) {

          message = 'Network Timeout communicating with the server, unable edit password';

        } catch(error){

          print(error);
          message = 'Something went wrong. Please try again';

        }

      }
    } else {
      message = 'No data connection, unable to change password';
    }

    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<void> createTemporaryForms() async {
    final int existingTemporaryActivityLog = await databaseHelper.checkTemporaryActivityLogExists(user.uid);
    if(existingTemporaryActivityLog == 0){
      await databaseHelper.add(Strings.temporaryActivityLogTable, {Strings.uid: user.uid});
    }
    final int existingTemporaryCave = await databaseHelper.checkTemporaryCaveExists(user.uid);
    if(existingTemporaryCave == 0){
      await databaseHelper.add(Strings.temporaryCaveTable, {Strings.uid: user.uid});
    }
    final int existingTemporaryCallOut = await databaseHelper.checkTemporaryCallOutExists(user.uid);
    if(existingTemporaryCallOut == 0){
      await databaseHelper.add(Strings.temporaryCallOutTable, {Strings.uid: user.uid});
    }
  }



}



class AuthenticatedUser {
  String uid;
  String email;
  String username;
  String clubId;
  String clubName;
  String clubRole;
  String requestedClubId;
  String token;
  String tokenExpiryTime;
  bool suspended;
  bool deleted;
  bool termsAccepted;
  bool forcePasswordReset;

  AuthenticatedUser(
      {@required this.uid,
      @required this.email,
      @required this.username,
      @required this.clubId,
      @required this.clubName,
      @required this.clubRole,
      @required this.requestedClubId,
      @required this.token,
      @required this.tokenExpiryTime,
      @required this.suspended,
      @required this.deleted,
      @required this.termsAccepted,
      @required this.forcePasswordReset});
}
