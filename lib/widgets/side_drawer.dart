import 'package:caving_app/models/activity_log_model.dart';
import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/shared/global_functions.dart';
import 'package:caving_app/shared/strings.dart';
import 'package:caving_app/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/authentication_model.dart';
import '../shared/global_config.dart';
import '../services/navigation_service.dart';
import '../constants/route_paths.dart' as routes;
import '../locator.dart';



class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {

  final NavigationService _navigationService = locator<NavigationService>();
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _pendingItems = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPendingItems();
  }


  _checkPendingItems() async{
    _databaseHelper.checkExistsTwoArguments(Strings.activityLogTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
      if (value == 1) {
        setState(() {
          _pendingItems = true;
        });
      }
    });
    _databaseHelper.checkExistsTwoArguments(Strings.caveTable, Strings.serverUploaded, 0, Strings.uid, user.uid).then((int value) {
      if (value == 1) {
        setState(() {
          _pendingItems = true;
        });
      }
    });
  }

  _uploadPendingItems() async{

    bool hasConnection = await GlobalFunctions.hasDataConnection();
    bool successfulActivityLogUploads = true;
    bool successfulCaveUploads = true;
    String message;


    if(hasConnection){

      GlobalFunctions.showLoadingDialog('Uploading data...');
      int pendingActivityLog = await _databaseHelper.checkExistsTwoArguments(Strings.activityLogTable, Strings.serverUploaded, 0, Strings.uid, user.uid);
      int pendingCave = await _databaseHelper.checkExistsTwoArguments(Strings.caveTable, Strings.serverUploaded, 0, Strings.uid, user.uid);


      if (pendingActivityLog == 1) {
        print('pending maintenance');
        Map<String, dynamic> uploadActivityLogs = await context.read<ActivityLogModel>().uploadPendingActivityLogs();
        successfulActivityLogUploads = uploadActivityLogs['success'];
        message = uploadActivityLogs['message'];
      }
      if (pendingCave == 1) {
        print('pending cave');
        Map<String, dynamic> uploadCaves = await context.read<CaveModel>().uploadPendingCaves();
        successfulCaveUploads = uploadCaves['success'];
        message = uploadCaves['message'];
      }

      GlobalFunctions.dismissLoadingDialog();
      GlobalFunctions.showToast(message);



      if(successfulActivityLogUploads && successfulCaveUploads){
        setState(() {
          _pendingItems = false;
        });
      }



    } else {
      GlobalFunctions.showToast('No data connection, please try again when you have a valid connection');
    }




  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: mintGreen,
            title: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {

                return Image.asset(
                    'assets/images/logotext.png', width: constraints.maxWidth * 0.9,);
              },
            ),
            actions: [],
          ),
          Expanded(child: Container(
            color: whiteGreen,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              children: [
                ListTile(
                  leading: Image.asset('assets/icons/clubhubIcon.png', height: 25,),
                  title: Text('Clubhub', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                  onTap: () => _navigationService.navigateToReplacement(routes.ClubhubPageRoute),
                ),
                Divider(),
                ExpansionTile(
                    leading: Image.asset('assets/icons/caveIcon.png', height: 25,),
                    title: Text('Caves', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),children: <Widget>[
                  ListTile(
                    leading: Image.asset('assets/icons/createIcon.png', height: 25,),
                      title: Text('Add Cave', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _navigationService.navigateToReplacement(routes.CreateCavePageRoute),
                  ),
                  ListTile(
                    leading: Image.asset('assets/icons/listIcon.png', height: 25,),
                      title: Text('Caves List', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _navigationService.navigateToReplacement(routes.CaveListRoute),
                  )
                ]),ExpansionTile(
                    leading: Image.asset('assets/icons/activityLogIcon.png', height: 25,),
                    title: Text('Activity Logs', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),children: <Widget>[
                  ListTile(
                    leading: Image.asset('assets/icons/createIcon.png', height: 25,),
                      title: Text('Create Activity Log', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _navigationService.navigateToReplacement(routes.ActivityLogPageRoute),
                  ),
                  ListTile(
                    leading: Image.asset('assets/icons/listIcon.png', height: 25,),
                      title: Text('My Activity Logs', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _navigationService.navigateToReplacement(routes.ActivityLogListPageRoute),
                  ),
                  user != null && user.clubId != '' ? ListTile(
                    leading: Image.asset('assets/icons/listIcon.png', height: 25,),
                    title: Text('Club Activity Logs', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                    onTap: () => _navigationService.navigateToReplacement(routes.ClubActivityLogListPageRoute),
                  ) : Container(),
                ]),
                Divider(),
                ListTile(
                  leading: Image.asset('assets/icons/callOutIcon.png', height: 25,),
                    title: Text('Create Call Out', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                  onTap: () => _navigationService.navigateToReplacement(routes.CallOutPageRoute),
                ),
                Divider(),
                _pendingItems ? Column(
                  children: [
                    ListTile(
                      leading: Image.asset('assets/icons/uploadIcon.png', height: 25,),
                      title: Text('Upload Pending Items', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                      onTap: () => _uploadPendingItems(),
                    ),
                    Divider()
                  ],
                ) : Container(),
                ListTile(
                  leading: Image.asset('assets/icons/settingsIcon.png', height: 25,),
                    title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                    onTap: () => _navigationService.navigateToReplacement(routes.SettingsPageRoute),
                ),
                Divider(),
                ListTile(
                    leading: Image.asset('assets/icons/logoutIcon.png', height: 25,),
                    title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),),
                    onTap: () => context.read<AuthenticationModel>().logout()
                ),
              ],
            ),
          ))

        ],
      ),

    );
  }
}
