import 'dart:convert';
import 'dart:io' show Directory, File, FileSystemEntity, Platform;
import 'package:caving_app/utils/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:bot_toast/bot_toast.dart';
import 'dart:async';
import '../shared/global_config.dart';
import '../shared/strings.dart';




import 'global_config.dart';

class GlobalFunctions {


  static void showToast(String message) {
    BotToast.showText(text: message, align: Alignment.center, duration: Duration(milliseconds: 2500));
  }


  static Future <bool> hasDataConnection() async {

    bool connected = false;
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

    if(connectivityResult != ConnectivityResult.none){
      connected = true;
    }

    return connected;
  }


  static bool isTokenExpired()  {

    bool result = false;
    final DateTime parsedExpiryTime = DateTime.parse(sharedPreferences.getString(Strings.tokenExpiryTime));
    if (parsedExpiryTime.isBefore(DateTime.now())) {
      //renew the session
      result = true;
    }
    return result;
  }

  static String getFirebaseAppId () {
    String firebaseAppId;
    if(releaseMode && Platform.isIOS) firebaseAppId = firebaseAppIdIosLive;
    if(!releaseMode && Platform.isIOS) firebaseAppId = firebaseAppIdIosDev;
    if(releaseMode && Platform.isAndroid) firebaseAppId = firebaseAppIdAndroidLive;
    if(!releaseMode && Platform.isAndroid) firebaseAppId = firebaseAppIdAndroidDev;
    return firebaseAppId;
  }


  static String encryptString(String value) {
    String encryptedValueIv;

    if (value == null || value == '' || value.isEmpty) {
      encryptedValueIv = '';
    } else {
      final Encrypt.IV initializationVector = Encrypt.IV.fromUtf8(randomAlpha(8));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      Encrypt.Encrypted encryptedValue = encrypter.encrypt(value, iv: initializationVector);
      String encryptedStringValue = encryptedValue.base16;
      encryptedValueIv = encryptedStringValue + initializationVector.base16;
    }

    return encryptedValueIv;
  }

  static String decryptString(String value) {
    String decryptedValue;

    if (value == null || value == '' || value.isEmpty) {
      decryptedValue = '';
    } else {
      int valueLength = value.length;
      int valueRequired = valueLength - 16;
      int startOfIv = valueLength - 16;
      String valueToDecrypt = value.substring(0, valueRequired);
      final Encrypt.IV initializationVector = Encrypt.IV.fromBase16(value.substring(startOfIv));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      decryptedValue = encrypter.decrypt(Encrypt.Encrypted.fromBase16(valueToDecrypt), iv: initializationVector);
    }

    return decryptedValue;
  }
  
  static void showLoadingDialog(String message){

    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        wrapToastAnimation: (controller, cancel, child) => Stack(
          children: <Widget>[
            AnimatedBuilder(
              builder: (_, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
                child: SizedBox.expand(),
              ),
              animation: controller,
            ),
            CustomOffsetAnimation(
              controller: controller,
              child: child,
            )
          ],
        ),
        toastBuilder: (cancelFunc) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    darkBlue),
              ),
              SizedBox(
                height: 20.0,
              ),
              new Text(
                message,
                style: TextStyle(fontSize: 20.0), textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        animationDuration: Duration(milliseconds: 300));
    
  }

  static void dismissLoadingDialog(){

    BotToast.cleanAll();

  }


  static bool tinyIntToBool(var databaseValue) {
    bool value = false;

    if (databaseValue != null &&
        databaseValue != 'null') {
      if (databaseValue == 1) {
        value = true;
      }
    }

    return value;
  }

  static int boolToTinyInt(var boolValue) {
    int value = 0;

    if (boolValue != null) {
      if (boolValue == true) {
        value = 1;
      }
    }

    return value;
  }

  static String databaseValueString(var databaseValue) {
    String value = databaseValue == null ||
        databaseValue == 'null'
        ? '' : databaseValue;
    return value;
  }

  static bool databaseValueBool(var databaseValue) {
    bool value = databaseValue == null ||
        databaseValue == false
        ? false : true;
    return value;
  }

  static Future<List<int>> getImageBytes(File image) async {
    List<int> imageBytes = await FlutterImageCompress.compressWithFile(
        image.absolute.path, quality: 90, keepExif: true);
    return imageBytes;
  }

  static String getBase64Image(List<int> imageBytes) {
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  static checkFirebaseStorageFail(DatabaseHelper databaseHelper) async {
    final int existingFirebaseStorageRow = await databaseHelper
        .checkFirebaseStorageRowExists(user.uid);

    if (existingFirebaseStorageRow != 0) {
      List<Map<String, dynamic>> storageRows = [];

      storageRows = await databaseHelper.getRowsWhere(
          DatabaseHelper.firebaseStorageUrlTable, DatabaseHelper.uid, user.uid);

      if (storageRows.length > 0) {
        Map<String, dynamic> row = storageRows[0];

        List<dynamic> urlList = await jsonDecode(row['url_list']);

        for (String url in urlList) {
          await FirebaseStorage.instance.ref().child(url).delete();
        }

        databaseHelper.deleteFirebaseRow(
            DatabaseHelper.firebaseStorageUrlTable, user.uid);
      }
    }
  }

  static checkAddFirebaseStorageRow(List<String> storageUrlList,
      DatabaseHelper databaseHelper) async {
    if (storageUrlList != null && storageUrlList.length > 0) {
      String storageUrlJson = await compute(jsonEncode, storageUrlList);

      await databaseHelper.add(
        DatabaseHelper.firebaseStorageUrlTable,
        {'uid': user.uid, 'url_list': storageUrlJson},
      );
    }
  }

  static RichText boldTitleText(String title, String field, BuildContext context){

    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.caption.color,),
        children: [
          TextSpan(
              text: field,
              style: TextStyle(fontFamily: 'Open Sans',
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.caption.color,)
          ),
        ],
      ),
    );

  }

  static Future<void> deleteTemporaryImages() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    //Delete the temporary images and replace images with compressed ones
    int imagePathCount = await databaseHelper.getImagePathCount();

    if (imagePathCount == 1) {
      String imagePath = await databaseHelper.getImagePath();


      if (imagePath != null) {
        Directory dir = Directory(imagePath);
        print('this is the dir');
        print(dir);

        if (dir.existsSync()) {
          print('it exsits tjis directory');
          List<FileSystemEntity> list = dir.listSync(recursive: false)
              .toList();
          print('thisis the list of the files');
          print(list);

          for (FileSystemEntity file in list) {
            if (file.path.contains('.jpg') || file.path.contains('.png')) file
                .deleteSync(
                recursive: false);
          }
        } else {
          print('this does not exist');
        }
      }
    }
  }

  static Future<void> deleteActivityLogImages() async {
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/images${user.uid}/activityLogs';
    Directory dir = Directory(dirPath);

    if (dir.existsSync()) {
      print('it clearly exists');
      dir.deleteSync(recursive: true);
    } else {
      print('doe not exist');
    }
  }





}


class CustomOffsetAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const CustomOffsetAnimation({Key key, this.controller, this.child})
      : super(key: key);

  @override
  _CustomOffsetAnimationState createState() => _CustomOffsetAnimationState();
}

class _CustomOffsetAnimationState extends State<CustomOffsetAnimation> {
  Tween<Offset> tweenOffset;
  Tween<double> tweenScale;

  Animation<double> animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation =
        CurvedAnimation(parent: widget.controller, curve: Curves.decelerate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      child: widget.child,
      animation: widget.controller,
      builder: (BuildContext context, Widget child) {
        return FractionalTranslation(
            translation: tweenOffset.evaluate(animation),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale.evaluate(animation),
                child: Opacity(
                  child: child,
                  opacity: animation.value,
                ),
              ),
            ));
      },
    );
  }
}