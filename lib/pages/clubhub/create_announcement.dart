import 'package:caving_app/models/club_model.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';

class CreateAnnouncement extends StatefulWidget {
  @override
  _CreateAnnouncementState createState() => _CreateAnnouncementState();
}

class _CreateAnnouncementState extends State<CreateAnnouncement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _bodyFieldController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();

  Color _bodyLabelColor = Colors.grey;

  @override
  void initState() {
    _bodyFocusNode.addListener(() {
      if (mounted) {
        if (_bodyFocusNode.hasFocus) {
          setState(() {
            _bodyLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _bodyLabelColor = Colors.grey;
          });
        }
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _bodyFieldController.dispose();
    _bodyFocusNode.dispose();
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
            "Create Announcement",
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  maxLines: 4,
                  validator: (String value) {
                    String message;
                    if (value == '' ||
                        value.isEmpty ||
                        value.trim().length < 1) {
                      message = 'Announcement must not be empty';
                    }
                    return message;
                  },
                  focusNode: _bodyFocusNode,
                  decoration: InputDecoration(
                      labelStyle: TextStyle(color: _bodyLabelColor),
                      labelText: 'Announcement',
                      suffixIcon: _bodyFieldController.text == ''
                          ? null
                          : IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) {
                                    FocusScope.of(context).unfocus();
                                    _bodyFieldController.clear();
                                  });
                                });
                              })),
                  controller: _bodyFieldController,
                ),
              ],
            ),
          )),
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

            if (_formKey.currentState.validate()) {
              ConnectivityResult connectivityResult =
                  await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {
                GlobalFunctions.showToast('No data connection, unable to submit announcement');
              } else {
                await context
                    .read<ClubModel>()
                    .submitAnnouncement(_bodyFieldController.text);
              }
            }
          },
          child: Text(
            'Post',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
