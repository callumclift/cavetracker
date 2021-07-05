import 'package:caving_app/models/club_model.dart';
import 'package:caving_app/services/secure_storage.dart';
import 'package:caving_app/shared/strings.dart';
import 'package:caving_app/widgets/dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../models/authentication_model.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import '../../utils/database_helper.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage>{

  final SecureStorage _secureStorage = SecureStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey3 = GlobalKey<FormState>();
  bool okPressed = false;

  final TextEditingController _currentPasswordFieldController =
  TextEditingController();
  final TextEditingController _newPasswordFieldController =
  TextEditingController();
  final TextEditingController _confirmPasswordFieldController =
  TextEditingController();

  final FocusNode _currentPasswordFocusNode = new FocusNode();
  final FocusNode _newPasswordFocusNode = new FocusNode();
  final FocusNode _confirmPasswordFocusNode = new FocusNode();

  Color _currentPasswordLabelColor = Colors.grey;
  Color _newPasswordLabelColor = Colors.grey;
  Color _confirmPasswordLabelColor = Colors.grey;

  String _currentPasswordValidationMessage;
  String club = 'Select One';
  List<String> clubDrop = ['Select One'];

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    _setupFocusNodes();
  }

  @override
  void dispose() {
    _currentPasswordFieldController.dispose();
    _newPasswordFieldController.dispose();
    _confirmPasswordFieldController.dispose();
    _currentPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  _setupFocusNodes(){

    _currentPasswordFocusNode.addListener((){
      if(mounted) {
        if (_currentPasswordFocusNode.hasFocus) {
          setState(() {
            _currentPasswordLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _currentPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
    _newPasswordFocusNode.addListener((){
      if(mounted) {
        if (_newPasswordFocusNode.hasFocus) {
          setState(() {
            _newPasswordLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _newPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
    _confirmPasswordFocusNode.addListener((){
      if(mounted) {
        if (_confirmPasswordFocusNode.hasFocus) {
          setState(() {
            _confirmPasswordLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _confirmPasswordLabelColor = Colors.grey;
          });
        }
      }
    });
  }



  Widget _buildCurrentPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        return _currentPasswordValidationMessage;
      },
      obscureText: true,
      autocorrect: false,
      focusNode: _currentPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _currentPasswordLabelColor),
          labelText: 'Password',
          suffixIcon: _currentPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _currentPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _currentPasswordFieldController,
    );
  }

  Widget _buildNewPasswordTextField() {
    return TextFormField(
        validator: (String value) {
          String message;
          if (value.trim().length <= 0 && value.isEmpty) {
            message = 'Please enter a new password';
          }
          if (value.length < 8) {
            message = 'Password must be at least 8 characters long';
          }
          if(value != _confirmPasswordFieldController.text){
            message = 'New password and confirm new password fields should match';
          }
          return message;
        },
      obscureText: true,
      autocorrect: false,
      focusNode: _newPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _newPasswordLabelColor),
          labelText: 'New Password',
          suffixIcon: _newPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _newPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _newPasswordFieldController,
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a new password';
        }
        if (value.length < 8) {
          message = 'Password must be at least 8 characters long';
        }
        if(value != _newPasswordFieldController.text){
          message = 'New password and confirm new password fields should match';
        }
        return message;
      },
      obscureText: true,
      autocorrect: false,
      focusNode: _confirmPasswordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _confirmPasswordLabelColor),
          labelText: 'Confirm Password',
          suffixIcon: _confirmPasswordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _confirmPasswordFieldController.clear();
                  });
                });
              })
      ),
      controller: _confirmPasswordFieldController,
    );
  }

  Widget _buildSubmitButton() {
    return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: RaisedButton(
          shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
            color: darkBlue,
            textColor: whiteGreen,
            child: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold),),
            onPressed: () async => _changePassword(),
          ),
        ));

  }

  Widget _buildClearDataButton() {
    return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color: darkBlue,
            textColor: whiteGreen,
            child: Text('Clear App Data', style: TextStyle(fontWeight: FontWeight.bold),),
            onPressed: () => _clearAppData(),
          ),
        ));
  }


  void _clearAppData(){

    DatabaseHelper _databaseHelper = DatabaseHelper();

    showDialog(
        context: context,
        builder: (BuildContext context) {
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
              child: Center(child: Text("Clear App Data", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
            ),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text('Are you sure you wish to clear local app data?', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0,),
            ],),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                ),
              ),
              FlatButton(
                onPressed: () {

                  setState(() {
                    okPressed = true;
                  });

                  Navigator.pop(context);

                },
                child: Text(
                  'OK',
                  style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).then((_) async{

      if(okPressed){

        GlobalFunctions.showLoadingDialog('Deleting Data...');
        await _databaseHelper.deleteAllRows(Strings.activityLogTable);
        await _databaseHelper.deleteAllRows(Strings.caveTable);
        await GlobalFunctions.deleteTemporaryImages();
        imageCache.clear();
        GlobalFunctions.dismissLoadingDialog();

        setState(() {
          okPressed = false;
        });
      }});
  }

  _changePassword() async {

    String _currentPassword = await _secureStorage.readSecureData('password');

    if(_currentPasswordFieldController.text.trim().length <= 0 && _currentPasswordFieldController.text.isEmpty) {

        _currentPasswordValidationMessage = 'Please enter your current password';

    } else if(_currentPasswordFieldController.text != _currentPassword) {
      _currentPasswordValidationMessage = 'Current password is incorrect';
      _currentPassword = '';
    } else {
      _currentPasswordValidationMessage = null;
    }



    if (!_formKey.currentState.validate()) {
      return;
    }

    bool success = await context.read<AuthenticationModel>().changePassword(_newPasswordFieldController.text);
    print(success);
    if(success) {
      setState(() {
        _currentPasswordFieldController.clear();
        _newPasswordFieldController.clear();
        _confirmPasswordFieldController.clear();
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }


  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
          margin: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2), child: Column(children: <Widget>[
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),

                ],),
                SizedBox(height: 10.0,),
                Container(decoration: BoxDecoration(border: Border.all(width: 2.0)), width: MediaQuery.of(context).size.width, child: Container(padding: EdgeInsets.all(5.0),color: Colors.grey, child: Row(children: <Widget>[
                  Icon(Icons.info),
                  SizedBox(width: 5.0,),
                  Flexible(child: Text('To change your password, enter your existing password along with your new password details below. Your new password must be at least 8 characters in length.'))

                ],),)),
                _buildCurrentPasswordTextField(),
                _buildNewPasswordTextField(),
                _buildConfirmPasswordTextField(),
                SizedBox(height: 10.0,),
                _buildSubmitButton(),
                SizedBox(height: 10.0,),
                Divider(),
              ],),
            ),
            Form(
              key: _formKey3,
              child: Column(children: <Widget>[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Text('Clear App Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),

                ],),
                SizedBox(height: 10.0,),
                Container(decoration: BoxDecoration(border: Border.all(width: 2.0)), width: MediaQuery.of(context).size.width, child: Container(padding: EdgeInsets.all(5.0),color: Colors.grey, child: Row(children: <Widget>[
                  Icon(Icons.info),
                  SizedBox(width: 5.0,),
                  Flexible(child: Text('If you want to reduce the amount of space the app is using you can clear all of the local data on this device, all previous succesfully submitted'
                      ' forms will be available to download from the server.'))

                ],),)),
                SizedBox(height: 10.0,),
                _buildClearDataButton(),
                SizedBox(height: 10.0,),
              ],),
            ),
          ],
          ))
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(appBar: AppBar(backgroundColor: mintGreen, title: FittedBox(fit:BoxFit.fitWidth,
        child: Text('Settings', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)), iconTheme: IconThemeData(color: darkBlue),),drawer: SideDrawer(), body: _buildPageContent(context),);
  }
}