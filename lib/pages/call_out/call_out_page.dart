import 'dart:convert';

import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/pages/caves/download_caves_button.dart';
import 'package:caving_app/widgets/dropdown_form_field.dart';
import 'package:caving_app/widgets/dropdown_form_field_cave.dart';
import 'package:caving_app/widgets/side_drawer.dart';
import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import '../../utils/database_helper.dart';
import 'package:provider/provider.dart';
import '../../shared/strings.dart';
import '../../models/call_out_model.dart';
import 'package:share/share.dart';




class CallOutPage extends StatefulWidget {

  final bool edit;

  CallOutPage([this.edit = false]);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CallOutPageState();
  }
}

class _CallOutPageState
    extends State<CallOutPage> {

  bool _loadingTemporary = false;
  bool _disableScreen = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
  DateTime _entryDate;
  DateTime _exitDate;
  final TextEditingController _entryDateController = new TextEditingController();
  final TextEditingController _exitDateController = new TextEditingController();
  final TextEditingController _detailsTextController = new TextEditingController();
  final FocusNode _detailsFocusNode = new FocusNode();
  Color _detailsLabelColor = Colors.grey;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> cavers = [];
  List<Cave> _caves = [Cave(
    length: null,
    county: null,
    uid: null,
    verticalRange: null,
    parkingPostCode: null,
    parkingLongitude: null,
    parkingLatitude: null,
    documentId: null,
    description: null,
    caveLongitude: null,
    caveLatitude: null,
    name: 'Select One'
  )];
  Cave cave;
  bool hasCaves = false;


  @override
  initState() {
    super.initState();
    _loadingTemporary = true;
    _setupFocusNodes();
    _setupTextControllerListeners();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _populateCaveDrop();
    });
  }

  @override
  void dispose() {
    _detailsTextController.dispose();
    _entryDateController.dispose();
    _exitDateController.dispose();
    _detailsFocusNode.dispose();
    super.dispose();
  }



  _setupFocusNodes() {
    _detailsFocusNode.addListener(() {
      if (mounted) {
        if (_detailsFocusNode.hasFocus) {
          setState(() {
            _detailsLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _detailsLabelColor = Colors.grey;
          });
        }
      }
    });
  }

  _setupTextControllerListeners() {
    _detailsTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCallOutField({
        Strings.details: GlobalFunctions.databaseValueString(
            _detailsTextController.text)
      }, user.uid);

    });
  }


  _populateCaveDrop() async{

    cave = _caves[0];
    _caves = [_caves[0]];


    List<Map<String, dynamic>> databaseCaves = await context.read<CaveModel>().getAllCaves();
    if(databaseCaves.length > 1){
      databaseCaves.forEach((element) {
        _caves.add(
            Cave(
                length: element[Strings.length],
                county: element[Strings.county],
                uid: element[Strings.uid],
                verticalRange: element[Strings.verticalRange],
                parkingPostCode: element[Strings.parkingPostCode],
                parkingLongitude: element[Strings.parkingLongitude],
                parkingLatitude: element[Strings.parkingLatitude],
                documentId: element[Strings.documentId],
                description: element[Strings.description],
                caveLongitude: element[Strings.caveLongitude],
                caveLatitude: element[Strings.caveLatitude],
                name: element[Strings.name]
            )
        );

      });
      hasCaves = true;
    } else {

      hasCaves = false;
      GlobalFunctions.showToast('Please download caves using download button');
    }

    _getTemporaryCallOut();


  }

  _getTemporaryCallOut() async{
    if(mounted) {
      int result = await _databaseHelper.checkTemporaryCallOutExists(user.uid);


      if (result != 0) {
        Map<String, dynamic> callOut = await _databaseHelper.getTemporaryCallOut(user.uid);
        if (callOut[Strings.details] != null) {
          _detailsTextController.text =
              GlobalFunctions.databaseValueString(callOut[Strings.details]);
        } else {

          _detailsTextController.text = '';
        }

        if (callOut[Strings.entryDate] != null) {
          _entryDateController.text =
              dateFormat.format(
                  DateTime.parse(callOut[Strings.entryDate]));

          _entryDate = DateTime.parse(callOut[Strings.entryDate]);

        } else {
          _entryDateController.text = '';
          _entryDate = null;
        }
        if (callOut[Strings.exitDate] != null) {
          _exitDateController.text =
              dateFormat.format(
                  DateTime.parse(callOut[Strings.exitDate]));

          _entryDate = DateTime.parse(callOut[Strings.exitDate]);

        } else {
          _exitDateController.text = '';
          _entryDate = null;
        }
        if (callOut[Strings.cavers] != null) {
          List<dynamic> caversDynamic = jsonDecode(callOut[Strings.cavers]);

          List<Map<String,dynamic>> caversList = [];

          caversDynamic.forEach((dynamic caver){

            Map<String,dynamic> actualMap = Map.from(caver);
            caversList.add(actualMap);

          });

          cavers = caversList;

        } else {
          cavers = [];
        }


        cave = _caves[0];

        if (callOut['cave'] != null) {

          Map<String, dynamic> localCave = jsonDecode(callOut['cave']);

          if(localCave != null && localCave['uid'] != null){
            for(Cave caveObject in _caves){
              if(caveObject.uid == localCave['uid']){
                setState(() {
                  cave = caveObject;
                });
                break;
              }

            }

          }

        }

        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingTemporary = false;
          });
        }
      }
    }
  }

  Widget _buildCaveDrop() {
    return DropdownFormFieldCave(
      expanded: true,
      hint: 'Cave',
      value: cave,
      items: _caves.toList(),
      onChanged: (val) => setState(() {
        cave = val;
        Map<String, dynamic> caveMap = {
          Strings.documentId: val.documentId,
          Strings.uid: val.uid,
          Strings.name: val.name,
          Strings.description: val.description,
          Strings.caveLatitude: val.caveLatitude,
          Strings.caveLongitude: val.caveLongitude,
          Strings.parkingLatitude: val.parkingLatitude,
          Strings.parkingLongitude: val.parkingLongitude,
          Strings.parkingPostCode: val.parkingPostCode,
          Strings.verticalRange: val.verticalRange,
          Strings.length: val.length,
          Strings.county: val.county,
        };
        _databaseHelper.updateTemporaryCallOutField(
            {Strings.cave : jsonEncode(caveMap)}, user.uid);
        FocusScope.of(context).unfocus();
      }),
      initialValue: cave,
    );
  }


  Widget _buildEntryDateField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(
                      labelText: 'Time of Entry:',
                  ),
                  initialValue: null,
                  controller: _entryDateController,
                  validator: (String value) {
                    String message;
                    if (value.trim().length <= 0 && value.isEmpty) {
                      message = 'Please enter a date';
                    }
                    return message;
                  },
                  onSaved: (String value) {
                    setState(() {
                      _entryDateController.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _entryDate = null;
                    _entryDateController.clear();

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: darkBlue),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: mintGreen,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      showTimePicker(
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light().copyWith(
                                  primary: mintGreen,
                                ),
                              ),
                              child: child,
                            );
                          },
                          context: context, initialTime: TimeOfDay.now())
                          .then((TimeOfDay time) {
                        if (time != null) {
                          newDate = newDate.add(
                              Duration(hours: time.hour, minutes: time.minute));
                          String dateTime = dateFormat.format(newDate);
                          setState(() {
                            _entryDateController.text = dateTime;
                            _entryDate = newDate;
                            if(!widget.edit) _databaseHelper.updateTemporaryCallOutField(
                                {Strings.entryDate : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid);

                          });
                        }
                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }

  Widget _buildExitDateField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(
                    labelText: 'Expected Time of Exit:',
                  ),
                  initialValue: null,
                  controller: _exitDateController,
                  validator: (String value) {
                    String message;
                    if (value.trim().length <= 0 && value.isEmpty) {
                      message = 'Please enter a date';
                    }
                    return message;
                  },
                  onSaved: (String value) {
                    setState(() {
                      _exitDateController.text = value;
                    });
                  },

                ),
              ),
            ),
            IconButton(
                color: Colors.grey,
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _exitDate = null;
                    _exitDateController.clear();

                  });
                }),
            IconButton(
                icon: Icon(Icons.access_time,
                    color: darkBlue),
                onPressed: () async{
                  FocusScope.of(context).unfocus();
                  await Future.delayed(Duration(milliseconds: 100));
                  showDatePicker(
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light().copyWith(
                              primary: mintGreen,
                            ),
                          ),
                          child: child,
                        );
                      },
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100))
                      .then((DateTime newDate) {
                    if (newDate != null) {
                      showTimePicker(
                          builder: (BuildContext context, Widget child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light().copyWith(
                                  primary: mintGreen,
                                ),
                              ),
                              child: child,
                            );
                          },
                          context: context, initialTime: TimeOfDay.now())
                          .then((TimeOfDay time) {
                        if (time != null) {
                          newDate = newDate.add(
                              Duration(hours: time.hour, minutes: time.minute));
                          String dateTime = dateFormat.format(newDate);
                          setState(() {
                            _exitDateController.text = dateTime;
                            _exitDate = newDate;
                            if(!widget.edit) _databaseHelper.updateTemporaryCallOutField(
                                {Strings.exitDate : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid);

                          });
                        }
                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }


  Widget _buildDetailsTextField() {
    return TextFormField(
      maxLines: 4,
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter some details';
        }
        return message;
      },
      focusNode: _detailsFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _detailsLabelColor),
          labelText: 'Additional Info:',
          suffixIcon: _detailsTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _detailsTextController.clear();
                  });
                });
              })
      ),
      controller: _detailsTextController,
    );
  }

  void _resetCallOut() {
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
              child: Center(child: Text("Reset Call Out", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
            ),
            content: Text('Are you sure you wish to reset this form?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'No',
                  style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: FlatButton(
                    onPressed: () {

                      setState(() {
                        _entryDate = null;
                        _entryDateController.clear();
                        _exitDate = null;
                        _exitDateController.clear();
                        _detailsTextController.clear();
                        cavers = [];
                        cave = _caves[0];
                      });
                      _databaseHelper.resetTemporaryCallOut(user.uid);
                      Navigator.of(context).pop();
                      FocusScope.of(context).unfocus();

                    },
                    child: Text(
                      'Yes',
                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  }),
            ],
          );
        });
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
              child: Text('Share', style: TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () => _disableScreen == true
                  ? null
                  : _submitForm(),
            )));
  }

  void _submitForm() async {

    if (_formKey.currentState.validate()) {

      Map<String, dynamic> callOutData = {
        Strings.details: _detailsTextController.text,
        Strings.entryDate: _entryDate,
        Strings.exitDate: _exitDate,
        Strings.cavers: jsonEncode(cavers)
      };

      List<String> caverNames = [];
      cavers.forEach((element) {
        caverNames.add(element['name'] == null ? '' : element['name']);
      });
      String caverString = caverNames.join("\n");

      cave.name == 'Select One' ? Share.share(
          "Cave Entry Time: ${_entryDateController.text}\n"
              "Expected Time of Exit: ${_entryDateController.text}\n"
              "Cavers: ${user.username}\n$caverString\nDetails: ${_detailsTextController.text}\n",
              subject: 'Cavetracker - Call Out Information'
      ) : Share.share(
          "Cave Entry Time: ${_entryDateController.text}\n"
              "Expected Time of Exit: ${_entryDateController.text}\n"
              "Cavers: ${user.username}\n$caverString\nDetails: ${_detailsTextController.text}\n"
              "Cave: ${cave.name}\nCave Latitude: ${cave.caveLatitude}\nCave Longitude: ${cave.caveLongitude}\nCave Length: ${cave.length}\nCave Vertical Range: ${cave.verticalRange}\nParking Latitude: ${cave.parkingLatitude}\nParking Longitude: ${cave.caveLongitude}\nParking Post Code: ${cave.parkingPostCode}", subject: 'Cavetracker - Call Out Information'
      );

    }


  }

  _getContacts() async{

    Iterable<Contact> contacts;
    List<Contact> contactsList;

    GlobalFunctions.showLoadingDialog('Loading Contacts...');
    if (await Permission.contacts.request().isGranted) {
      contacts = await ContactsService.getContacts(withThumbnails: false);
      contactsList = contacts.toList();
      GlobalFunctions.dismissLoadingDialog();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AddCavers(cavers, contactsList, updateCavers);
          }
      ).then((value) => {
      setState(() {
      cavers = cavers;
      })
      });
    } else {
      GlobalFunctions.dismissLoadingDialog();
      GlobalFunctions.showToast('Please accept permission to access device contacts');
    }

  }

  updateCavers(List<Map<String, dynamic>> updatedList){
    cavers = updatedList;

    if(!widget.edit) _databaseHelper.updateTemporaryCallOutField({
      Strings.cavers: jsonEncode(cavers)
    }, user.uid);
  }

  Widget _buildListTile(int index) {

    Widget returnedWidget;

    if(cavers.length < 1) {
      returnedWidget = Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Center(child: Text('No Cavers Added'),),
        SizedBox(height: 10,)
      ],);
    } else {
      returnedWidget = Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.contacts,
              color: darkBlue,
              size: 30.0,
            ),
            trailing: _buildIconButton(cavers[index]),
            title: Text(cavers[index]['name'] == null ? '' : cavers[index]['name']),
          ),
          Divider(),
        ],
      );
    }

    return returnedWidget;
  }

  Widget _buildIconButton(Map<String, dynamic> selectedCaver){

    return IconButton(icon: Icon(Icons.remove, color: darkBlue,), onPressed: (){
        try{

          setState(() {
            cavers.removeWhere((caver) => caver['identifier'] == selectedCaver['identifier']);

          });
        } catch (e){
          print(e);
        }
      });


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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildEntryDateField(),
                  _buildExitDateField(),
                  hasCaves ? _buildCaveDrop() : Row(children: [
                    Expanded(child: _buildCaveDrop(),),
                    SizedBox(width: 5,),
                    DownloadCavesButton(() => _populateCaveDrop())
                  ],),
                  _buildDetailsTextField(),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: <Widget>[
                    Expanded(child: Text('Cavers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                    StyledBlueButton('Add Caver', _getContacts),
                  ],),
                  SizedBox(
                    height: 20,
                  ),
                  ListView.builder(shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cavers.length < 1 ? 1 : cavers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildListTile(index);
                    },),
                  SizedBox(
                    height: 20,
                  ),
                  _buildSubmitButton()
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(drawer: widget.edit ? null : SideDrawer(),
      appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Call Out', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
        actions: <Widget>[widget.edit ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetCallOut)],),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
        ),
      )
          : _buildPageContent(context),
    );
  }
}




class AddCavers extends StatefulWidget {

  final List<Map<String, dynamic>> cavers;
  final List<Contact> contactsList;
  final Function updateCavers;

  AddCavers(this.cavers, this.contactsList, this.updateCavers);

  @override
  _AddCaversState createState() => _AddCaversState();
}

class _AddCaversState extends State<AddCavers> {

  List<Map<String, dynamic>> temporaryCavers = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    temporaryCavers = widget.cavers;
  }

  @override
  void dispose() {
    super.dispose();
  }


  Widget _buildListTile(int index, List<Contact> contacts) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.contacts,
            color: darkBlue,
            size: 30.0,
          ),
          trailing: _buildIconButton(contacts[index]),
          title: Text(contacts[index].displayName == null ? '' : contacts[index].displayName),
        ),
        Divider(),
      ],
    );
  }

  Widget _buildIconButton(Contact contact){

    Widget returnedWidget;

    bool exists = containsIdentifier(contact.identifier);

    if(exists){
      returnedWidget = IconButton(icon: Icon(Icons.remove, color: darkBlue,), onPressed: (){
        try{

          setState(() {
            temporaryCavers.removeWhere((caver) => caver['identifier'] == contact.identifier);

          });
        } catch (e){
          print(e);
        }
      });
    } else {
      returnedWidget = IconButton(icon: Icon(Icons.add, color: darkBlue,), onPressed: (){
        setState(() {
          temporaryCavers.add({'name': contact.displayName, 'identifier': contact.identifier});
        });
      });
    }

    return returnedWidget;


  }


  bool containsIdentifier(String identifier) {
    for (Map<String, dynamic> caver in temporaryCavers) {
      if (caver['identifier'] == identifier) return true;
    }
    return false;
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
        child: Center(child: Text("Add Cavers", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
      ),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, widget.contactsList);
          },
          itemCount: widget.contactsList.length,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              widget.updateCavers(temporaryCavers);
              Navigator.pop(context);
            });
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



