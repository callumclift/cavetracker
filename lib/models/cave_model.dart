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


class CaveModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();


  CaveModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _caves = [];
  String _selCaveId;
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



  List<Map<String, dynamic>> get allCaves {
    return List.from(_caves);
  }
  int get selectedCaveIndex {
    return _caves.indexWhere((Map<String, dynamic> cave) {
      return cave[Strings.documentId] == _selCaveId;
    });
  }
  String get selectedCaveId {
    return _selCaveId;
  }

  Map<String, dynamic> get selectedCave {
    if (_selCaveId == null) {
      return null;
    }
    return _caves.firstWhere((Map<String, dynamic> cave) {
      return cave[Strings.documentId] == _selCaveId;
    });
  }
  void selectCave(String caveId) {
    _selCaveId = caveId;
    if (caveId != null) {
      notifyListeners();
    }
  }

  TextEditingController _searchControllerActivityLog = TextEditingController();
  String searchControllerValueActivityLog = '';

  TextEditingController get searchControllerActivityLog {
    return _searchControllerActivityLog;
  }

  Future<bool> submitCave(Map<String, dynamic> caveDetails, [bool edit = false]) async {

    GlobalFunctions.showLoadingDialog('Submitting Cave...');
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
        .getRowCount(Strings.caveTable);
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }

    String nameString = caveDetails[Strings.name];
    String lowercaseName = nameString.toLowerCase();


    Map<String, dynamic> localData = {
      Strings.localId: id,
      Strings.documentId: null,
      Strings.uid: user.uid,
      Strings.name: caveDetails[Strings.name],
      Strings.nameLowercase: lowercaseName,
      Strings.description: caveDetails[Strings.description],
      Strings.caveLatitude: caveDetails[Strings.caveLatitude],
      Strings.caveLongitude: caveDetails[Strings.caveLongitude],
      Strings.parkingLatitude: caveDetails[Strings.parkingLatitude],
      Strings.parkingLongitude: caveDetails[Strings.parkingLongitude],
      Strings.parkingPostCode: caveDetails[Strings.parkingPostCode],
      Strings.verticalRange: caveDetails[Strings.verticalRange],
      Strings.length: caveDetails[Strings.length],
      Strings.county: caveDetails[Strings.county] == 'Select One' ? '' : caveDetails[Strings.county],
      Strings.images: temporaryPaths.length < 1 ? null : await compute(jsonEncode, temporaryPaths),
      Strings.imageFiles: null,
      Strings.localImages: base64s.length < 1 ? null : await compute(jsonEncode, base64s),
      DatabaseHelper.pendingTime: DateTime.now().toIso8601String(),
      DatabaseHelper.serverUploaded: 0,
    };


    int result = await _databaseHelper.add(Strings.caveTable, localData);

    if (result != 0) {
      message = 'Cave has successfully been added to local database';
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
          await FirebaseFirestore.instance.collection('caves').add({
            Strings.uid: user.uid,
            Strings.name: caveDetails[Strings.name],
            Strings.nameLowercase: lowercaseName,
            Strings.description: caveDetails[Strings.description],
            Strings.caveLatitude: caveDetails[Strings.caveLatitude],
            Strings.caveLongitude: caveDetails[Strings.caveLongitude],
            Strings.parkingLatitude: caveDetails[Strings.parkingLatitude],
            Strings.parkingLongitude: caveDetails[Strings.parkingLongitude],
            Strings.parkingPostCode: caveDetails[Strings.parkingPostCode],
            Strings.verticalRange: caveDetails[Strings.verticalRange],
            Strings.length: caveDetails[Strings.length],
            Strings.county: caveDetails[Strings.county] == 'Select One' ? '' : caveDetails[Strings.county],
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
              FirebaseStorage.instance.ref().child('${user.uid}/caveImages/${snap.id}/image${index.toString()}.jpg');

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

              await FirebaseFirestore.instance.collection('caves').doc(snap.id).update({
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
                Strings.caveTable,
                localData,
                Strings.localId,
                id);

            if (queryResult != 0) {
              success = true;
              message = 'Cave uploaded successfully';
            }



        } on TimeoutException catch (_) {
          // A timeout occurred.
          message = 'Network Timeout communicating with the server, unable to upload Cave';

          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

        } catch (e) {
          print(e);
          message = e.toString();
          await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

          print(e);
        }
      }

    } else {

      message = 'No data connection, Cave has been saved locally, please upload when you have a valid connection';
      success = true;

    }

    if(success) _databaseHelper.resetTemporaryCave(user.uid);
    GlobalFunctions.dismissLoadingDialog();
    if(edit){
      _navigationService.goBack();
      _navigationService.goBack();
      getCaves();
    }
    GlobalFunctions.showToast(message);
    return success;


  }

  Future<Map<String, dynamic>> uploadPendingCaves() async {
    _isLoading = true;
    String message = 'Something went wrong!';
    bool success = false;
    List<String> storageUrlList = [];
    List<File> compressedImageFiles = [];
    List<String> base64s = [];
    DatabaseHelper _databaseHelper = DatabaseHelper();


    try {

      List<Map<String, dynamic>> caves =
      await _databaseHelper.getAllWhereAndWhere(
          Strings.caveTable,
          DatabaseHelper.serverUploaded,
          0,
          DatabaseHelper.uid,
          user.uid);


      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if (isTokenExpired)
        authenticated = await authenticationModel.reAuthenticate();

      if (authenticated) {

        for (Map<String, dynamic> cave in caves) {
          success = false;


          if (cave[Strings.images] != null) {

            List<dynamic> temporaryPaths = jsonDecode(
                cave[Strings.images]);

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

          await GlobalFunctions.checkFirebaseStorageFail(_databaseHelper);



          DocumentReference ref =
          await FirebaseFirestore.instance.collection('caves').add({
            Strings.uid: user.uid,
            Strings.name: cave[GlobalFunctions.databaseValueString(Strings.name)],
            Strings.nameLowercase: cave[GlobalFunctions.databaseValueString(Strings.nameLowercase)],
            Strings.description: cave[GlobalFunctions.databaseValueString(Strings.description)],
            Strings.caveLatitude: cave[GlobalFunctions.databaseValueString(Strings.caveLatitude)],
            Strings.caveLongitude: cave[GlobalFunctions.databaseValueString(Strings.caveLongitude)],
            Strings.parkingLatitude: cave[GlobalFunctions.databaseValueString(Strings.parkingLatitude)],
            Strings.parkingLongitude: cave[GlobalFunctions.databaseValueString(Strings.parkingLongitude)],
            Strings.parkingPostCode: cave[GlobalFunctions.databaseValueString(Strings.parkingPostCode)],
            Strings.verticalRange: cave[GlobalFunctions.databaseValueString(Strings.verticalRange)],
            Strings.length: cave[GlobalFunctions.databaseValueString(Strings.length)],
            Strings.county: cave[GlobalFunctions.databaseValueString(Strings.county)],
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
            FirebaseStorage.instance.ref().child('${user.uid}/caveImages/${snap.id}/image${index.toString()}.jpg');

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

            await FirebaseFirestore.instance.collection('caves').doc(snap.id).update({
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
              Strings.caveTable,
              localData,
              Strings.localId,
              cave[Strings.localId]);

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
      await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

    } catch (e) {
      await GlobalFunctions.checkAddFirebaseStorageRow(storageUrlList, _databaseHelper);

      print(e);
    }


    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }


  Future<List<String>> searchCavesActivityLog() async{
    _isLoading = true;
    notifyListeners();
    bool success = false;
    String message = 'Something went wrong';
    String searchString;

    List<String> _fetchedCaveList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localChecklistCount;

        localChecklistCount = await databaseHelper.getRowCount(Strings.caveTable);

        if (localChecklistCount > 0) {

          List<Map<String, dynamic>> localRecords = [];

          localRecords = await databaseHelper.getCavesLocally();

          if(localRecords.length >0){

            for (Map<String, dynamic> localRecord in localRecords) {

              String caveName = GlobalFunctions.databaseValueString(localRecord[Strings.name]);
              if(caveName.contains(searchControllerActivityLog.text.toLowerCase())) _fetchedCaveList.add(caveName);
            }

            _fetchedCaveList.sort((String b,
                String a) =>
                b.compareTo(a));

            _fetchedCaveList.forEach((String caveNameString){
              print(caveNameString);
            });

            success = true;

          }

        } else {
          GlobalFunctions.showToast('No Caves available, please try again when you have a data connection');
          success = true;
        }
      } else {

        //Check the expiry time on the token before making the request
        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){

          QuerySnapshot snapshot;
          searchString = searchControllerActivityLog.text.toLowerCase();


            try {
              snapshot =
              await FirebaseFirestore.instance.collection('caves').where('name_lowercase', isGreaterThanOrEqualTo: searchString).where('name_lowercase', isLessThanOrEqualTo: searchString + '\uf8ff').limit(20)
                  .get()
                  .timeout(Duration(seconds: 90));
            } catch(e) {
              print(e);
            }


            Map<String, dynamic> snapshotData = {};

            if(snapshot.docs.length < 1){
              success = true;

            } else {


                for (DocumentSnapshot snap in snapshot.docs) {
                  snapshotData = snap.data();

                  String caveName = GlobalFunctions.databaseValueString(snapshotData[Strings.name]);
                  _fetchedCaveList.add(caveName);
                  success = true;

                }



              _fetchedCaveList.sort((String b,
                  String a) =>
                  b.compareTo(a));
            }

        }

      }

    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Caves';
    } catch(e){
      _isLoading = false;
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
    return _fetchedCaveList;

  }


  Future<void> getCaves() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedCaveList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localChecklistCount;

        localChecklistCount = await databaseHelper.getRowCountWhere(Strings.caveTable, Strings.serverUploaded, 1);

        if (localChecklistCount > 0) {

          List<Map<String, dynamic>> localRecords = await databaseHelper.getRowsWhereOrderByDirectionLast10(Strings.caveTable, Strings.serverUploaded, 1, Strings.timestamp, 'DESC');

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

              final Map<String, dynamic> cave = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(localRecord[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(localRecord[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(localRecord[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(localRecord[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(localRecord[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(localRecord[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(localRecord[Strings.county]),
                Strings.images: localRecord[Strings.images] == null ? null : localRecord[Strings.images],
                Strings.localImages: null,
                Strings.localImages: localImages.length < 1 ? null : localImages,
                Strings.serverUploaded: GlobalFunctions.tinyIntToBool(localRecord[Strings.serverUploaded]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedCaveList.add(cave);
            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));

            _caves = _fetchedCaveList;
            message = 'No data connection, unable to fetch latest Caves';

          }

        } else {
          _caves = [];
          message = 'No Caves available, please try again when you have a data connection';
        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

            try{
              snapshot = await FirebaseFirestore.instance.collection('caves').orderBy('name_lowercase', descending: false).limit(10).get().timeout(Duration(seconds: 90));
            } catch(e){
              print(e);
            }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Caves found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> cave = {
                Strings.documentId: snap.id,
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(snapshotData[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(snapshotData[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(snapshotData[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(snapshotData[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(snapshotData[Strings.county]),
                Strings.images: snapshotData[Strings.images] == null ? null : snapshotData[Strings.images],
                Strings.imageFiles: null,
                Strings.serverUploaded: snapshotData[Strings.serverUploaded] == null ? false : snapshotData[Strings.serverUploaded],
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedCaveList.add(cave);

              Map<String, dynamic> localData = Map.from(cave);
              localData[Strings.serverUploaded] = GlobalFunctions.boolToTinyInt(cave[Strings.serverUploaded]);
              int queryResult;

              int existingCave = await databaseHelper.checkCaveExists(snap.id);

              if (existingCave == 0) {

                queryResult = await databaseHelper.add(Strings.caveTable, localData);
              } else {

                  queryResult = await databaseHelper.updateRow(Strings.caveTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));


            _caves = _fetchedCaveList;
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Caves';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selCaveId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }

  Future<void> getMoreCaves() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedCaveList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        int localChecklistCount;

        localChecklistCount = await databaseHelper.getRowCountWhereAndWhere(Strings.caveTable, Strings.uid, user.uid, Strings.serverUploaded, 1);

        if (localChecklistCount > 0) {

          int currentLength = _caves.length;


          List<Map<String, dynamic>> localRecords = await databaseHelper.getRowsWhereAndWhereOrderByDirection10More(Strings.caveTable, Strings.serverUploaded, 1, Strings.uid, user.uid, Strings.timestamp, 'DESC', _caves[currentLength - 1][Strings.timestamp]);



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

              final Map<String, dynamic> cave = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(localRecord[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(localRecord[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(localRecord[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(localRecord[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(localRecord[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(localRecord[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(localRecord[Strings.county]),
                Strings.images: localRecord[Strings.images] == null ? null : localRecord[Strings.images],
                Strings.localImages: null,
                Strings.localImages: localImages.length < 1 ? null : localImages,
                Strings.serverUploaded: GlobalFunctions.tinyIntToBool(localRecord[Strings.serverUploaded]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedCaveList.add(cave);
            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));
            _caves.addAll(_fetchedCaveList);

            message = 'No data connection, unable to fetch latest Caves';

          }

        } else {

          message = 'No more Caves available, please try again when you have a data connection';

        }


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;
          int currentLength = _caves.length;
          DateTime latestDate = DateTime.parse(_caves[currentLength - 1][Strings.timestamp]);



          try {
            snapshot = await FirebaseFirestore.instance.collection('caves').orderBy(
                'name_lowercase', descending: false).startAfter(
                [Timestamp.fromDate(latestDate)]).limit(10)
                .get()
                .timeout(Duration(seconds: 90));
          } catch(e) {
            print(e);
          }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Caves found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> cave = {
                Strings.documentId: snap.id,
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(snapshotData[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(snapshotData[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(snapshotData[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(snapshotData[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(snapshotData[Strings.county]),
                Strings.images: snapshotData[Strings.images] == null ? null : snapshotData[Strings.images],
                Strings.imageFiles: null,
                Strings.serverUploaded: snapshotData[Strings.serverUploaded] == null ? false : snapshotData[Strings.serverUploaded],
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedCaveList.add(cave);

              Map<String, dynamic> localData = Map.from(cave);
              localData[Strings.serverUploaded] = GlobalFunctions.boolToTinyInt(cave[Strings.serverUploaded]);
              int queryResult;

              int existingCave = await databaseHelper.checkCaveExists(snap.id);

              if (existingCave == 0) {

                queryResult = await databaseHelper.add(Strings.caveTable, localData);
              } else {

                queryResult = await databaseHelper.updateRow(Strings.caveTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));


            _caves.addAll(_fetchedCaveList);
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Caves';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selCaveId = null;
    if(message != '') GlobalFunctions.showToast(message);

  }


  Future<List<Map<String,dynamic>>> getAllCaves() async{

    List<Map<String, dynamic>> _fetchedCaveList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

        int localChecklistCount;

        localChecklistCount = await databaseHelper.getRowCountWhere(Strings.caveTable, Strings.serverUploaded, 1);

        if (localChecklistCount > 0) {

          List<Map<String, dynamic>> localRecords = await databaseHelper.getAllCaves();

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

              final Map<String, dynamic> cave = {
                Strings.documentId: GlobalFunctions.databaseValueString(localRecord[Strings.documentId]),
                Strings.uid: GlobalFunctions.databaseValueString(localRecord[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(localRecord[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(localRecord[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(localRecord[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(localRecord[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(localRecord[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(localRecord[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(localRecord[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(localRecord[Strings.county]),
                Strings.images: localRecord[Strings.images] == null ? null : localRecord[Strings.images],
                Strings.localImages: null,
                Strings.localImages: localImages.length < 1 ? null : localImages,
                Strings.serverUploaded: GlobalFunctions.tinyIntToBool(localRecord[Strings.serverUploaded]),
                Strings.timestamp: localRecord[Strings.timestamp] == null ? null : localRecord[Strings.timestamp]
              };

              _fetchedCaveList.add(cave);
            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));
            _caves = _fetchedCaveList;
          }

        }

    } on TimeoutException catch (_) {
      // A timeout occurred.
    } catch(e){
      print(e);

    }

    return _fetchedCaveList;


  }

  Future<void> downloadAllCaves() async{

    _isLoading = true;
    String message = '';

    List<Map<String, dynamic>> _fetchedCaveList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    try {

      bool hasDataConnection = await GlobalFunctions.hasDataConnection();

      if(!hasDataConnection){

        message = 'No data connection, unable to download all caves';


      } else {


        bool isTokenExpired = GlobalFunctions.isTokenExpired();
        bool authenticated = true;

        if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

        if(authenticated){


          QuerySnapshot snapshot;

          try{
            snapshot = await FirebaseFirestore.instance.collection('caves').orderBy('name_lowercase', descending: false).get().timeout(Duration(seconds: 90));
          } catch(e){
            print(e);
          }



          Map<String, dynamic> snapshotData = {};

          if(snapshot.docs.length < 1){
            message = 'No Caves found';
          } else {
            for (DocumentSnapshot snap in snapshot.docs) {

              snapshotData = snap.data();

              final Map<String, dynamic> cave = {
                Strings.documentId: snap.id,
                Strings.uid: GlobalFunctions.databaseValueString(snapshotData[Strings.uid]),
                Strings.name: GlobalFunctions.databaseValueString(snapshotData[Strings.name]),
                Strings.nameLowercase: GlobalFunctions.databaseValueString(snapshotData[Strings.nameLowercase]),
                Strings.description: GlobalFunctions.databaseValueString(snapshotData[Strings.description]),
                Strings.caveLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLatitude]),
                Strings.caveLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.caveLongitude]),
                Strings.parkingLatitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLatitude]),
                Strings.parkingLongitude: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingLongitude]),
                Strings.parkingPostCode: GlobalFunctions.databaseValueString(snapshotData[Strings.parkingPostCode]),
                Strings.verticalRange: GlobalFunctions.databaseValueString(snapshotData[Strings.verticalRange]),
                Strings.length: GlobalFunctions.databaseValueString(snapshotData[Strings.length]),
                Strings.county: GlobalFunctions.databaseValueString(snapshotData[Strings.county]),
                Strings.images: snapshotData[Strings.images] == null ? null : snapshotData[Strings.images],
                Strings.imageFiles: null,
                Strings.serverUploaded: snapshotData[Strings.serverUploaded] == null ? false : snapshotData[Strings.serverUploaded],
                Strings.timestamp: snapshotData[Strings.timestamp] == null ? null : DateTime.fromMillisecondsSinceEpoch(snapshotData[Strings.timestamp].millisecondsSinceEpoch).toIso8601String(),
              };

              _fetchedCaveList.add(cave);

              Map<String, dynamic> localData = Map.from(cave);
              localData[Strings.serverUploaded] = GlobalFunctions.boolToTinyInt(cave[Strings.serverUploaded]);
              int queryResult;

              int existingCave = await databaseHelper.checkCaveExists(snap.id);

              if (existingCave == 0) {

                queryResult = await databaseHelper.add(Strings.caveTable, localData);
              } else {

                queryResult = await databaseHelper.updateRow(Strings.caveTable, localData, Strings.documentId, snap.id);

              }

              if (queryResult != 0) {

                print('added to local db');
              } else {
                print('issue with local db');
              }

            }

            _fetchedCaveList.sort((Map<String, dynamic> a,
                Map<String, dynamic> b) =>
                a[Strings.nameLowercase].compareTo(b[Strings.nameLowercase]));


            _caves = _fetchedCaveList;
            message = 'All caves successfully downloaded & stored to device';
          }


        }

      }


    } on TimeoutException catch (_) {
      // A timeout occurred.
      message = 'Network Timeout communicating with the server, unable to fetch latest Caves';
    } catch(e){
      print(e);
      message = 'Something went wrong. Please try again';

    }

    _isLoading = false;
    notifyListeners();
    _selCaveId = null;
    GlobalFunctions.showToast(message);

  }




  Future<void> deleteCave() async{

    GlobalFunctions.showLoadingDialog('Deleting Cave...');
    String message;

    bool hasDataConnection = await GlobalFunctions.hasDataConnection();

    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          await FirebaseFirestore.instance.collection('caves').doc(selectedCaveId).delete();

          DatabaseHelper databaseHelper = DatabaseHelper();
          int queryResult = await databaseHelper.delete(Strings.caveTable, selectedCaveId);

          if(queryResult != 0){
            message = 'Cave deleted';
            await getCaves();
            notifyListeners();
          }



        } on TimeoutException catch (_) {

          GlobalFunctions.showToast('Network Timeout communicating with the server, unable to delete Customer');

        } catch (error) {
          print(error);
        }

      }

    } else {
      message = 'No data connection, unable to delete Cave';
    }

    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);

  }

}

class Cave {

  String documentId;
  String uid;
  String name;
  String description;
  String caveLatitude;
  String caveLongitude;
  String parkingLatitude;
  String parkingLongitude;
  String parkingPostCode;
  String verticalRange;
  String length;
  String county;

  Cave(
      {@required this.documentId,
        @required this.uid,
        @required this.name,
        @required this.description,
        @required this.caveLatitude,
        @required this.caveLongitude,
        @required this.parkingLatitude,
        @required this.parkingLongitude,
        @required this.parkingPostCode,
        @required this.verticalRange,
        @required this.length,
        @required this.county
      });
}