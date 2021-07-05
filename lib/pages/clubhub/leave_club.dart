import 'package:caving_app/models/club_model.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';

class LeaveClub extends StatefulWidget {
  @override
  _LeaveClubState createState() => _LeaveClubState();
}

class _LeaveClubState extends State<LeaveClub> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      titlePadding: EdgeInsets.all(0),
      title: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: mintGreen,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Center(
          child: Text(
            "Leave Club",
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you wish to leave this club?')
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
        FlatButton(
          onPressed: () async {

              ConnectivityResult connectivityResult =
              await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast('No data connection, unable to leave club');
              } else {
                await context
                    .read<ClubModel>()
                    .leaveClub();
              }

          },
          child: Text(
            'OK',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
