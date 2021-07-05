import 'dart:convert';
import 'dart:io';
import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/pages/caves/download_caves_button.dart';
import 'package:caving_app/widgets/dropdown_form_field.dart';
import 'package:caving_app/widgets/side_drawer.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import '../../utils/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/strings.dart';
import '../../models/activity_log_model.dart';
import 'package:photo_view/photo_view.dart';



class ActivityLogPage extends StatefulWidget {

  final bool edit;

  ActivityLogPage([this.edit = false]);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ActivityLogPageState();
  }
}

class _ActivityLogPageState
    extends State<ActivityLogPage> {

  bool _loadingTemporary = false;
  bool _disableScreen = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  final dateFormat = DateFormat("dd/MM/yyyy");
  DateTime _date;
  bool _pickInProgress = false;
  bool _share = false;

  final TextEditingController _titleTextController = new TextEditingController();
  final TextEditingController _detailsTextController = new TextEditingController();
  final TextEditingController _dateTextController = new TextEditingController();
  final TextEditingController _caveTextController = new TextEditingController();


  final FocusNode _titleFocusNode = new FocusNode();
  final FocusNode _detailsFocusNode = new FocusNode();
  final FocusNode _caveFocusNode = new FocusNode();

  Color _titleLabelColor = Colors.grey;
  Color _detailsLabelColor = Colors.grey;
  Color _caveLabelColor = Colors.grey;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _caveStrings = ['Select One'];
  String cave = 'Select One';
  bool hasCaves = false;

  @override
  initState() {
    super.initState();
    _loadingTemporary = true;
    _setupFocusNodes();
    _setupTextControllerListeners();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getCaves();
      widget.edit ? _getSelectedActivityLog() : _getTemporaryActivityLog();
    });
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _detailsTextController.dispose();
    _dateTextController.dispose();
    _caveTextController.dispose();
    _titleFocusNode.dispose();
    _detailsFocusNode.dispose();
    _caveFocusNode.dispose();
    super.dispose();
  }


  _getCaves() async{

    List<Map<String, dynamic>> databaseCaves = await context.read<CaveModel>().getAllCaves();
    if(databaseCaves.length > 1){
      databaseCaves.forEach((element) {
        _caveStrings.add(element['name']);
      });
      hasCaves = true;
    } else {
      GlobalFunctions.showToast('Please download caves using download button');
    }
  }

  _setupFocusNodes() {
    _titleFocusNode.addListener(() {
      if (mounted) {
        if (_titleFocusNode.hasFocus) {
          setState(() {
            _titleLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _titleLabelColor = Colors.grey;
          });
        }
      }
    });
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
    _caveFocusNode.addListener(() {
      if (mounted) {
        if (_caveFocusNode.hasFocus) {
          setState(() {
            _caveLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _caveLabelColor = Colors.grey;
          });
        }
      }
    });
  }

  _setupTextControllerListeners() {

    _titleTextController.addListener(() {
        if(!widget.edit) _databaseHelper.updateTemporaryActivityLogField({
          Strings.title: GlobalFunctions.databaseValueString(
              _titleTextController.text)
        }, user.uid);

    });
    _detailsTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryActivityLogField({
        Strings.details: GlobalFunctions.databaseValueString(
            _detailsTextController.text)
      }, user.uid);

    });
    _caveTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryActivityLogField({
        Strings.caveName: GlobalFunctions.databaseValueString(
            _caveTextController.text)
      }, user.uid);
    });
  }

  _getSelectedActivityLog() async{
    if(mounted) {

      Map<String, dynamic> activityLog = context.read<ActivityLogModel>().selectedActivityLog;

      if (activityLog[Strings.title] != null) {
        _titleTextController.text =
            GlobalFunctions.databaseValueString(activityLog[Strings.title]);
      }
      if (activityLog[Strings.details] != null) {
        _detailsTextController.text =
            GlobalFunctions.databaseValueString(activityLog[Strings.details]);
      }
      if (activityLog[Strings.caveName] != null) {
        cave = GlobalFunctions.databaseValueString(activityLog[Strings.caveName]);
      }
      if (activityLog[Strings.caveName] != null) {
        _caveTextController.text =
            GlobalFunctions.databaseValueString(activityLog[Strings.caveName]);
      }

//      if (activityLog[Strings.date] != null) {
//        _dateTextController.text =
//            dateFormat.format(
//                DateTime.parse(activityLog[Strings.date]));
//
//        _date = DateTime.parse(activityLog[Strings.date]);
//
//      } else {
//        _dateTextController.text = '';
//        _date = null;
//      }

      if (activityLog[Strings.share] != null) {
        if (mounted) {
          setState(() {
            _share = activityLog[Strings.share];
          });
        }
      }

      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }
    }
  }

  _getTemporaryActivityLog() async{
    if(mounted) {
      int result = await _databaseHelper.checkTemporaryActivityLogExists(user.uid);

      print('results' + result.toString());

      if (result != 0) {
        Map<String, dynamic> activityLog = await _databaseHelper.getTemporaryActivityLog(user.uid);

        if (activityLog[Strings.title] != null) {
          _titleTextController.text =
              GlobalFunctions.databaseValueString(activityLog[Strings.title]);
        } else {
          _titleTextController.text = '';
        }
        if (activityLog[Strings.caveName] != null) {
          _caveTextController.text =
              GlobalFunctions.databaseValueString(activityLog[Strings.caveName]);
        } else {
          _caveTextController.text = '';
        }
        if (activityLog[Strings.caveName] != null) {
          cave = GlobalFunctions.databaseValueString(activityLog[Strings.caveName]);
        }
        if (activityLog[Strings.details] != null) {
          _detailsTextController.text =
              GlobalFunctions.databaseValueString(activityLog[Strings.details]);
        } else {

          _detailsTextController.text = '';
        }

//        if (activityLog[Strings.date] != null) {
//          _dateTextController.text =
//              dateFormat.format(
//                  DateTime.parse(activityLog[Strings.date]));
//
//          _date = DateTime.parse(activityLog[Strings.date]);
//
//        } else {
//          _dateTextController.text = '';
//          _date = null;
//        }

        if (activityLog[Strings.share] !=
            null &&
            activityLog[Strings.share] ==
                1 ||
            activityLog[Strings.share] ==
                'true') {
          if (mounted) {
            setState(() {
              _share = true;
            });
          }
        } else {
          _share = false;
        }





        if (activityLog[Strings.images] != null && context.read<ActivityLogModel>().getLostImage == false) {
          context.read<ActivityLogModel>().temporaryPaths =
              jsonDecode(activityLog[Strings.images]);

          if (context.read<ActivityLogModel>().temporaryPaths != null) {
            int index = 0;
            context.read<ActivityLogModel>().temporaryPaths.forEach((dynamic path) {
              if (path != null) {
                if (File(path).existsSync()) {
                  setState(() {
                    context.read<ActivityLogModel>().images[index] = File(path);
                  });
                }
              }

              index++;
            });
          }
        } else if(activityLog[Strings.images] != null && context.read<ActivityLogModel>().getLostImage == true){


          context.read<ActivityLogModel>().temporaryPaths =
              jsonDecode(activityLog[Strings.images]);

          if (context.read<ActivityLogModel>().temporaryPaths != null) {
            int index = 0;
            context.read<ActivityLogModel>().temporaryPaths.forEach((dynamic path) {
              if (path != null) {
                if (File(path).existsSync()) {
                  setState(() {
                    context.read<ActivityLogModel>().images[index] = File(path);
                  });
                }
              }

              index++;
            });
          }

          File image = context.read<ActivityLogModel>().lostImage;



          if (image != null) {

            int index = context.read<ActivityLogModel>().crashedIndex;

            setState(() {

              context.read<ActivityLogModel>().images[index] = null;

            });

            int pathCount = await _databaseHelper.getImagePathCount();
            if (pathCount != null && pathCount == 0) {
              if (image.path != null) {
                String path = image.path;

                int lastIndex = path.lastIndexOf('/');

                String picturesFolder = path.substring(0, lastIndex);

                await _databaseHelper.addImagePath({Strings.imagePath: picturesFolder});
              }
            }

            final Directory extDir = await getApplicationDocumentsDirectory();

            final String dirPath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages';
            final String filePath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages/image${index.toString()}.jpg';

            if (!Directory(dirPath).existsSync()) {
              new Directory(dirPath).createSync(recursive: true);
            }

            if(File(filePath).existsSync()){
              File oldImage = File(filePath);
              oldImage.deleteSync(recursive: true);
              imageCache.clear();
            }

            String path = '$dirPath/image${index.toString()}.jpg';

            if(Platform.isAndroid){
              image = await FlutterExifRotation.rotateImage(path: image.path);
            }

            File changedImage = await FlutterImageCompress.compressAndGetFile(image.absolute.path, path, quality: 50, keepExif: false);

            path = changedImage.path;


            if (context.read<ActivityLogModel>().images[index] != null) {
              setState(() {
                //this is setting the image locally here
                context.read<ActivityLogModel>().images[index] = changedImage;
                if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (context.read<ActivityLogModel>().temporaryPaths.length < index + 1) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                }
              });
            } else {
              setState(() {
                context.read<ActivityLogModel>().images[index] = changedImage;
                if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 0 && context.read<ActivityLogModel>().temporaryPaths.length >= 1) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length < 2) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length >= 2) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length < 3) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length >= 3) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length < 4) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length >= 4) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length < 5) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length >= 5) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                }
              });
            }

            var encodedPaths = jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
            _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);

          }

          await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : false, Strings.imageIndex: 0, Strings.formName: null});
          context.read<ActivityLogModel>().getLostImage = false;
          context.read<ActivityLogModel>().lostImage = null;


        } else if(activityLog[Strings.images] == null && context.read<ActivityLogModel>().getLostImage == true){

          File image = context.read<ActivityLogModel>().lostImage;


          if (image != null) {

            int index = context.read<ActivityLogModel>().crashedIndex;

            setState(() {

              context.read<ActivityLogModel>().images[index] = null;

            });

            int pathCount = await _databaseHelper.getImagePathCount();
            if (pathCount != null && pathCount == 0) {
              if (image.path != null) {
                String path = image.path;

                int lastIndex = path.lastIndexOf('/');

                String picturesFolder = path.substring(0, lastIndex);

                await _databaseHelper.addImagePath({DatabaseHelper.imagePath: picturesFolder});
              }
            }

            final Directory extDir = await getApplicationDocumentsDirectory();

            final String dirPath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages';
            final String filePath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages/image${index.toString()}.jpg';

            if (!Directory(dirPath).existsSync()) {
              print('directory does not exist');
              new Directory(dirPath).createSync(recursive: true);
            }

            if(File(filePath).existsSync()){
              File oldImage = File(filePath);
              oldImage.deleteSync(recursive: true);
              imageCache.clear();
            }

            String path = '$dirPath/image${index.toString()}.jpg';

            if(Platform.isAndroid){
              image = await FlutterExifRotation.rotateImage(path: image.path);
            }

            File changedImage = await FlutterImageCompress.compressAndGetFile(image.absolute.path, path, quality: 50, keepExif: false);

            path = changedImage.path;


            if (context.read<ActivityLogModel>().images[index] != null) {
              setState(() {
                //this is setting the image locally here
                context.read<ActivityLogModel>().images[index] = changedImage;
                if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (context.read<ActivityLogModel>().temporaryPaths.length < index + 1) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                }
              });
            } else {
              setState(() {
                context.read<ActivityLogModel>().images[index] = changedImage;
                if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 0 && context.read<ActivityLogModel>().temporaryPaths.length >= 1) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length < 2) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length >= 2) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length < 3) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length >= 3) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length < 4) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length >= 4) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length < 5) {
                  context.read<ActivityLogModel>().temporaryPaths.add(path);
                } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length >= 5) {
                  context.read<ActivityLogModel>().temporaryPaths[index] = path;
                }
              });
            }

            var encodedPaths = jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
            _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);

          }

          await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : false, Strings.imageIndex: 0, Strings.formName: null});
          context.read<ActivityLogModel>().getLostImage = false;
          context.read<ActivityLogModel>().lostImage = null;

        } else if(activityLog[Strings.images] == null && context.read<ActivityLogModel>().getLostImage == false){
          context.read<ActivityLogModel>().temporaryPaths = [];
          context.read<ActivityLogModel>().images = [
            null,
            null,
            null,
            null,
            null
          ];
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

  Widget gridColor(BuildContext context, int index) {
    int minusIndex = index - 1;

    if (context.read<ActivityLogModel>().images[index] == null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (context.read<ActivityLogModel>().images[index] != null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            context.read<ActivityLogModel>().images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index > 0 &&
        context.read<ActivityLogModel>().images[minusIndex] != null &&
        context.read<ActivityLogModel>().images[index] == null) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (context.read<ActivityLogModel>().images[index] != null && index > 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            context.read<ActivityLogModel>().images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.grey,
        ),
      );
    }
  }

  List<Widget> _buildGridTiles(BoxConstraints constraints, int numOfTiles) {
    List<Container> containers =
    List<Container>.generate(numOfTiles, (int index) {
      return Container(
        padding: EdgeInsets.all(2.0),
        width: constraints.maxWidth / 5,
        height: constraints.maxWidth / 5,
        child: GestureDetector(
          onLongPress: () {
            int minusIndex = index - 1;

            if (index == 0) {
              _openImagePicker(context, index);
            } else if (index > 0 && context.read<ActivityLogModel>().images[minusIndex] == null) {
              return;
            } else {
              _openImagePicker(context, index);
            }
          },
          onTap: () {
            int minusIndex = index - 1;


            if (context.read<ActivityLogModel>().images[index] != null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    return ImagesDialog(index);
                  });
            } else if (index == 0) {
              _openImagePicker(context, index);
            } else if (index > 0 && context.read<ActivityLogModel>().images[minusIndex] == null) {
              return;
            } else {
              _openImagePicker(context, index);
            }
          },
          child: gridColor(context, index),
        ),
      );
    });
    return containers;
  }

  void _openImagePicker(BuildContext context, int index) async{
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    if (isAndroid) {
      await Permission.camera.request();
      await Permission.storage.request();
    }

    _showBottomSheet(index);
  }

  double _buildBottomSheetHeight(File image) {
    double _deviceHeight = MediaQuery.of(context).size.height;

    double height;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      height = image == null ? _deviceHeight * 0.3 : _deviceHeight * 0.37;
    } else {
      height = image == null ? _deviceHeight * 0.4 : _deviceHeight * 0.56;
    }

    return height;
  }

  Future<Widget> _showBottomSheet(int index) async {

    FocusScope.of(context).requestFocus(new FocusNode());

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(bottom: 10.0),
            height: _buildBottomSheetHeight(context.read<ActivityLogModel>().images[index]),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double sheetHeight = constraints.maxHeight;

                  return Container(
                    height: sheetHeight,
                    child: Column(
                      children: <Widget>[
                        Container(width: constraints.maxWidth,
                            color: mintGreen,
                            height: sheetHeight * 0.15,
                            child: Center(child: Text(
                              'Pick an Image',
                              style: TextStyle(color: darkBlue, fontSize: 18, fontWeight: FontWeight.bold),
                            ),)),
                        InkWell(onTap: () {
                          setState(() {
                            _disableScreen = true;
                          });
                          _pickPhoto(ImageSource.camera, index);
                        },child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: context.read<ActivityLogModel>().images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Camera', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),)),),
                        InkWell(onTap: () {
                          setState(() {
                            _disableScreen = true;
                          });
                          _pickPhoto(ImageSource.gallery, index);
                        }, child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: context.read<ActivityLogModel>().images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Gallery', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),)),),
                        context.read<ActivityLogModel>().images[index] == null
                            ? Container()
                            : InkWell(onTap: () {
                          setState(() {
                            context.read<ActivityLogModel>().images[index] = null;
                            context.read<ActivityLogModel>().temporaryPaths[index] = null;

                            int maxImageNo = context.read<ActivityLogModel>().images.length - 1;

                            //if the last image in the list
                            if (index == maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }

                            //if the image one in front is not null then replace this index with it
                            int plusOne = index + 1;
                            if (context.read<ActivityLogModel>().images[plusOne] != null) {
                              context.read<ActivityLogModel>().images[index] = context.read<ActivityLogModel>().images[plusOne];
                              context.read<ActivityLogModel>().images[plusOne] = null;
                              context.read<ActivityLogModel>().temporaryPaths[index] =
                              context.read<ActivityLogModel>().temporaryPaths[plusOne];
                              context.read<ActivityLogModel>().temporaryPaths[plusOne] = null;
                            }

                            //if the image two in front is not null then replace this index with it
                            int plusTwo = index + 2;
                            if (plusTwo > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }

                            if (context.read<ActivityLogModel>().images[plusTwo] != null) {
                              context.read<ActivityLogModel>().images[plusOne] = context.read<ActivityLogModel>().images[plusTwo];
                              context.read<ActivityLogModel>().images[plusTwo] = null;
                              context.read<ActivityLogModel>().temporaryPaths[plusOne] =
                              context.read<ActivityLogModel>().temporaryPaths[plusTwo];
                              context.read<ActivityLogModel>().temporaryPaths[plusTwo] = null;
                            }

                            //if the image three in front is not null then replace this index with it
                            int plusThree = index + 3;
                            if (plusThree > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }
                            if (context.read<ActivityLogModel>().images[plusThree] != null) {
                              context.read<ActivityLogModel>().images[plusTwo] = context.read<ActivityLogModel>().images[plusThree];
                              context.read<ActivityLogModel>().images[plusThree] = null;
                              context.read<ActivityLogModel>().temporaryPaths[plusTwo] =
                              context.read<ActivityLogModel>().temporaryPaths[plusThree];
                              context.read<ActivityLogModel>().temporaryPaths[plusThree] = null;
                            }

                            //if the image four in front is not null then replace this index with it
                            int plusFour = index + 4;
                            if (plusFour > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);

                              Navigator.pop(context);
                              return;
                            }

                            if (context.read<ActivityLogModel>().images[plusFour] != null) {
                              context.read<ActivityLogModel>().images[plusThree] = context.read<ActivityLogModel>().images[plusFour];
                              context.read<ActivityLogModel>().images[plusFour] = null;
                              context.read<ActivityLogModel>().temporaryPaths[plusThree] =
                              context.read<ActivityLogModel>().temporaryPaths[plusFour];
                              context.read<ActivityLogModel>().temporaryPaths[plusFour] = null;
                            }

                            var encodedPaths =
                            jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
                            _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);

                            Navigator.pop(context);
                          });
                        }, child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: sheetHeight * 0.283,
                            child: Center(child: Text('Delete Image', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),)),),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  _pickPhoto(ImageSource source, int index) async {

    print('here');
    if (_pickInProgress) {
      return;
    }
    _pickInProgress = true;
    Navigator.pop(context);

    if(source == ImageSource.camera){
      if(Platform.isAndroid){
        await _databaseHelper.update(DatabaseHelper.cameraCrashTable, {DatabaseHelper.hasCrashed : true, DatabaseHelper.imageIndex: index, DatabaseHelper.formName: Strings.activityLogTable});
        final Directory tempPictures = await getExternalStorageDirectory();
        final String testPath = '${tempPictures.path}/Pictures';
        print(testPath);

        if (Directory(testPath).existsSync()) {

          print('directory is here');

          List<FileSystemEntity> list = Directory(testPath).listSync(recursive: false)
              .toList();
          print('thisis the list of the files');
          print(list);

          for (FileSystemEntity file in list) {
            file.deleteSync(recursive: false);
          }
        }
      }


    }


    var pickedImage = await ImagePicker().getImage(source: source, maxWidth: 800);

    if (pickedImage != null) {

      File image = File(pickedImage.path);

      setState(() {

        context.read<ActivityLogModel>().images[index] = null;

      });

      int pathCount = await _databaseHelper.getImagePathCount();
      if (pathCount != null && pathCount == 0) {
        if (image.path != null) {
          String path = image.path;

          int lastIndex = path.lastIndexOf('/');

          String picturesFolder = path.substring(0, lastIndex);

          await _databaseHelper.addImagePath({DatabaseHelper.imagePath: picturesFolder});
        }
      }

      final Directory extDir = await getApplicationDocumentsDirectory();

      final String dirPath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages';
      final String filePath = '${extDir.path}/images/${user.uid}/temporaryActivityLogImages/image${index.toString()}.jpg';

      if (!Directory(dirPath).existsSync()) {
        new Directory(dirPath).createSync(recursive: true);
      }

      if(File(filePath).existsSync()){
        File oldImage = File(filePath);
        oldImage.deleteSync(recursive: true);
        imageCache.clear();
      }

      String path = '$dirPath/image${index.toString()}.jpg';

      if(Platform.isAndroid){
        image = await FlutterExifRotation.rotateImage(path: image.path);
      }

      File changedImage = await FlutterImageCompress.compressAndGetFile(image.absolute.path, path, quality: 50, keepExif: false);

      path = changedImage.path;


      if (context.read<ActivityLogModel>().images[index] != null) {

        setState(() {
          context.read<ActivityLogModel>().images[index] = changedImage;
          if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (context.read<ActivityLogModel>().temporaryPaths.length < index + 1) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          }
        });
      } else {

        setState(() {
          context.read<ActivityLogModel>().images[index] = changedImage;
          if (context.read<ActivityLogModel>().temporaryPaths.length == 0) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (index == 0 && context.read<ActivityLogModel>().temporaryPaths.length >= 1) {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length < 2) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (index == 1 && context.read<ActivityLogModel>().temporaryPaths.length >= 2) {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length < 3) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (index == 2 && context.read<ActivityLogModel>().temporaryPaths.length >= 3) {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length < 4) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (index == 3 && context.read<ActivityLogModel>().temporaryPaths.length >= 4) {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length < 5) {
            context.read<ActivityLogModel>().temporaryPaths.add(path);
          } else if (index == 4 && context.read<ActivityLogModel>().temporaryPaths.length >= 5) {
            context.read<ActivityLogModel>().temporaryPaths[index] = path;
          }
        });
      }

      var encodedPaths = jsonEncode(context.read<ActivityLogModel>().temporaryPaths);
      _databaseHelper.updateTemporaryActivityLogField({Strings.images : encodedPaths}, user.uid);

    } else {
      if(Platform.isAndroid){
        await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : false, Strings.imageIndex: 0, Strings.formName: null});
      }
    }
    // }
    setState(() {
      _disableScreen = false;
      _pickInProgress = false;
    });
  }

  Widget _buildDateField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: TextFormField(
                  enabled: true,
                  decoration: InputDecoration(
                      labelText: 'Date:',
                  ),
                  initialValue: null,
                  controller: _dateTextController,
                  validator: (String value) {
                    String message;
                    if (value.trim().length <= 0 && value.isEmpty) {
                      message = 'Please enter a date';
                    }
                    return message;
                  },
                  onSaved: (String value) {
                    setState(() {
                      _dateTextController.text = value;
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
                    _date = null;
                    _dateTextController.clear();

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
                      String dateTime = dateFormat.format(newDate);
                      setState(() {
                        _dateTextController.text = dateTime;
                        _date = newDate;
                        if(!widget.edit) _databaseHelper.updateTemporaryActivityLogField(
                            {Strings.date : DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch).toIso8601String()}, user.uid);

                      });
                    }
                  });
                })
          ],
        ),
      ],
    );
  }

  Widget _buildShareRow(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Row(children: [
          Text('Share with club members?', style: TextStyle(fontWeight: FontWeight.bold),),
          Checkbox(
              value: _share,
              onChanged: (bool value) => setState(() {
                _share = value;
                int savedValue = GlobalFunctions.boolToTinyInt(value);
                _databaseHelper.updateTemporaryActivityLogField({Strings.share : savedValue}, user.uid);
              }))
        ],)
      ],
    );
  }


  Widget _buildTitleTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a title';
        }
        return message;
      },
      focusNode: _titleFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _titleLabelColor),
          labelText: 'Title',
          suffixIcon: _titleTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _titleTextController.clear();
                  });
                });
              })
      ),
      controller: _titleTextController,
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
          labelText: 'Log Details',
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

  void _resetActivityLog() {
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
              child: Center(child: Text("Reset Activity Log", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
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
                        _date = null;
                        _dateTextController.clear();
                        _titleTextController.clear();
                        _detailsTextController.clear();
                        _caveTextController.clear();
                        cave = 'Select One';
                        _share = false;
                      });
                      _databaseHelper.resetTemporaryActivityLog(user.uid);
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.of(context).pop();
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
              child: Text(widget.edit ? 'Edit' : 'Submit', style: TextStyle(fontWeight: FontWeight.bold),),
              onPressed: () => _disableScreen == true
                  ? null
                  : _submitForm(),
            )));
  }

  Widget _buildCaveDrop() {
    return DropdownFormField(
      expanded: true,
      hint: 'Cave',
      value: cave,
      items: _caveStrings.toList(),
      onChanged: (val) => setState(() {
        cave = val;
        _databaseHelper.updateTemporaryActivityLogField(
            {Strings.caveName : val}, user.uid);
        FocusScope.of(context).unfocus();
      }),
      initialValue: cave,
    );
  }

  Widget _buildCaveRow() {
    return Row(children: <Widget>[
      Expanded(child: TypeAheadField(autoFlipDirection: true,
        textFieldConfiguration: TextFieldConfiguration(controller: _caveTextController,
            autofocus: false,
            focusNode: _caveFocusNode,
            decoration: InputDecoration(labelText: 'Cave', labelStyle: TextStyle(color: _caveFocusNode.hasFocus ? darkBlue : Colors.grey)
            )


        ),

        hideOnEmpty: true,
        suggestionsCallback: (pattern) async {

        context.read<CaveModel>().searchControllerActivityLog.text = _caveTextController.text.toLowerCase();

          return context.read<CaveModel>().searchControllerActivityLog.text.length < 3 ? null : await context.read<CaveModel>().searchCavesActivityLog();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Image.asset('assets/icons/caveIcon.png', height: 25,),
            title: Row(children: <Widget>[
              Flexible(child: Text(suggestion)),
            ],),
          );
        },
        onSuggestionSelected: (suggestion) async {


            setState(() {
              _caveTextController.text = suggestion;
              _databaseHelper.updateTemporaryActivityLogField(
                  {Strings.caveName : suggestion}, user.uid);
            });


        },
      )),
      _caveTextController.text.isEmpty ? Container() : InkWell(child: Container(padding: EdgeInsets.only(right: 10), child: Icon(Icons.clear, color: Colors.grey,),), onTap: (){
        setState(() {
          _caveTextController.clear();
          _databaseHelper.updateTemporaryActivityLogField(
              {Strings.caveName : null}, user.uid);
        });
      },),

    ],);
  }

  void _submitForm() async {

    if (_formKey.currentState.validate()) {

      bool success;

      if(widget.edit) {
        success = await context.read<ActivityLogModel>().submitActivityLog(_titleTextController.text, cave, _detailsTextController.text, _date, true);

      } else {
        success = await context.read<ActivityLogModel>().submitActivityLog(_titleTextController.text, cave, _detailsTextController.text, _date, _share);

      }

      if(success){
        setState(() {
          _date = null;
          _dateTextController.clear();
          _titleTextController.clear();
          _detailsTextController.clear();
          cave = 'Select One';
          _share = false;
          context.read<ActivityLogModel>().resetImages();
          FocusScope.of(context).requestFocus(new FocusNode());

        });
      }
    }


  }

  Widget _buildPageContent(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 768.0 ? 600.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    print('building page content');

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
                  //_buildDateField(),
                  _buildTitleTextField(),
                  hasCaves ? _buildCaveRow() : Row(children: [
                    Expanded(child: _buildCaveRow(),),
                    SizedBox(width: 5,),
                    DownloadCavesButton(() => _getCaves())
                  ],),
                  _buildDetailsTextField(),
                  user != null && user.clubId != '' ? _buildShareRow() : Container(),
                  SizedBox(height: 20.0,),
                  widget.edit ? Container() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text('Images', style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Consumer<ActivityLogModel>(
                        builder: (context,  model, child) {
                          return LayoutBuilder(builder:
                              (BuildContext context, BoxConstraints constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildGridTiles(constraints, context.read<ActivityLogModel>().images.length),
                            );
                          });}),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],),
                  _buildSubmitButton()
                ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    print('[Parts Form] - build page');

    // TODO: implement build
    return Scaffold(drawer: widget.edit ? null : SideDrawer(),
      appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Activity Log', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
        actions: <Widget>[widget.edit ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetActivityLog)],),
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

class ImagesDialog extends StatefulWidget {
  final int currentIndex;

  ImagesDialog(this.currentIndex);
  @override
  _ImagesDialogState createState() => new _ImagesDialogState();
}

class _ImagesDialogState extends State<ImagesDialog> {

  File currentImage;
  int imagesLength;
  int imageIndex;

  @override
  void initState() {
    imageIndex = widget.currentIndex;
    currentImage = context.read<ActivityLogModel>().images[imageIndex];
    imagesLength = _getImagesLength();
    // TODO: implement initState
    super.initState();
  }

  int _getImagesLength(){

    int count = 0;

    for(File image in context.read<ActivityLogModel>().images){
      if(image == null) continue;
      count ++;
    }

    return count;

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: Stack(children: <Widget>[
      PinchZoomImage(
        image: Image.file(currentImage),
        zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
        hideStatusBarWhileZooming: true,
        onZoomStart: () {
          print('Zoom started');
        },
        onZoomEnd: () {
          print('Zoom finished');
        },
      ),
      imageIndex == 0 ? Positioned.fill(child: Align(alignment: Alignment.centerLeft ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerLeft ,child: Container(child: IconButton(icon: Icon(Icons.arrow_back),
        onPressed: (){
          imageIndex --;
          setState(() {
            currentImage = context.read<ActivityLogModel>().images[imageIndex];
          });
        }, color: darkBlue,),margin: EdgeInsets.only(left: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),),
      imageIndex == (imagesLength -1) ? Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(child: IconButton(icon: Icon(Icons.arrow_forward),
        onPressed: (){
          imageIndex ++;
          setState(() {
            currentImage = context.read<ActivityLogModel>().images[imageIndex];
          });
        }, color: darkBlue,),margin: EdgeInsets.only(right: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),)

    ],));
  }
}

