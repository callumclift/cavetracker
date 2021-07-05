import 'package:caving_app/models/authentication_model.dart';
import 'package:caving_app/models/club_model.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';

class CreateClub extends StatefulWidget {
  @override
  _CreateClubState createState() => _CreateClubState();
}

class _CreateClubState extends State<CreateClub> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _descriptionFieldController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  Color _nameLabelColor = Colors.grey;
  Color _descriptionLabelColor = Colors.grey;

  @override
  void initState() {
    _nameFocusNode.addListener(() {
      if (mounted) {
        if (_nameFocusNode.hasFocus) {
          setState(() {
            _nameLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _nameLabelColor = Colors.grey;
          });
        }
      }
    });
    _descriptionFocusNode.addListener(() {
      if (mounted) {
        if (_descriptionFocusNode.hasFocus) {
          setState(() {
            _descriptionLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _descriptionLabelColor = Colors.grey;
          });
        }
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _nameFieldController.dispose();
    _descriptionFieldController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
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
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        ),
        child: Center(child: Text("Create Club", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
      ),
      content: Form(
          key: _formKey,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Please enter your club details.'),
              TextFormField(
                validator: (String value) {
                  String message;
                  if (value == '' || value.isEmpty || value.trim().length < 1) {
                    message =  'Please enter a club name';
                  }
                  return message;
                },
                focusNode: _nameFocusNode,
                decoration: InputDecoration(
                    labelStyle: TextStyle(color: _nameLabelColor),
                    labelText: 'Name',
                    suffixIcon: _nameFieldController.text == ''
                        ? null
                        : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              FocusScope.of(context).unfocus();
                              _nameFieldController.clear();
                            });
                          });
                        })
                ),
                controller: _nameFieldController,
              ),
              TextFormField(
                validator: (String value) {
                  String message;
                  if (value == '' || value.isEmpty || value.trim().length < 1) {
                    message =  'Please enter a description';
                  }
                  return message;
                },
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                    labelStyle: TextStyle(color: _descriptionLabelColor),
                    labelText: 'Description',
                    suffixIcon: _descriptionFieldController.text == ''
                        ? null
                        : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              FocusScope.of(context).unfocus();
                              _descriptionFieldController.clear();
                            });
                          });
                        })
                ),
                controller: _descriptionFieldController,
              )
            ],
          ),)),
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

            print('validation status');
            print(_formKey.currentState.validate());
            print(_nameFieldController.text);

            if(_formKey.currentState.validate()){

              ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

              if (connectivityResult == ConnectivityResult.none) {

              } else {

                await context.read<ClubModel>().submitClub(_nameFieldController.text, _descriptionFieldController.text);

              }

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

