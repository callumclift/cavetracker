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


class ActivityLogModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();


  ActivityLogModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _activityLogs = [];
  List<Map<String, dynamic>> _activityLogsClub = [];
  String _selActivityLogId;
  String _selActivityLogClubId;
  int crashedIndex = 0;
  bool getLostImage = false;
  final dateFormatDay = DateFormat("dd-MM-yyyy");
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



  List<Map<String, dynamic>> get allActivityLogs {
    return List.from(_activityLogs);
  }
  List<Map<String, dynamic>> get allActivityLogsClub {
    return List.from(_activityLogsClub);
  }
  int get selectedActivityLogIndex {
    return _activityLogs.indexWhere((Map<String, dynamic> activityLog) {
      return activityLog[Strings.documentId] == _selActivityLogId;
    });
  }
  int get selectedActivityLogClubIndex {
    return _activityLogsClub.indexWhere((Map<String, dynamic> activityLogClub) {
      return activityLogClub[Strings.documentId] == _selActivityLogClubId;
    });
  }
  String get selectedActivityLogId {
    return _selActivityLogId;
  }
  String get selectedActivityLogClubId {
    return _selActivityLogClubId;
  }

  Map<String, dynamic> get selectedActivityLog {
    if (_selActivityLogId == null) {
      return null;
    }
    return _activityLogs.firstWhere((Map<String, dynamic> activityLog) {
      return activityLog[Strings.documentId] == _selActivityLogId;
    });
  }
  Map<String, dynamic> get selectedActivityLogClub {
    if (_selActivityLogClubId == null) {
      return null;
    }
    return _activityLogsClub.firstWhere((Map<String, dynamic> activityLog) {
      return activityLog[Strings.documentId] == _selActivityLogClubId;
    });
  }
  void selectActivityLog(String activityLogId) {
    _selActivityLogId = activityLogId;
    if (activityLogId != null) {
      notifyListeners();
    }
  }
  void selectActivityLogClub(String activityLogClubId) {
    _selActivityLogClubId = activityLogClubId;
    if (activityLogClubId != null) {
      notifyListeners();
    }
  }


  Future<bool> submitActivityLog(String title, String caveName, String details, DateTime date, bool share, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Submitting Activity Log...');
    String message = '';
    bool success = false;
    List<String> storageUrlList = [];
    List<File> compressedImageFiles = [];
    List<String> base64s = [];

    for(File image in images){
      if(image != null){
        List<int> imageBytes = await GlobalFunctions.getImageBytes(image);
        String base64Image = await compute(GlobalFunctions.getBase64Image, imageBytes);
        if(base64Image != null) base64s.add(base64Image);
        compressedImageFiles.add(image);

      }
    }

    DatabaseHelper _databaseHelper = DatabaseHelper();
    int count = await _databaseHelper
        .getRowCount(Strings.activityLogTable);
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }

    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.username: user.username,
      Strings.title: title,
      Strings.caveName: caveName == 'Select One' ? '' : caveName,
      Strings.details: details,
      //Strings.date: date == null ? null : DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch).toIso8601String(),
      Strings.share: GlobalFunctions.boolToTinyInt(share),
      Strings.images: temporaryPaths.length < 1 ? null : await compute(jsonEncode, temporaryPaths),
      Strings.imageFiles: null,
      Strings.localImages: base64s.length < 1 ? null : await compute(jsonEncode, base64s),
      Strings.pendingTime: DateTime.now().toIso8601String(),
      Strings.serverUploaded: 0,
    };

    int result = await _databaseHelper.add(Strings.activityLogTable, localData);

    if (result != 0) {
      message = 'Activity Log has successfully been added to local database';
    }


    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);

        try {

          DocumentReference ref =
          await FirebaseFirestore.instance.collection('activity_logs').add({
            Strings.uid: user.uid,
            Strings.username: user.username,
            Strings.title: title,
            Strings.caveName: caveName,
            Strings.details: details,
            //Strings.date: date,
            Strings.share: share,
            Strings.images: null,
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: true,
          });

          DocumentSnapshot snap = await ref.get();

          //Images

            int index = 1;
            List<String> imageUrls = [];

            for(File image in compressedImageFiles){
              if(image == null) continue;
              final Reference storageRef =
              FirebaseStorage.instance.ref().child('${user.uid}/activityLogImages/${snap.id}/image${index.toString()}.jpg');

              final UploadTask uploadTask = storageRef.putFile(image, SettableMetadata(contentType: 'image/jpg'));

              final TaskSnapshot downloadUrl =
              (await uploadTask);

              String imageUrl = (await downloadUrl.ref.getDownloadURL());
              print('URL Is $imageUrl');
              imageUrls.add(imageUrl);
              index ++;

            }

            String encodedUrls;
            Map<String, dynamic> localData;


            if(imageUrls.length > 0){

              encodedUrls = await compute(jsonEncode, imageUrls);

              await FirebaseFirestore.instance.collection('activity_logs').doc(snap.id).update({
                Strings.images: encodedUrls
              }).timeout(Duration(seconds: 60));

              localData = {
                Strings.documentId: snap.id,
                Strings.serverUploaded: 1,
                Strings.images: encodedUrls,
                Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
              };


            } else {

              localData = {
                Strings.documentId: snap.id,
                Strings.serverUploaded: 1,
                Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
              };
            }

            int queryResult = await _databaseHelper.updateRow(
                Strings.activityLogTable,
                localData,
                Strings.localId,
                id);

            if (queryResult != 0) {
              success = true;
              message = 'Activity Log uploaded successfully';
            }



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Activity Log';

          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

        } catch (e) {
          print(e);
          message = e.toString();
          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

          print(e);
        }
      }

    } else {

      message = 'No data connection, Activity Log has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    if(success) _databaseHelper.resetTemporaryActivityLog(user.uid);
    GlobalFunctions.dismissLoadingDialog();
    if(edit){
      _navigationService.goBack();
      _navigationService.goBack();
      getActivityLogs();
    }
    GlobalFunctions.showToast(message);
    return success;


  }


  Future<Map<String, dynamic>> uploadPendingActivityLogs() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<File> compressedImageFiles = [];
    List<String> base64s = [];
    DatabaseHelper _databaseHelper = DatabaseHelper();


    try {

        List<Map<String, dynamic>> activityLogs =
        await databaseHelper.getAllWhereAndWhere(
            Strings.activityLogTable,
            DatabaseHelper.serverUploaded,
            0,
            DatabaseHelper.uid,
            user.uid);


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if (isTokenExpired)
          authenticated = await authenticationModel.reAuthenticate();

        if (authenticated) {

        for (Map<String, dynamic> activityLog in activityLogs) {
          success = false;


          if (activityLog[Strings.images] != null) {

              List<dynamic> temporaryPaths = jsonDecode(
                  activityLog[Strings.images]);

              if (temporaryPaths != null) {
                int index = 0;

                temporaryPaths.forEach((dynamic path) {
                  if (path != null) {
                    if (File(path).existsSync()) {
                      images[index] = File(path);
                    }
                  }

                  index++;
                });
              }

              for (File image in images) {
                if (image != null) {
                  List<int> imageBytes = await GlobalFunctions.getImageBytes(
                      image);
                  String base64Image = await compute(
                      GlobalFunctions.getBase64Image, imageBytes);
                  if (base64Image != null) base64s.add(base64Image);
                  compressedImageFiles.add(image);
                }
              }
            }

            await GlobalFunctions.checkFirebaseStorageFail(databaseHelper);

            DocumentReference ref =
            await FirebaseFirestore.instance.collection('activity_logs').add({
              Strings.uid: user.uid,
              Strings.username: user.username,
              Strings.title: activityLog[GlobalFunctions.databaseValueString(Strings.title)],
              Strings.caveName: activityLog[GlobalFunctions.databaseValueString(Strings.caveName)],
              Strings.details: activityLog[GlobalFunctions.databaseValueString(Strings.details)],
              //Strings.date: activityLog[Strings.date] == null ? null : DateTime.parse(activityLog[Strings.date]),
              Strings.share: activityLog[GlobalFunctions.tinyIntToBool(Strings.share)],
              Strings.images: null,
              Strings.timestamp: FieldValue.serverTimestamp(),
              Strings.serverUploaded: true,
            });

            DocumentSnapshot snap = await ref.get();

            //Images

            int index = 1;
            List<String> imageUrls = [];

            for(File image in compressedImageFiles){
              if(image == null) continue;
              final Reference storageRef =
              FirebaseStorage.instance.ref().child('${user.uid}/activityLogImages/${snap.id}/image${index.toString()}.jpg');

              final UploadTask uploadTask = storageRef.putFile(image, SettableMetadata(contentType: 'image/jpg'));

              final TaskSnapshot downloadUrl =
              (await uploadTask);

              String imageUrl = (await downloadUrl.ref.getDownloadURL());
              print('URL Is $imageUrl');
              imageUrls.add(imageUrl);
              index ++;

            }

            String encodedUrls;
            Map<String, dynamic> localData;


            if(imageUrls.length > 0){

              encodedUrls = await compute(jsonEncode, imageUrls);

              await FirebaseFirestore.instance.collection('activity_logs').doc(snap.id).update({
                Strings.images: encodedUrls
              }).timeout(Duration(seconds: 60));

              localData = {
                Strings.documentId: snap.id,
                Strings.serverUploaded: 1,
                Strings.images: encodedUrls,
                Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
              };


            } else {

              localData = {
                Strings.documentId: snap.id,
                Strings.serverUploaded: 1,
                Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
              };
            }

            int queryResult = await _databaseHelper.updateRow(
                Strings.activityLogTable,
                localData,
                Strings.localId,
                activityLog[Strings.localId]);

            if (queryResult != 0) {
              success = true;
            }
        }

        message = 'Data Successfully Uploaded';

        }
      } on TimeoutException catch (_) {
        // A timeout occurred.
        message =
        'Network Timeout communicating with the server, unable to upload Forms';
        await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, databaseHelper);

      } catch (e) {
        await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, databaseHelper);

        print(e);
      }


    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }


  Future<void> getActivityLogs([bool all = false]) async{
    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedActivityLogList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localChecklistCount;

        if(all){
          localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.activityLogTable, Strings.share, 1, Strings.serverUploaded, 1);
        } else {
          localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.activityLogTable, Strings.uid, user.uid, Strings.serverUploaded, 1);

        }


        if (localChecklistCount > 0) {

          List<Map<String, dynamic>> localRecords;

          if(all){
            localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirectionLast10(Strings.activityLogTable, Strings.serverUploaded, 1, Strings.share, 1, Strings.timestamp, 'DESC');
          } else {
            localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirectionLast10(Strings.activityLogTable, Strings.serverUploaded, 1, Strings.uid, user.uid, Strings.timestamp, 'DESC');

          }

          if(localRecords.length >0){

            for (Map<String, dynamic> localRecord in localRecords) {

              List<Uint8List> localImages = [];

              if(localRecord[Strings.localImages]!= null){

                List<dynamic> base64s = jsonDecode(localRecord[Strings.localImages]);
                if(base64s != null){

                  for(dynamic base64 in base64s){

                    String base64String = base64;
                    Uint8List imageBytes = await compute(base64Decode, base64String);
                    localImages.add(imageBytes);
                    print(localImages);
                  }
                }
              }

              final Map<String, dynamic> activityLog = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.username: GlobalFunctions.databaseValueString(localRecord[Strings.username]),
                //Strings.date: localRecord[Strings.date] == null ? null : localRecord[Strings.date],
                Strings.share: GlobalFunctions.tinyIntToBool(localRecord[Strings.share]),
                Strings.title: GlobalFunctions.databaseValueString(localRecord[Strings.title]),
                Strings.caveName: GlobalFunctions.databaseValueString(localRecord[Strings.caveName]),
                Strings.details: GlobalFunctions.databaseValueString(localRecord[Strings.details]),
                Strings.images: localRecord[Strings.images] == null ? null : localRecord[Strings.images],
                Strings.localImages: null,
                Strings.localImages: localImages.length < 1 ? null : localImages,
                Strings.serverUploaded: GlobalFunctions.tinyIntToBool(localRecord[Strings.serverUploaded]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedActivityLogList.add(activityLog);
            }

            if(all){
              _activityLogsClub = _fetchedActivityLogList;

            } else {
              _activityLogs = _fetchedActivityLogList;

            }
            message = 'No data connection, unable to fetch latest Activity Logs';

          }

        } else {
          if(all){
            _activityLogsClub = [];

          } else {
            _activityLogs = [];

          }
          message = 'No Activity Logs available, please try again when you have a data connection';
        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

            if(all){
              try{
                snapshot = await FirebaseFirestore.instance.collection('activity_logs').where('share', isEqualTo: true).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
              } catch(e){
                print(e);
              }
            } else {
              try{
                snapshot = await FirebaseFirestore.instance.collection('activity_logs').where('uid', isEqualTo: user.uid).orderBy('timestamp', descending: true).limit(10).get().timeout(Duration(seconds: 90));
              } catch(e){
                print(e);
              }
            }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Activity Logs found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> activityLog = {
                Strings.documentId: snap.id,
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
                //Strings.date: snapshotData[Strings.date] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.date].millisecondsSinceEpoch).toIso8601String(),
                Strings.share: snapshotData[Strings.share] == null ? false : snapshotData[Strings.share],
                Strings.title: GlobalFunctions.databaseValueString(snapshotData[Strings.title]),
                Strings.caveName: GlobalFunctions.databaseValueString(snapshotData[Strings.caveName]),
                Strings.details: GlobalFunctions.databaseValueString(snapshotData[Strings.details]),
                Strings.images: snapshotData[Strings.images] == null ? null : snapshotData[Strings.images],
                Strings.imageFiles: null,
                Strings.serverUploaded: snapshotData[Strings.serverUploaded] == null ? false : snapshotData[Strings.serverUploaded],
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedActivityLogList.add(activityLog);

              Map<String, dynamic> localData = Map.from(activityLog);
              localData[Strings.serverUploaded] = GlobalFunctions.boolToTinyInt(activityLog[Strings.serverUploaded]);
              int queryResult;

              int existingActivityLog = await databaseHelper.checkActivityLogExists(snap.id);

              if (existingActivityLog == 0) {

                queryResult = await databaseHelper.add(Strings.activityLogTable, localData);
              } else {

                  queryResult = await databaseHelper.updateRow(Strings.activityLogTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedActivityLogList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                b[Strings.timestamp].compareTo(a[Strings.timestamp]));

            if(all){
              _activityLogsClub = _fetchedActivityLogList;

            } else {
              _activityLogs = _fetchedActivityLogList;

            }

          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Activity Logs';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selActivityLogId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreActivityLogs([bool all  = false]) async{

    String message = '';

    List<Map<String, dynamic>> _fetchedActivityLogList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localChecklistCount;

        if(all){

          localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.activityLogTable, Strings.share, 1, Strings.serverUploaded, 1);

        } else {
          localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.activityLogTable, Strings.uid, user.uid, Strings.serverUploaded, 1);

        }


        if (localChecklistCount > 0) {

          int currentLength;

          if(all){
            currentLength = _activityLogsClub.length;

          } else {
            currentLength = _activityLogs.length;

          }



          List<Map<String, dynamic>> localRecords;

          if(all){
            localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirection10More(Strings.activityLogTable, Strings.serverUploaded, 1, Strings.share, 1, Strings.timestamp, 'DESC', _activityLogsClub[currentLength - 1][Strings.timestamp]);
          } else {
            localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirection10More(Strings.activityLogTable, Strings.serverUploaded, 1, Strings.uid, user.uid, Strings.timestamp, 'DESC', _activityLogs[currentLength - 1][Strings.timestamp]);
          }



          if(localRecords.length >0){

            for (Map<String, dynamic> localRecord in localRecords) {

              List<Uint8List> localImages = [];

              if(localRecord[Strings.localImages]!= null){

                List<dynamic> base64s = jsonDecode(localRecord[Strings.localImages]);
                if(base64s != null){

                  for(dynamic base64 in base64s){

                    String base64String = base64;
                    Uint8List imageBytes = await compute(base64Decode, base64String);
                    localImages.add(imageBytes);
                    print(localImages);
                  }
                }
              }

              final Map<String, dynamic> activityLog = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.username: GlobalFunctions.databaseValueString(localRecord[Strings.username]),
                //Strings.date: localRecord[Strings.date] == null ? null : localRecord[Strings.date],
                Strings.share: GlobalFunctions.tinyIntToBool(localRecord[Strings.share]),
                Strings.title: GlobalFunctions.databaseValueString(localRecord[Strings.title]),
                Strings.caveName: GlobalFunctions.databaseValueString(localRecord[Strings.caveName]),
                Strings.details: GlobalFunctions.databaseValueString(localRecord[Strings.details]),
                Strings.images: localRecord[Strings.images] == null ? null : localRecord[Strings.images],
                Strings.localImages: null,
                Strings.localImages: localImages.length < 1 ? null : localImages,
                Strings.serverUploaded: GlobalFunctions.tinyIntToBool(localRecord[Strings.serverUploaded]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedActivityLogList.add(activityLog);
            }

            if(all){
              _activityLogsClub.addAll(_fetchedActivityLogList);

            } else {
              _activityLogs.addAll(_fetchedActivityLogList);

            }

            message = 'No data connection, unable to fetch latest Activity Logs';

          }

        } else {

          message = 'No more Activity Logs available, please try again when you have a data connection';

        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength;
          DateTime latestDate;

          if(all){
            currentLength = _activityLogsClub.length;
            latestDate = DateTime.parse(_activityLogsClub[currentLength - 1][Strings.timestamp]);

          } else {
            currentLength = _activityLogs.length;
            latestDate = DateTime.parse(_activityLogs[currentLength - 1][Strings.timestamp]);

          }



          if(all){
            try {
              snapshot = await FirebaseFirestore.instance.collection('activity_logs').where(
                  'share', isEqualTo: true).orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }
          } else {
            try {
              snapshot = await FirebaseFirestore.instance.collection('activity_logs').where(
                  'uid', isEqualTo: user.uid).orderBy(
                  'timestamp', descending: true).startAfter(
                  [Timestamp.fromDate(latestDate)]).limit(10)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }
          }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No more Activity Logs found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> activityLog = {
                Strings.documentId: snap.id,
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.username: GlobalFunctions.databaseValueString(snapshotData[Strings.username]),
                //Strings.date: snapshotData[Strings.date] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.date].millisecondsSinceEpoch).toIso8601String(),
                Strings.share: snapshotData[Strings.share] == null ? false : snapshotData[Strings.share],
                Strings.title: GlobalFunctions.databaseValueString(snapshotData[Strings.title]),
                Strings.caveName: GlobalFunctions.databaseValueString(snapshotData[Strings.caveName]),
                Strings.details: GlobalFunctions.databaseValueString(snapshotData[Strings.details]),
                Strings.images: snapshotData[Strings.images] == null ? null : snapshotData[Strings.images],
                Strings.imageFiles: null,
                Strings.serverUploaded: snapshotData[Strings.serverUploaded] == null ? false : snapshotData[Strings.serverUploaded],
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedActivityLogList.add(activityLog);

              Map<String, dynamic> localData = Map.from(activityLog);
              localData[Strings.serverUploaded] = GlobalFunctions.boolToTinyInt(activityLog[Strings.serverUploaded]);
              int queryResult;

              int existingActivityLog = await databaseHelper.checkActivityLogExists(snap.id);

              if (existingActivityLog == 0) {

                queryResult = await databaseHelper.add(Strings.activityLogTable, localData);
              } else {

                queryResult = await databaseHelper.updateRow(Strings.activityLogTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedActivityLogList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                b[Strings.timestamp].compareTo(a[Strings.timestamp]));

            if(all){
              _activityLogsClub.addAll(_fetchedActivityLogList);

            } else {
              _activityLogs.addAll(_fetchedActivityLogList);

            }


          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Activity Logs';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    notifyListeners();
    _selActivityLogId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }




  Future<void> deleteActivityLog() async{

    GlobalFunctions.showLoadingDialog('Deleting Activity Log...');
    String message;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          await FirebaseFirestore.instance.collection('activity_logs').doc(selectedActivityLogId).delete();

          DatabaseHelper databaseHelper = DatabaseHelper();
          int queryResult = await databaseHelper.delete(Strings.activityLogTable, selectedActivityLogId);

          if(queryResult != 0){
            message = 'Activity Log deleted';
            await getActivityLogs();
            notifyListeners();
          }



        } on TimeoutException catch (_) {

          GlobalFunctions.showToast('Network Timeout communicating with the server, unable to delete Customer');

        } catch (error) {
          print(error);
        }

      }

    } else {
      message = 'No data connection, unable to delete Activity Log';
    }

    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);

  }

}