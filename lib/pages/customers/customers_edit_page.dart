//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/scheduler.dart';
//import 'package:flutter/services.dart';
//import '../../shared/global_config.dart';
//import '../../shared/global_functions.dart';
//import 'dart:io';
//import 'package:provider/provider.dart';
//import '../../models/customers_model.dart';
//import '../../widgets/standard_text_form_field.dart';
//import '../../widgets/dropdown_form_field.dart';
//
//class CustomersEditPage extends StatefulWidget {
//
//  CustomersEditPage();
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//
//    return _CustomersEditPageState();
//  }
//}
//
//class _CustomersEditPageState extends State<CustomersEditPage> {
//
//  bool loading = false;
//  bool firstNameValidationFail = false;
//  bool lastNameValidationFail = false;
//  bool addressValidationFail = false;
//  bool emailValidationFail = false;
//
//
//  final TextEditingController _firstNameTextController = TextEditingController();
//  final TextEditingController _lastNameTextController = TextEditingController();
//  final TextEditingController _addressTextController = TextEditingController();
//  final TextEditingController _postcodeTextController = TextEditingController();
//  final TextEditingController _telephoneTextController = TextEditingController();
//  final TextEditingController _mobileTextController = TextEditingController();
//  final TextEditingController _emailFieldController = TextEditingController();
//
//  final FocusNode _firstNameFocusNode = new FocusNode();
//  final FocusNode _lastNameFocusNode = new FocusNode();
//  final FocusNode _addressFocusNode = new FocusNode();
//  final FocusNode _postcodeFocusNode = new FocusNode();
//  final FocusNode _telephoneFocusNode = new FocusNode();
//  final FocusNode _mobileFocusNode = new FocusNode();
//  final FocusNode _emailFocusNode = new FocusNode();
//
//  Color _firstNameLabelColor = Colors.grey;
//  Color _lastNameLabelColor = Colors.grey;
//  Color _addressLabelColor = Colors.grey;
//  Color _postcodeLabelColor = Colors.grey;
//  Color _telephoneLabelColor = Colors.grey;
//  Color _mobileLabelColor = Colors.grey;
//  Color _emailLabelColor = Colors.grey;
//
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//  List<String> _prefixes = <String>['N/A', 'Mr', 'Mrs', 'Miss', 'Ms', 'Mx'];
//  String _prefixValue = 'N/A';
//
//  @override
//  initState(){
//    _setupTextControllerValues();
//    _setupFocusNodes();
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    _firstNameTextController.dispose();
//    _lastNameTextController.dispose();
//    _addressTextController.dispose();
//    _postcodeTextController.dispose();
//    _telephoneTextController.dispose();
//    _mobileTextController.dispose();
//    _emailFieldController.dispose();
//    _firstNameFocusNode.dispose();
//    _lastNameFocusNode.dispose();
//    _addressFocusNode.dispose();
//    _postcodeFocusNode.dispose();
//    _telephoneFocusNode.dispose();
//    _mobileFocusNode.dispose();
//    _emailFocusNode.dispose();
//    super.dispose();
//  }
//
//  _setupTextControllerValues(){
//
//    if(context.read<CustomersModel>().selectedCustomer == null){
//
//      _prefixValue = 'N/A';
//      _firstNameTextController.text = '';
//      _lastNameTextController.text = '';
//      _addressTextController.text = '';
//      _postcodeTextController.text = '';
//      _telephoneTextController.text = '';
//      _mobileTextController.text = '';
//      _emailFieldController.text = '';
//
//    } else {
//
//      if(context.read<CustomersModel>().selectedCustomer.prefix == null || context.read<CustomersModel>().selectedCustomer.prefix == 'N/A' || context.read<CustomersModel>().selectedCustomer.prefix == ''){
//        _prefixValue = 'N/A';
//
//      } else {
//        _prefixValue = context.read<CustomersModel>().selectedCustomer.prefix;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.firstName == null || context.read<CustomersModel>().selectedCustomer.firstName == ''){
//        _firstNameTextController.text = '';
//
//      } else {
//        _firstNameTextController.text = context.read<CustomersModel>().selectedCustomer.firstName;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.lastName == null || context.read<CustomersModel>().selectedCustomer.lastName == ''){
//        _lastNameTextController.text = '';
//
//      } else {
//        _lastNameTextController.text = context.read<CustomersModel>().selectedCustomer.lastName;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.address == null || context.read<CustomersModel>().selectedCustomer.address == ''){
//        _addressTextController.text = '';
//
//      } else {
//        _addressTextController.text = context.read<CustomersModel>().selectedCustomer.address;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.postCode == null || context.read<CustomersModel>().selectedCustomer.postCode == ''){
//        _postcodeTextController.text = '';
//
//      } else {
//        _postcodeTextController.text = context.read<CustomersModel>().selectedCustomer.postCode;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.telephone == null || context.read<CustomersModel>().selectedCustomer.telephone == ''){
//        _telephoneTextController.text = '';
//
//      } else {
//        _telephoneTextController.text = context.read<CustomersModel>().selectedCustomer.telephone;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.mobile == null || context.read<CustomersModel>().selectedCustomer.mobile == ''){
//        _mobileTextController.text = '';
//
//      } else {
//        _mobileTextController.text = context.read<CustomersModel>().selectedCustomer.mobile;
//      }
//      if(context.read<CustomersModel>().selectedCustomer.email == null || context.read<CustomersModel>().selectedCustomer.email == ''){
//        _emailFieldController.text = '';
//
//      } else {
//        _emailFieldController.text = context.read<CustomersModel>().selectedCustomer.email;
//      }
//
//    }
//
//  }
//
//
//  _setupFocusNodes(){
//
//    _firstNameFocusNode.addListener((){
//      if(mounted) {
//        if (_firstNameFocusNode.hasFocus) {
//          setState(() {
//            _firstNameLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _firstNameLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _lastNameFocusNode.addListener((){
//      if(mounted) {
//        if (_lastNameFocusNode.hasFocus) {
//          setState(() {
//            _lastNameLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _lastNameLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _addressFocusNode.addListener((){
//      if(mounted) {
//        if (_addressFocusNode.hasFocus) {
//          setState(() {
//            _addressLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _addressLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _postcodeFocusNode.addListener((){
//      if(mounted) {
//        if (_postcodeFocusNode.hasFocus) {
//          setState(() {
//            _postcodeLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _postcodeLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _telephoneFocusNode.addListener((){
//      if(mounted) {
//        if (_telephoneFocusNode.hasFocus) {
//          setState(() {
//            _telephoneLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _telephoneLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _mobileFocusNode.addListener((){
//      if(mounted) {
//        if (_mobileFocusNode.hasFocus) {
//          setState(() {
//            _mobileLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _mobileLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//    _emailFocusNode.addListener((){
//      if(mounted) {
//        if (_emailFocusNode.hasFocus) {
//          setState(() {
//            _emailLabelColor = darkBlue;
//          });
//        } else {
//          setState(() {
//            _emailLabelColor = Colors.grey;
//          });
//        }
//      }
//    });
//  }
//
//  Color _emailColor(){
//
//    Color returnedValue = Colors.grey;
//
//    if(_emailFocusNode.hasFocus && emailValidationFail == false) returnedValue = darkBlue;
//    if(emailValidationFail) returnedValue = Colors.red;
//
//    return returnedValue;
//  }
//
//
//  Widget _buildEmailTextField() {
//    return TextFormField(
//      validator: (String value) {
//        String message;
//        if (value == '' || value.isEmpty || value.trim().length > 0 ||
//            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
//                .hasMatch(value)) {
//          message =  'Please enter a valid email';
//        }
//        return message;
//      },
//      keyboardType: TextInputType.emailAddress,
//      focusNode: _emailFocusNode,
//      decoration: InputDecoration(
//          labelStyle: TextStyle(color: _emailLabelColor),
//          labelText: 'Email',
//          suffixIcon: _emailFieldController.text == ''
//              ? null
//              : IconButton(
//              icon: Icon(Icons.clear),
//              onPressed: () {
//                setState(() {
//                  SchedulerBinding.instance.addPostFrameCallback((_) {
//                    FocusScope.of(context).unfocus();
//                    _emailFieldController.clear();
//                  });
//                });
//              })
//      ),
//      controller: _emailFieldController,
//    );
//  }
//
//
//  Widget _buildPrefixDrop() {
//    return DropdownFormField(
//      expanded: true,
//      hint: 'Title',
//      value: _prefixValue,
//      items: _prefixes.toList(),
//      onChanged: (val) => setState(() {
//        FocusScope.of(context).unfocus();
//        _prefixValue = val;
//      }),
//      initialValue: _prefixes[0],
//      onSaved: (val) => setState(() {
//        _prefixValue = val;
//      }),
//    );
//  }
//
//  Widget _buildSubmitButton() {
//    return Consumer<CustomersModel>(
//        builder: (context, model, child) {
//          return Center(
//              child: SizedBox(
//                width: MediaQuery.of(context).size.width * 0.5,
//                child: RaisedButton(
//                  shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(18.0),
//                  ),
//                  color: darkBlue,
//                  textColor: whiteGreen,
//                  child: model.selectedCustomer == null ? Text('Save') : Text('Edit'),
//                  onPressed: () => _saveCustomer(),
//                ),
//              ));
//        });
//  }
//
//
//  Widget _buildPageContent(BuildContext context) {
//    final double deviceWidth = MediaQuery.of(context).size.width;
//    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
//    final double targetPadding = deviceWidth - targetWidth;
//
//
//    return GestureDetector(
//      onTap: () {
//        FocusScope.of(context).requestFocus(FocusNode());
//      },
//      child: Container(
//        color: whiteGreen,
//        padding: EdgeInsets.all(10.0),
//        child: Form(
//          key: _formKey,
//          child: SingleChildScrollView(
//            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
//            child: Column(children: <Widget>[
//              _buildPrefixDrop(),
//              Row(
//                children: <Widget>[
//                  Expanded(
//                    child: TextFormField(
//                      validator: (String value) {
//                        String returnedValue;
//                        if (value.trim().length <= 0 && value.isEmpty && _lastNameTextController.text.isEmpty) {
//                          returnedValue = 'Please enter either a First Name or Last Name';
//                        }
//                        return returnedValue;
//                      },
//                      focusNode: _firstNameFocusNode,
//                      decoration: InputDecoration(
//                        labelStyle: TextStyle(color: _firstNameLabelColor),
//                        labelText: 'First Name',
//                      ),
//                      controller: _firstNameTextController,
//                    ),
//                  ),
//                  _firstNameTextController.text.isEmpty
//                      ? Container()
//                      : InkWell(onTap: () {
//                    setState(() {
//                      _firstNameTextController.clear();
//                    });
//                  }, child: Icon(Icons.clear,
//                    color: _firstNameFocusNode.hasFocus
//                        ? darkBlue
//                        : Colors.grey,
//                  ),)
//                ],
//              ),
//              Row(
//                children: <Widget>[
//                  Expanded(
//                    child: TextFormField(
//                      validator: (String value) {
//                        String returnedValue;
//                        if (value.trim().length <= 0 && value.isEmpty && _firstNameTextController.text.isEmpty) {
//                          returnedValue = 'Please enter either a First Name or Last Name';
//                        }
//                        return returnedValue;
//                      },
//                      focusNode: _lastNameFocusNode,
//                      decoration: InputDecoration(
//                        labelStyle: TextStyle(color: _lastNameLabelColor),
//                        labelText: 'Last Name',
//                      ),
//                      controller: _lastNameTextController,
//                    ),
//                  ),
//                  _lastNameTextController.text.isEmpty
//                      ? Container()
//                      : InkWell(onTap: () {
//                    setState(() {
//                      _lastNameTextController.clear();
//                    });
//                  }, child: Icon(Icons.clear,
//                    color: _lastNameFocusNode.hasFocus
//                        ? darkBlue
//                        : Colors.grey,
//                  ),)
//                ],
//              ),
//              StandardTextFormField(textInputType: TextInputType.multiline,
//                maxLines: 3,
//                validationFail: addressValidationFail,
//                validatorMessage: 'Please enter an Address',
//                focusNode: _addressFocusNode,
//                labelColor: _addressLabelColor,
//                labelText: 'Address',
//                controller: _addressTextController,
//              ),
//              StandardTextFormField(
//                focusNode: _postcodeFocusNode,
//                labelColor: _postcodeLabelColor,
//                labelText: 'Post Code',
//                controller: _postcodeTextController,
//              ),
//              StandardTextFormField(
//                textInputType: Platform.isIOS ? TextInputType.numberWithOptions(signed: true) : TextInputType.phone,
//                focusNode: _telephoneFocusNode,
//                labelColor: _telephoneLabelColor,
//                labelText: 'Telephone',
//                controller: _telephoneTextController,
//              ),
//              StandardTextFormField(
//                textInputType: Platform.isIOS ? TextInputType.numberWithOptions(signed: true) : TextInputType.phone,
//                focusNode: _mobileFocusNode,
//                labelColor: _mobileLabelColor,
//                labelText: 'Mobile',
//                controller: _mobileTextController,
//              ),
//              _buildEmailTextField(),
//              SizedBox(
//                height: 10.0,
//              ),
//              _buildSubmitButton(),
//            ],),
//          ),
//        ),
//      ),
//    );
//  }
//
//  void _saveCustomer() {
//
//    if (_emailFieldController.text.isNotEmpty && _emailFieldController.text.trim().length > 0 &&
//        !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
//            .hasMatch(_emailFieldController.text)){
//      setState(() {
//        emailValidationFail = true;
//      });
//    } else {
//      setState(() {
//        emailValidationFail = false;
//      });
//    }
//
//    if(_firstNameTextController.text.isEmpty && _lastNameTextController.text.isEmpty){
//      setState(() {
//        firstNameValidationFail = true;
//        lastNameValidationFail = true;
//      });
//    } else {
//      setState(() {
//        firstNameValidationFail = false;
//        lastNameValidationFail = false;
//      });
//    }
//    if(_addressTextController.text.isEmpty){
//      setState(() {
//        addressValidationFail = true;
//      });
//    } else {
//      setState(() {
//        addressValidationFail = false;
//      });
//    }
//
//    if (!_formKey.currentState.validate()) {
//      showDialog(
//          context: context,
//          builder: (BuildContext context) {
//            return AlertDialog(
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
//              title: Text(
//                'Notice',
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              content: Text(
//                  'Please ensure all required fields are completed (highlighted in red)'),
//              actions: <Widget>[
//                FlatButton(
//                  onPressed: () => Navigator.of(context).pop(),
//                  child: Text(
//                    'OK',
//                    style: TextStyle(color: darkBlue),
//                  ),
//                ),
//              ],
//            );
//          });
//      return;
//    }
//
//    if (context.read<CustomersModel>().selectedCustomer != null) {
//
//      GlobalFunctions.showLoadingDialog('Editing Customer...');
//
//      context.read<CustomersModel>().addEditCustomer(true,
//          _prefixValue,
//          _firstNameTextController.text,
//          _lastNameTextController.text,
//          _addressTextController.text,
//          _postcodeTextController.text,
//          _telephoneTextController.text,
//          _mobileTextController.text,
//          _emailFieldController.text,
//      );
//    } else {
//
//      GlobalFunctions.showLoadingDialog('Adding Customer...');
//
//      context.read<CustomersModel>().addEditCustomer(false,
//          _prefixValue,
//          _firstNameTextController.text,
//          _lastNameTextController.text,
//          _addressTextController.text,
//          _postcodeTextController.text,
//          _telephoneTextController.text,
//          _mobileTextController.text,
//          _emailFieldController.text,
//      );
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    print('[Product Create Page] - build page');
//    // TODO: implement build
//    return Material(child: Consumer<CustomersModel>(
//      builder: (BuildContext context, CustomersModel model, _) {
//        final Widget pageContent = loading ? Center(child: CircularProgressIndicator(
//          valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
//        ),): _buildPageContent(context);
//        return model.selectedCustomer == null
//            ? pageContent
//            : Scaffold(
//          backgroundColor: whiteGreen,
//          appBar: AppBar(iconTheme: IconThemeData(color: darkBlue), backgroundColor: mintGreen,
//            title: FittedBox(fit:BoxFit.fitWidth,
//                child: Text('Edit Customer', style: TextStyle(color: darkBlue),)),
//          ),
//          body: pageContent,
//        );
//      },
//    ),);
//  }
//}
