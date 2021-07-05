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


class CallOutModel extends ChangeNotifier {

  AuthenticationModel authenticationModel = AuthenticationModel();
  final NavigationService _navigationService = locator<NavigationService>();


  CallOutModel(this.authenticationModel);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> _callOuts = [];
  String _selCallOutId;
  final dateFormat = DateFormat("dd/MM/yyyy HH:mm");




  List<Map<String, dynamic>> get allCallOuts {
    return List.from(_callOuts);
  }
  int get selectedCallOutIndex {
    return _callOuts.indexWhere((Map<String, dynamic> callOut) {
      return callOut[Strings.documentId] == _selCallOutId;
    });
  }
  String get selectedCallOutId {
    return _selCallOutId;
  }

  Map<String, dynamic> get selectedCallOut {
    if (_selCallOutId == null) {
      return null;
    }
    return _callOuts.firstWhere((Map<String, dynamic> callOut) {
      return callOut[Strings.documentId] == _selCallOutId;
    });
  }
  void selectCallOut(String callOutId) {
    _selCallOutId = callOutId;
    if (callOutId != null) {
      notifyListeners();
    }
  }


  Future<bool> submitCallOut(Map<String, dynamic> callOutData) async {

    GlobalFunctions.showLoadingDialog('Submitting Call Out...');
    String message = '';
    bool success = false;

    DatabaseHelper _databaseHelper = DatabaseHelper();
    int count = await _databaseHelper.getRowCount(Strings.callOutTable);
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
      Strings.details: callOutData[Strings.details],
      Strings.entryDate: callOutData[Strings.entryDate] == null ? null : DateTime.fromMillisecondsSinceEpoch(callOutData[Strings.entryDate].millisecondsSinceEpoch).toIso8601String(),
      Strings.exitDate: callOutData[Strings.exitDate] == null ? null : DateTime.fromMillisecondsSinceEpoch(callOutData[Strings.exitDate].millisecondsSinceEpoch).toIso8601String(),
      DatabaseHelper.pendingTime: DateTime.now().toIso8601String(),
      DatabaseHelper.serverUploaded: 0,
    };


    int result = await _databaseHelper.add(Strings.callOutTable, localData);

    if (result != 0) {
      message = 'Activity Log has successfully been added to local database';
    }


    bool hasDataConnection = await GlobalFunctions.hasDataConnection();


    if(hasDataConnection){

      bool isTokenExpired = GlobalFunctions.isTokenExpired();
      bool authenticated = true;

      if(isTokenExpired) authenticated = await authenticationModel.reAuthenticate();

      if(authenticated){

        try {

          DocumentReference ref =
          await FirebaseFirestore.instance.collection('activity_logs').add({
            Strings.uid: user.uid,
            Strings.details: callOutData[Strings.details],
            Strings.entryDate: callOutData[Strings.entryDate],
            Strings.exitDate: callOutData[Strings.exitDate],
            Strings.timestamp: FieldValue.serverTimestamp(),
            Strings.serverUploaded: true,
          });

          DocumentSnapshot snap = await ref.get();



          String encodedUrls;
          Map<String, dynamic> localData;


            localData = {
              Strings.documentId: snap.id,
              Strings.serverUploaded: 1,
              Strings.timestamp: DateTime.fromMillisecondsSinceEpoch(snap.data()[Strings.timestamp].millisecondsSinceEpoch).toIso8601String()
            };


          int queryResult = await _databaseHelper.updateRow(
              Strings.callOutTable,
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


        } catch (e) {
          print(e);
          message = e.toString();

          print(e);
        }
      }

    } else {

      message = 'No data connection, please submit when you have a valid connection';
      success = true;

    }

    if(success) _databaseHelper.resetTemporaryCallOut(user.uid);
    GlobalFunctions.dismissLoadingDialog();
    GlobalFunctions.showToast(message);
    return success;


  }

}