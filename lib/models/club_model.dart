import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:caving_app/services/navigation_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../locator.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../utils/database_helper.dart';
import './authentication_model.dart';
import '../shared/strings.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';


class ClubModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();
  DatabaseHelper databaseHelper = DatabaseHelper();



  ClubModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _clubs = [];
  String _selClubId;
  int crashedIndex = 0;
  bool getLostImage = false;
  final dateFormatDay = DateFormat("dd/MM/yyyy HH:mm");
  static File _imageFile1;
  static File _imageFile2;
  static File _imageFile3;
  static File _imageFile4;
  static File _imageFile5;

  List<File> images = [
    _imageFile1,
    _imageFile2,
    _imageFile3,
    _imageFile4,
    _imageFile5,
  ];

  List<dynamic> temporaryPaths = [];
  File lostImage;

  void resetImages(){
    images[0] = null;
    images[1] = null;
    images[2] = null;
    images[3] = null;
    images[4] = null;
    temporaryPaths = [];
    notifyListeners();
  }



  List<Map<String, dynamic>> get allClubs {
    return List.from(_clubs);
  }
  int get selectedClubIndex {
    return _clubs.indexWhere((Map<String, dynamic> club) {
      return club[Strings.documentId] == _selClubId;
    });
  }
  String get selectedClubId {
    return _selClubId;
  }

  Map<String, dynamic> get selectedClub {
    if (_selClubId == null) {
      return null;
    }
    return _clubs.firstWhere((Map<String, dynamic> club) {
      return club[Strings.documentId] == _selClubId;
    });
  }
  void selectClub(String clubId) {
    _selClubId = clubId;
    if (clubId != null) {
      notifyListeners();
    }
  }


  List<Map<String, dynamic>> _announcements = [];
  String _selAnnouncementId;

  List<Map<String, dynamic>> get allAnnouncements {
    return List.from(_announcements);
  }
  int get selectedAnnouncementIndex {
    return _announcements.indexWhere((Map<String, dynamic> announcement) {
      return announcement[Strings.documentId] == _selAnnouncementId;
    });
  }
  String get selectedAnnouncementId {
    return _selAnnouncementId;
  }

  Map<String, dynamic> get selectedAnnouncement {
    if (_selAnnouncementId == null) {
      return null;
    }
    return _announcements.firstWhere((Map<String, dynamic> announcement) {
      return announcement[Strings.documentId] == _selAnnouncementId;
    });
  }
  void selectAnnouncement(String announcementId) {
    _selAnnouncementId = announcementId;
    if (announcementId != null) {
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _clubMembers = [];
  String _selClubMemberId;

  List<Map<String, dynamic>> get allClubMembers {
    return List.from(_clubMembers);
  }
  int get selectedClubMemberIndex {
    return _clubMembers.indexWhere((Map<String, dynamic> clubMember) {
      return clubMember[Strings.uid] == _selClubMemberId;
    });
  }
  String get selectedClubMemberId {
    return _selClubMemberId;
  }

  Map<String, dynamic> get selectedClubMember {
    if (_selClubMemberId == null) {
      return null;
    }
    return _clubMembers.firstWhere((Map<String, dynamic> clubMember) {
      return clubMember[Strings.uid] == _selClubMemberId;
    });
  }
  void selectClubMember(String clubMemberId) {
    _selClubMemberId = clubMemberId;
    if (clubMemberId != null) {
      notifyListeners();
    }
  }



  Future<void> submitClub(String name, String description) async {

    GlobalFunctions.showLoadingDialog('Submitting Club...');
    String message = '';
    bool success = false;

    DatabaseHelper _databaseHelper = DatabaseHelper();
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          QuerySnapshot existingClub = await FirebaseFirestore.instance.collection('clubs').where('name', isEqualTo: name.trim().toLowerCase()).get().timeout(Duration(seconds: 90));

          if(existingClub.size > 0){

            message = 'Club with that name already exists';

          } else {

            DocumentReference ref =
            await FirebaseFirestore.instance.collection('clubs').add({
              Strings.name: name.trim(),
              Strings.nameLowercase: name.trim().toLowerCase(),
              Strings.description: description,
              Strings.requests: null
            });

            DocumentSnapshot snap = await ref.get();



            Map<String, dynamic> localData = {
              Strings.documentId: snap.id,
              Strings.name: name,
              Strings.nameLowercase: name,
              Strings.description: description,
              Strings.requests: null
            };


            int queryResult = await _databaseHelper.add(
                Strings.clubTable,
                localData);

            if (queryResult != 0) {
              success = true;
              message = 'Club created successfully';
            }

            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              Strings.clubId: snap.id,
              Strings.clubName: name,
              Strings.clubRole: 'Admin',
              Strings.requestedClubId: null
            }).timeout(Duration(seconds: 60));

            Map<String, dynamic> userData = {
              Strings.uid: GlobalFunctions.databaseValueString(user.uid),
              Strings.suspended: GlobalFunctions.boolToTinyInt(user.suspended),
              Strings.deleted: GlobalFunctions.boolToTinyInt(user.deleted),
              Strings.termsAccepted: GlobalFunctions.boolToTinyInt(user.termsAccepted),
              Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(user.forcePasswordReset),
              Strings.username: GlobalFunctions.encryptString(user.username),
              Strings.clubId: GlobalFunctions.databaseValueString(snap.id),
              Strings.clubName: GlobalFunctions.databaseValueString(name),
              Strings.clubRole: GlobalFunctions.databaseValueString('Admin'),
              Strings.requestedClubId: GlobalFunctions.databaseValueString(''),
            };

            user.requestedClubId = '';
            user.clubId = snap.id;
            user.clubName = name;
            user.clubRole = 'Admin';
            sharedPreferences.setString(Strings.requestedClubId, user.requestedClubId);
            sharedPreferences.setString(Strings.clubId, user.requestedClubId);
            sharedPreferences.setString(Strings.clubName, user.clubName);
            sharedPreferences.setString(Strings.clubRole, user.clubRole);


            int existingUser = await databaseHelper.checkAuthenticatedUserExists(user.uid);

            if(existingUser == 0){
              await databaseHelper.add(Strings.authenticationTable, userData);
            } else {
              await databaseHelper.updateRow(Strings.authenticationTable, userData, Strings.uid, user.uid);
            }

          }



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to create Club';


        } catch (e) {
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to create Club';

    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) _navigationService.goBack();
    GlobalFunctions.showToast(message);
    authenticationModel.notifyListeners();
    return success;


  }

  Future<bool> joinClub(String documentId) async {

    GlobalFunctions.showLoadingDialog('Submitting Request...');
    String message = '';
    bool success = false;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {


          DocumentSnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').doc(documentId).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }

          Map<String, dynamic> snapshotData = {};
          List<Map<String, dynamic>> requests = [];

          if(snapshot.exists == false){
            message = 'No Clubs found';
          } else {

            snapshotData = snapshot.data();


            List<dynamic> requestsDynamic = [];

            if(snapshotData['requests'] != null){
              requestsDynamic = jsonDecode(
                  snapshotData['requests']);
              requestsDynamic.forEach((dynamic item) {
                Map<String, dynamic> actualMap = Map.from(item);
                requests.add(actualMap);
              });
            }



            requests.add({'name': user.username, 'uid': user.uid});

            var reEncodedRequests = jsonEncode(requests);

            await FirebaseFirestore.instance.collection('clubs').doc(documentId).update({
              Strings.requests: reEncodedRequests
            }).timeout(Duration(seconds: 60));

            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              Strings.requestedClubId: documentId
            }).timeout(Duration(seconds: 60));


            Map<String, dynamic> localData = {
              Strings.uid: GlobalFunctions.databaseValueString(user.uid),
              Strings.suspended: GlobalFunctions.boolToTinyInt(user.suspended),
              Strings.deleted: GlobalFunctions.boolToTinyInt(user.deleted),
              Strings.termsAccepted: GlobalFunctions.boolToTinyInt(user.termsAccepted),
              Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(user.forcePasswordReset),
              Strings.username: GlobalFunctions.encryptString(user.username),
              Strings.clubId: GlobalFunctions.databaseValueString(user.clubId),
              Strings.clubName: GlobalFunctions.databaseValueString(user.clubName),
              Strings.clubRole: GlobalFunctions.databaseValueString(user.clubRole),
              Strings.requestedClubId: GlobalFunctions.databaseValueString(documentId),
            };

            user.requestedClubId = documentId;
            sharedPreferences.setString(Strings.requestedClubId, user.requestedClubId);


            int existingUser = await databaseHelper.checkAuthenticatedUserExists(user.uid);

            if(existingUser == 0){
              await databaseHelper.add(Strings.authenticationTable, localData);
            } else {
              await databaseHelper.updateRow(Strings.authenticationTable, localData, Strings.uid, user.uid);
            }

            message = 'Your request has been sent';
            success = true;
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to join Club';

        } catch (e) {
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to join Club';
      success = true;

    }

    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    authenticationModel.notifyListeners();
    return success;

  }


  Future<bool> cancelRequest(String documentId) async {

    GlobalFunctions.showLoadingDialog('Cancelling Request...');
    String message = '';
    bool success = false;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {


          DocumentSnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').doc(documentId).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }

          Map<String, dynamic> snapshotData = {};
          List<Map<String, dynamic>> requests = [];

          if(snapshot.exists == false){
            message = 'No Clubs found';
          } else {

            snapshotData = snapshot.data();


            List<dynamic> requestsDynamic = [];

            if(snapshotData['requests'] != null){
              requestsDynamic = jsonDecode(
                  snapshotData['requests']);
              requestsDynamic.forEach((dynamic item) {
                Map<String, dynamic> actualMap = Map.from(item);
                requests.add(actualMap);
              });
            }


            if(requests.length > 0){

              requests.removeWhere((request) => request['uid'] == user.uid);

              var reEncodedRequests;

              if(requests.length > 0){
                reEncodedRequests = jsonEncode(requests);
              }


              await FirebaseFirestore.instance.collection('clubs').doc(documentId).update({
                Strings.requests: reEncodedRequests
              }).timeout(Duration(seconds: 60));

              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                Strings.requestedClubId: null
              }).timeout(Duration(seconds: 60));


              Map<String, dynamic> localData = {
                Strings.uid: GlobalFunctions.databaseValueString(user.uid),
                Strings.suspended: GlobalFunctions.boolToTinyInt(user.suspended),
                Strings.deleted: GlobalFunctions.boolToTinyInt(user.deleted),
                Strings.termsAccepted: GlobalFunctions.boolToTinyInt(user.termsAccepted),
                Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(user.forcePasswordReset),
                Strings.username: GlobalFunctions.encryptString(user.username),
                Strings.clubId: GlobalFunctions.databaseValueString(user.clubId),
                Strings.clubName: GlobalFunctions.databaseValueString(user.clubName),
                Strings.clubRole: GlobalFunctions.databaseValueString(user.clubRole),
                Strings.requestedClubId: GlobalFunctions.databaseValueString(''),
              };

              user.requestedClubId = '';
              sharedPreferences.setString(Strings.requestedClubId, user.requestedClubId);


              int existingUser = await databaseHelper.checkAuthenticatedUserExists(user.uid);

              if(existingUser == 0){
                await databaseHelper.add(Strings.authenticationTable, localData);
              } else {
                await databaseHelper.updateRow(Strings.authenticationTable, localData, Strings.uid, user.uid);
              }

              success = true;

            }
          }

        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to join Club';

        } catch (e) {
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to join Club';
      success = true;

    }

    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    authenticationModel.notifyListeners();
    return success;

  }


  Future<List<Map<String, dynamic>>> getClubs() async{
    print('get clubs called');

    _isLoading = true;
    String message = '';
    List<Map<String, dynamic>> _fetchedClubList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No data connection, unable to fetch latest Clubs';

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){

          QuerySnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').orderBy('name', descending: false).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }

          Map<String, dynamic> snapshotData = {};


          if(snapshot.docs.length < 1){
            message = 'No Clubs found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();
              List<Map<String, dynamic>> requests = [];
              List<dynamic> requestsDynamic = [];

              if(snapshotData['requests'] != null){
                requestsDynamic = jsonDecode(
                    snapshotData['requests']);
                requestsDynamic.forEach((dynamic item) {
                  Map<String, dynamic> actualMap = Map.from(item);
                  requests.add(actualMap);
                });

              }


              final Map<String, dynamic> club = {
                Strings.documentId: snap.id,
                Strings.name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
                Strings.description: GlobalFunctions.databaseValueString(snapshotData[Strings.description]),
                Strings.requests: requests.length < 1 ? null : requests
              };

              _fetchedClubList.add(club);

            }
          }
        }
      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Clubs';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
    return _fetchedClubList;

  }


  Future<void> deleteClub() async{

    GlobalFunctions.showLoadingDialog('Deleting Club...');
    String message;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          await FirebaseFirestore.instance.collection('clubs').doc(selectedClubId).delete();

          int queryResult = await databaseHelper.delete(Strings.clubTable, selectedClubId);

          if(queryResult != 0){
            message = 'Club deleted';
            await getClubs();
            notifyListeners();
          }



        } on TimeoutException catch (_) {

          GlobalFunctions.showToast('Network Timeout communicating with the server, unable to delete Customer');

        } catch (error) {
          print(error);
        }

      }

    } else {
      message = 'No data connection, unable to delete Club';
    }

    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);

  }


  Future<void> submitAnnouncement(String body) async {

    GlobalFunctions.showLoadingDialog('Submitting Announcement...');
    String message = '';
    bool success = false;

    DatabaseHelper _databaseHelper = DatabaseHelper();
    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {


            DocumentReference ref =
            await FirebaseFirestore.instance.collection('announcements').add({
              Strings.username: user.username,
              Strings.uid: user.uid,
              Strings.clubId: user.clubId,
              Strings.body: body,
              Strings.timestamp: FieldValue.serverTimestamp(),
            });

            DocumentSnapshot snap = await ref.get();



            Map<String, dynamic> localData = {
              Strings.documentId: snap.id,
              Strings.username: user.username,
              Strings.uid: user.uid,
              Strings.clubId: user.clubId,
              Strings.body: body,
              Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
            };


            int queryResult = await _databaseHelper.add(
                Strings.announcementTable,
                localData);

            if (queryResult != 0) {
              success = true;
              message = 'Announcement created successfully';
            }




        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to submit Announcement';


        } catch (e) {
          message = e.toString();
          print(e);
        }
      }

    } else {

      message = 'No data connection, unable to submit Announcement';
      success = true;

    }

    GlobalFunctions.dismissLoadingDialog();
    if(success) _navigationService.goBack();
    getAnnouncements();
    GlobalFunctions.showToast(message);


  }


  Future<Map<String, dynamic>> acceptMemberRequest(String uid, List<Map<String, dynamic>> currentMembersList) async{


    _isLoading = true;
    bool success = false;
    String message = '';
    List<Map<String, dynamic>> _fetchedMemberRequestsList = currentMembersList;
    GlobalFunctions.showLoadingDialog('Accepting Request');

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(hasDataConnection){

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          DocumentSnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').doc(user.clubId).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }


          Map<String, dynamic> snapshotData = snapshot.data();

          List<dynamic> requestsDynamic = [];
          print(snapshotData);

          if(snapshotData['requests'] != null){
            print(_fetchedMemberRequestsList);

            requestsDynamic = jsonDecode(
                snapshotData['requests']);
            requestsDynamic.forEach((dynamic item) {
              Map<String, dynamic> actualMap = Map.from(item);
              _fetchedMemberRequestsList.add(actualMap);
            });

          }

          _fetchedMemberRequestsList.removeWhere((memberRequest) => memberRequest['uid'] == uid);



          var reEncodedMemberRequestList;

          if(_fetchedMemberRequestsList.length > 0){
            reEncodedMemberRequestList = jsonEncode(_fetchedMemberRequestsList);
          }

          await FirebaseFirestore.instance.collection('clubs').doc(user.clubId).update({
            Strings.requests: reEncodedMemberRequestList
          }).timeout(Duration(seconds: 60));

          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            Strings.requestedClubId: null,
            Strings.clubId: user.clubId,
            Strings.clubName: user.clubName,
            Strings.clubRole: 'Standard'
          }).timeout(Duration(seconds: 60));

          message = 'Request accepted';
          success = true;


        }

      } else {
        message = 'No data connection, unable to accept member request';
      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to accept request';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return {'success' : success, 'member_requests': _fetchedMemberRequestsList};

  }

  Future<List<Map<String, dynamic>>> rejectMemberRequest(String uid, List<Map<String, dynamic>> currentMembersList) async{


    _isLoading = true;
    String message = '';
    List<Map<String, dynamic>> _fetchedMemberRequestsList = currentMembersList;
    GlobalFunctions.showLoadingDialog('Rejecting Request');

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(hasDataConnection){

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          DocumentSnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').doc(user.clubId).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }


          Map<String, dynamic> snapshotData = snapshot.data();

          List<dynamic> requestsDynamic = [];
          print(snapshotData);

          if(snapshotData['requests'] != null){
            print(_fetchedMemberRequestsList);

            requestsDynamic = jsonDecode(
                snapshotData['requests']);
            requestsDynamic.forEach((dynamic item) {
              Map<String, dynamic> actualMap = Map.from(item);
              _fetchedMemberRequestsList.add(actualMap);
            });

          }

          _fetchedMemberRequestsList.removeWhere((memberRequest) => memberRequest['uid'] == uid);



          var reEncodedMemberRequestList;

          if(_fetchedMemberRequestsList.length > 0){
            reEncodedMemberRequestList = jsonEncode(_fetchedMemberRequestsList);
          }

          await FirebaseFirestore.instance.collection('clubs').doc(user.clubId).update({
            Strings.requests: reEncodedMemberRequestList
          }).timeout(Duration(seconds: 60));

          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            Strings.requestedClubId: null,
          }).timeout(Duration(seconds: 60));

          message = 'Request rejected';


        }

      } else {
        message = 'No data connection, unable to reject member request';
      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to reject request';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    GlobalFunctions.dismissLoadingDialog();
    if(message != '') GlobalFunctions.showToast(message);
    return _fetchedMemberRequestsList;

  }



  Future<List<Map<String, dynamic>>> getMemberRequests() async{


    _isLoading = true;
    String message = '';
    List<Map<String, dynamic>> _fetchedMemberRequestsList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(hasDataConnection){

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          DocumentSnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('clubs').doc(user.clubId).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }


          Map<String, dynamic> snapshotData = snapshot.data();

          List<dynamic> requestsDynamic = [];
          print(snapshotData);

          if(snapshotData['requests'] != null){
            print(_fetchedMemberRequestsList);

            requestsDynamic = jsonDecode(
                snapshotData['requests']);
            requestsDynamic.forEach((dynamic item) {
              Map<String, dynamic> actualMap = Map.from(item);
              _fetchedMemberRequestsList.add(actualMap);
            });

          }

        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
    return _fetchedMemberRequestsList;

  }

  Future<List<Map<String, dynamic>>> getClubMembers() async{

    _isLoading = true;
    String message = '';
    List<Map<String, dynamic>> _fetchedClubMembersList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

          _clubMembers = [];

      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('users').where('club_id', isEqualTo: user.clubId).orderBy('username_lowercase', descending: false).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }


          Map<String, dynamic> snapshotData = {};


          if(snapshot.docs.length > 0){


            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();


              final Map<String, dynamic> clubMember = {
                Strings.uid: snap.id,
                Strings.username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
              };

              _fetchedClubMembersList.add(clubMember);

            }
          }
        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
    return _fetchedClubMembersList;

  }

  Future<bool> removeClubMember(String memberUid) async{

    _isLoading = true;
    String message = '';
    bool success = false;

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        String message = 'No Data Connection, unable to remove club member';

      } else {

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){

          try{
            await FirebaseFirestore.instance.collection('users').doc(memberUid).update({
              Strings.clubId: null,
              Strings.clubName: null,
              Strings.clubRole: null,
            }).timeout(Duration(seconds: 60));
            success = true;
          } catch(e){
            print(e);
          }
        }
      }

    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
    return success;

  }

  Future<void> leaveClub() async{

    _isLoading = true;
    String message = '';
    GlobalFunctions.showLoadingDialog('Leaving Club...');

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No Data Connection, unable to leave club';

      } else {

        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){

          try{
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              Strings.clubId: null,
              Strings.clubName: null,
              Strings.clubRole: null,
            }).timeout(Duration(seconds: 60));


            Map<String, dynamic> userData = {
              Strings.uid: GlobalFunctions.databaseValueString(user.uid),
              Strings.suspended: GlobalFunctions.boolToTinyInt(user.suspended),
              Strings.deleted: GlobalFunctions.boolToTinyInt(user.deleted),
              Strings.termsAccepted: GlobalFunctions.boolToTinyInt(user.termsAccepted),
              Strings.forcePasswordReset: GlobalFunctions.boolToTinyInt(user.forcePasswordReset),
              Strings.username: GlobalFunctions.encryptString(user.username),
              Strings.clubId: GlobalFunctions.databaseValueString(''),
              Strings.clubName: GlobalFunctions.databaseValueString(''),
              Strings.clubRole: GlobalFunctions.databaseValueString(''),
              Strings.requestedClubId: GlobalFunctions.databaseValueString(''),
            };

            user.requestedClubId = '';
            user.clubId = '';
            user.clubName = '';
            user.clubRole = '';
            sharedPreferences.setString(Strings.requestedClubId, '');
            sharedPreferences.setString(Strings.clubId, '');
            sharedPreferences.setString(Strings.clubName, '');
            sharedPreferences.setString(Strings.clubRole, '');


            int existingUser = await databaseHelper.checkAuthenticatedUserExists(user.uid);

            if(existingUser == 0){
              await databaseHelper.add(Strings.authenticationTable, userData);
            } else {
              await databaseHelper.updateRow(Strings.authenticationTable, userData, Strings.uid, user.uid);
            }

          } catch(e){
            print(e);
          }
        }
      }

    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    authenticationModel.notifyListeners();
    GlobalFunctions.dismissLoadingDialog();
    _navigationService.goBack();
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getAnnouncements() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedAnnouncementList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localAnnouncementCount;

        localAnnouncementCount = await databaseHelper.getRowCountWhere(Strings.announcementTable, Strings.clubId, user.clubId);

        if (localAnnouncementCount > 0) {

          List<Map<String, dynamic>> localRecords = await databaseHelper.getRowsWhereOrderByDirectionLast10(Strings.announcementTable, Strings.clubId, user.clubId, Strings.timestamp, 'DESC');

          if(localRecords.length >0){

            for (Map<String, dynamic> localRecord in localRecords) {

              final Map<String, dynamic> announcement = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.username: GlobalFunctions.databaseValueString(localRecord[Strings.username]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.clubId: GlobalFunctions.databaseValueString(localRecord[Strings.clubId]),
                Strings.body: GlobalFunctions.databaseValueString(localRecord[Strings.body]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedAnnouncementList.add(announcement);
            }
            _announcements = _fetchedAnnouncementList;
            message = 'No data connection, unable to fetch latest Announcements';

          }

        } else {
          _announcements = [];
          message = 'No Announcements available, please try again when you have a data connection';
        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('announcements').where('club_id', isEqualTo: user.clubId).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Announcements found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {


              snapshotData = snap.data();

              final Map<String, dynamic> announcement = {
                Strings.documentId: snap.id,
                Strings.username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.clubId: GlobalFunctions.databaseValueString(snapshotData[Strings.clubId]),
                Strings.body: GlobalFunctions.databaseValueString(snapshotData[Strings.body]),
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedAnnouncementList.add(announcement);

              Map<String, dynamic> localData = Map.from(announcement);
              int queryResult;

              int existingAnnouncement = await databaseHelper.checkAnnouncementExists(snap.id);

              if (existingAnnouncement == 0) {

                queryResult = await databaseHelper.add(Strings.announcementTable, localData);
              } else {

                queryResult = await databaseHelper.updateRow(Strings.announcementTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedAnnouncementList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                b[Strings.timestamp].compareTo(a[Strings.timestamp]));


            _announcements = _fetchedAnnouncementList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selAnnouncementId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreAnnouncements() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedAnnouncementList = [];

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localAnnouncementCount;

        localAnnouncementCount = await databaseHelper.getRowCountWhere(Strings.announcementTable, Strings.clubId, user.clubId);

        if (localAnnouncementCount > 0) {

          int currentLength = _announcements.length;

          List<Map<String, dynamic>> localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirection10More(Strings.announcementTable, Strings.serverUploaded, 1, Strings.uid, user.uid, Strings.timestamp, 'DESC', _announcements[currentLength - 1][Strings.timestamp]);

          if(localRecords.length >0){

            for (Map<String, dynamic> localRecord in localRecords) {

              final Map<String, dynamic> announcement = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.username: GlobalFunctions.databaseValueString(localRecord[Strings.username]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.clubId: GlobalFunctions.databaseValueString(localRecord[Strings.clubId]),
                Strings.body: GlobalFunctions.databaseValueString(localRecord[Strings.body]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedAnnouncementList.add(announcement);
            }
            _announcements.addAll(_fetchedAnnouncementList);
            message = 'No data connection, unable to fetch latest Announcements';

          }

        } else {
          _announcements = [];
          message = 'No Announcements available, please try again when you have a data connection';
        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          int currentLength = _announcements.length;
          DateTime latestDate = DateTime.parse(_announcements[currentLength - 1][Strings.timestamp]);



          try {
            snapshot = await FirebaseFirestore.instance.collection('announcements').where(
                'uid', isEqualTo: user.uid).orderBy(
                'timestamp', descending: true).startAfter(
                [Timestamp.fromDate(latestDate)]).limit(10)
                .get()
                .timeout(Duration(seconds: 90));
          } catch(e) {
            print(e);
          }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Announcements found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              print(snapshotData[Strings.body]);

              snapshotData = snap.data();

              final Map<String, dynamic> announcement = {
                Strings.documentId: snap.id,
                Strings.username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.clubId: GlobalFunctions.databaseValueString(snapshotData[Strings.clubId]),
                Strings.body: GlobalFunctions.databaseValueString(snapshotData[Strings.body]),
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedAnnouncementList.add(announcement);

              Map<String, dynamic> localData = Map.from(announcement);
              int queryResult;

              int existingAnnouncement = await databaseHelper.checkAnnouncementExists(snap.id);

              if (existingAnnouncement == 0) {

                queryResult = await databaseHelper.add(Strings.announcementTable, localData);
              } else {

                queryResult = await databaseHelper.updateRow(Strings.announcementTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedAnnouncementList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                b[Strings.timestamp].compareTo(a[Strings.timestamp]));


            _announcements.addAll(_fetchedAnnouncementList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Announcements';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selAnnouncementId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

}