import 'package:caving_app/models/authentication_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../models/customers_model.dart';
import '../../widgets/standard_text_form_field.dart';
import '../../widgets/dropdown_form_field.dart';

class SignUpPage extends StatefulWidget {

  SignUpPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController _usernameFieldController = TextEditingController();
  final TextEditingController _emailFieldController = TextEditingController();
  final TextEditingController _passwordFieldController = TextEditingController();
  final TextEditingController _confirmPasswordFieldController = TextEditingController();

  final FocusNode _usernameFocusNode = new FocusNode();
  final FocusNode _emailFocusNode = new FocusNode();
  final FocusNode _passwordFocusNode = new FocusNode();
  final FocusNode _confirmPasswordFocusNode = new FocusNode();

  Color _usernameLabelColor = Colors.grey;
  Color _emailLabelColor = Colors.grey;
  Color _passwordLabelColor = Colors.grey;
  Color _confirmPasswordLabelColor = Colors.grey;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState(){
    _setupFocusNodes();
    super.initState();
  }

  @override
  void dispose() {
    _usernameFieldController.dispose();
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _confirmPasswordFieldController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }




  _setupFocusNodes(){
    _usernameFocusNode.addListener((){
      if(mounted) {
        if (_usernameFocusNode.hasFocus) {
          setState(() {
            _usernameLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _usernameLabelColor = Colors.grey;
          });
        }
      }
    });
    _emailFocusNode.addListener((){
      if(mounted) {
        if (_emailFocusNode.hasFocus) {
          setState(() {
            _emailLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _emailLabelColor = Colors.grey;
          });
        }
      }
    });
    _passwordFocusNode.addListener((){
      if(mounted) {
        if (_passwordFocusNode.hasFocus) {
          setState(() {
            _passwordLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _passwordLabelColor = Colors.grey;
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



  Widget _buildEmailTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value == '' || value.isEmpty || value.trim().length > 0 &&
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          message =  'Please enter a valid email';
        }
        return message;
      },
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _emailLabelColor),
          labelText: 'Email',
          suffixIcon: _emailFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _emailFieldController.clear();
                  });
                });
              })
      ),
      controller: _emailFieldController,
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value == '' || value.isEmpty || value.trim().length < 8) {
          message =  'Password must be at least 8 characters';
        }
        return message;
      },
      obscureText: true,
      autocorrect: false,
      focusNode: _passwordFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _passwordLabelColor),
          labelText: 'Password',
          suffixIcon: _passwordFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _passwordFieldController.clear();
                  });
                });
              })
      ),
      controller: _passwordFieldController,
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value != _passwordFieldController.text) {
          message =  'Passwords must match';
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

  Widget _buildUsernameTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value == '' || value.isEmpty || value.trim().length < 1) {
          message =  'Name must not be empty';
        }
        return message;
      },
      focusNode: _usernameFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _usernameLabelColor),
          labelText: 'Name',
          suffixIcon: _usernameFieldController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _usernameFieldController.clear();
                  });
                });
              })
      ),
      controller: _usernameFieldController,
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
            child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold),),
            onPressed: () => _signUp(),
          ),
        ));
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
        color: whiteGreen,
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(children: <Widget>[
              _buildEmailTextField(),
              _buildUsernameTextField(),
              _buildPasswordTextField(),
              _buildConfirmPasswordTextField(),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],),
          ),
        ),
      ),
    );
  }

  void _signUp() {

    if (_formKey.currentState.validate()) {

      context.read<AuthenticationModel>().signUp(_emailFieldController.text, _passwordFieldController.text, _usernameFieldController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: whiteGreen,
      appBar: AppBar(iconTheme: IconThemeData(color: darkBlue), backgroundColor: mintGreen,
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Sign Up', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
      ),
      body: _buildPageContent(context),
    );
  }
}
