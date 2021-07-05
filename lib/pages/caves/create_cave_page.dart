import 'dart:convert';
import 'dart:io';
import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/pages/caves/location_select.dart';
import 'package:caving_app/widgets/dropdown_form_field.dart';
import 'package:caving_app/widgets/side_drawer.dart';
import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
import '../../shared/counties.dart';
import '../../models/activity_log_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class CreateCavePage extends StatefulWidget {

  final bool edit;

  CreateCavePage([this.edit = false]);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CreateCavePageState();
  }
}

class _CreateCavePageState
    extends State<CreateCavePage> {

  bool _loadingTemporary = false;
  bool _disableScreen = false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _pickInProgress = false;
  String county = 'Select One';

  final TextEditingController _nameTextController = new TextEditingController();
  final TextEditingController _descriptionTextController = new TextEditingController();
  final TextEditingController _caveLatitudeTextController = new TextEditingController();
  final TextEditingController _caveLongitudeTextController = new TextEditingController();
  final TextEditingController _parkingLatitudeTextController = new TextEditingController();
  final TextEditingController _parkingLongitudeTextController = new TextEditingController();
  final TextEditingController _parkingPostCodeTextController = new TextEditingController();
  final TextEditingController _verticalRangeTextController = new TextEditingController();
  final TextEditingController _lengthTextController = new TextEditingController();
  final TextEditingController _countyTextController = new TextEditingController();

  final FocusNode _nameFocusNode = new FocusNode();
  final FocusNode _descriptionFocusNode = new FocusNode();
  final FocusNode _parkingPostCodeFocusNode = new FocusNode();
  final FocusNode _verticalRangeFocusNode = new FocusNode();
  final FocusNode _lengthFocusNode = new FocusNode();
  final FocusNode _countyFocusNode = new FocusNode();

  Color _nameLabelColor = Colors.grey;
  Color _descriptionLabelColor = Colors.grey;
  Color _parkingPostCodeLabelColor = Colors.grey;
  Color _verticalRangeLabelColor = Colors.grey;
  Color _lengthLabelColor = Colors.grey;
  Color _countyLabelColor = Colors.grey;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    _loadingTemporary = true;
    _setupFocusNodes();
    _setupTextControllerListeners();
    widget.edit ? _getSelectedCave() : _getTemporaryCave();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _descriptionTextController.dispose();
    _caveLatitudeTextController.dispose();
    _caveLongitudeTextController.dispose();
    _parkingLatitudeTextController.dispose();
    _parkingLongitudeTextController.dispose();
    _parkingPostCodeTextController.dispose();
    _verticalRangeTextController.dispose();
    _lengthTextController.dispose();
    _countyTextController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _parkingPostCodeFocusNode.dispose();
    _verticalRangeFocusNode.dispose();
    _lengthFocusNode.dispose();
    _countyFocusNode.dispose();

    super.dispose();
  }

  _setupFocusNodes() {
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
    _verticalRangeFocusNode.addListener(() {
      if (mounted) {
        if (_verticalRangeFocusNode.hasFocus) {
          setState(() {
            _verticalRangeLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _verticalRangeLabelColor = Colors.grey;
          });
        }
      }
    });
    _lengthFocusNode.addListener(() {
      if (mounted) {
        if (_lengthFocusNode.hasFocus) {
          setState(() {
            _lengthLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _lengthLabelColor = Colors.grey;
          });
        }
      }
    });
    _countyFocusNode.addListener(() {
      if (mounted) {
        if (_countyFocusNode.hasFocus) {
          setState(() {
            _countyLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _countyLabelColor = Colors.grey;
          });
        }
      }
    });
    _parkingPostCodeFocusNode.addListener(() {
      if (mounted) {
        if (_parkingPostCodeFocusNode.hasFocus) {
          setState(() {
            _parkingPostCodeLabelColor = darkBlue;
          });
        } else {
          setState(() {
            _parkingPostCodeLabelColor = Colors.grey;
          });
        }
      }
    });
  }

  _setupTextControllerListeners() {

    _nameTextController.addListener(() {
        if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
          Strings.name: GlobalFunctions.databaseValueString(
              _nameTextController.text)
        }, user.uid);

    });
    _descriptionTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.description: GlobalFunctions.databaseValueString(
            _descriptionTextController.text)
      }, user.uid);
    });
    _caveLatitudeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.caveLatitude: GlobalFunctions.databaseValueString(
            _caveLatitudeTextController.text)
      }, user.uid);
    });
    _caveLongitudeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.caveLongitude: GlobalFunctions.databaseValueString(
            _caveLongitudeTextController.text)
      }, user.uid);
    });
    _parkingLatitudeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.parkingLatitude: GlobalFunctions.databaseValueString(
            _parkingLatitudeTextController.text)
      }, user.uid);
    });
    _parkingLongitudeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.parkingLongitude: GlobalFunctions.databaseValueString(
            _parkingLongitudeTextController.text)
      }, user.uid);
    });
    _parkingPostCodeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.parkingPostCode: GlobalFunctions.databaseValueString(
            _parkingPostCodeTextController.text)
      }, user.uid);
    });
    _verticalRangeTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.verticalRange: GlobalFunctions.databaseValueString(
            _verticalRangeTextController.text)
      }, user.uid);
    });
    _lengthTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.length: GlobalFunctions.databaseValueString(
            _lengthTextController.text)
      }, user.uid);
    });
    _countyTextController.addListener(() {
      if(!widget.edit) _databaseHelper.updateTemporaryCaveField({
        Strings.county: GlobalFunctions.databaseValueString(
            _countyTextController.text)
      }, user.uid);
    });
  }

  _getSelectedCave() async{
    if(mounted) {

      Map<String, dynamic> cave = context.read<CaveModel>().selectedCave;

      if (cave[Strings.name] != null) {
        _nameTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.name]);
      }
      if (cave[Strings.description] != null) {
        _descriptionTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.description]);
      }
      if (cave[Strings.caveLatitude] != null) {
        _caveLatitudeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.caveLatitude]);
      }
      if (cave[Strings.caveLongitude] != null) {
        _caveLongitudeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.caveLongitude]);
      }
      if (cave[Strings.parkingLatitude] != null) {
        _parkingLatitudeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.parkingLatitude]);
      }
      if (cave[Strings.parkingLongitude] != null) {
        _parkingLongitudeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.parkingLongitude]);
      }
      if (cave[Strings.parkingPostCode] != null) {
        _parkingPostCodeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.parkingPostCode]);
      }
      if (cave[Strings.verticalRange] != null) {
        _verticalRangeTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.verticalRange]);
      }
      if (cave[Strings.length] != null) {
        _lengthTextController.text =
            GlobalFunctions.databaseValueString(cave[Strings.length]);
      }
      if (cave[Strings.county] != null) {
        county = GlobalFunctions.databaseValueString(cave[Strings.county]);
      }



      if (mounted) {
        setState(() {
          _loadingTemporary = false;
        });
      }
    }
  }

  _getTemporaryCave() async{
    if(mounted) {
      int result = await _databaseHelper.checkTemporaryCaveExists(user.uid);

      print('results' + result.toString());

      if (result != 0) {
        Map<String, dynamic> cave = await _databaseHelper.getTemporaryCave(user.uid);

        if (cave[Strings.name] != null) {
          _nameTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.name]);
        } else {
          _nameTextController.text = '';
        }
        if (cave[Strings.description] != null) {
          _descriptionTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.description]);
        } else {
          _descriptionTextController.text = '';
        }
        if (cave[Strings.caveLatitude] != null) {
          _caveLatitudeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.caveLatitude]);
        } else {
          _caveLatitudeTextController.text = '';
        }
        if (cave[Strings.caveLongitude] != null) {
          _caveLongitudeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.caveLongitude]);
        } else {
          _caveLongitudeTextController.text = '';
        }
        if (cave[Strings.parkingLatitude] != null) {
          _parkingLatitudeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.parkingLatitude]);
        } else {
          _parkingLatitudeTextController.text = '';
        }
        if (cave[Strings.parkingLongitude] != null) {
          _parkingLongitudeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.parkingLongitude]);
        } else {
          _parkingLongitudeTextController.text = '';
        }
        if (cave[Strings.parkingPostCode] != null) {
          _parkingPostCodeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.parkingPostCode]);
        } else {
          _parkingPostCodeTextController.text = '';
        }
        if (cave[Strings.verticalRange] != null) {
          _verticalRangeTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.verticalRange]);
        } else {
          _verticalRangeTextController.text = '';
        }
        if (cave[Strings.length] != null) {
          _lengthTextController.text =
              GlobalFunctions.databaseValueString(cave[Strings.length]);
        } else {
          _lengthTextController.text = '';
        }
        if (cave[Strings.county] != null) {
          county = GlobalFunctions.databaseValueString(cave[Strings.county]);
        }



        if (cave[Strings.images] != null && context.read<CaveModel>().getLostImage == false) {
          context.read<CaveModel>().temporaryPaths =
              jsonDecode(cave[Strings.images]);

          if (context.read<CaveModel>().temporaryPaths != null) {
            int index = 0;
            context.read<CaveModel>().temporaryPaths.forEach((dynamic path) {
              if (path != null) {
                if (File(path).existsSync()) {
                  setState(() {
                    context.read<CaveModel>().images[index] = File(path);
                  });
                }
              }

              index++;
            });
          }
        } else if(cave[Strings.images] != null && context.read<CaveModel>().getLostImage == true){


          context.read<CaveModel>().temporaryPaths =
              jsonDecode(cave[Strings.images]);

          if (context.read<CaveModel>().temporaryPaths != null) {
            int index = 0;
            context.read<CaveModel>().temporaryPaths.forEach((dynamic path) {
              if (path != null) {
                if (File(path).existsSync()) {
                  setState(() {
                    context.read<CaveModel>().images[index] = File(path);
                  });
                }
              }

              index++;
            });
          }

          File image = context.read<CaveModel>().lostImage;



          if (image != null) {

            int index = context.read<CaveModel>().crashedIndex;

            setState(() {

              context.read<CaveModel>().images[index] = null;

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

            final String dirPath = '${extDir.path}/images/${user.uid}/temporaryCaveImages';
            final String filePath = '${extDir.path}/images/${user.uid}/temporaryCaveImages/image${index.toString()}.jpg';

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


            if (context.read<CaveModel>().images[index] != null) {
              setState(() {
                //this is setting the image locally here
                context.read<CaveModel>().images[index] = changedImage;
                if (context.read<CaveModel>().temporaryPaths.length == 0) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (context.read<CaveModel>().temporaryPaths.length < index + 1) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                }
              });
            } else {
              setState(() {
                context.read<CaveModel>().images[index] = changedImage;
                if (context.read<CaveModel>().temporaryPaths.length == 0) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 0 && context.read<CaveModel>().temporaryPaths.length >= 1) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length < 2) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length >= 2) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length < 3) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length >= 3) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length < 4) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length >= 4) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length < 5) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length >= 5) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                }
              });
            }

            var encodedPaths = jsonEncode(context.read<CaveModel>().temporaryPaths);
            _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);

          }

          await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : 0, Strings.imageIndex: 0, Strings.formName: null});
          context.read<CaveModel>().getLostImage = false;
          context.read<CaveModel>().lostImage = null;


        } else if(cave[Strings.images] == null && context.read<CaveModel>().getLostImage == true){

          File image = context.read<CaveModel>().lostImage;


          if (image != null) {

            int index = context.read<CaveModel>().crashedIndex;

            setState(() {

              context.read<CaveModel>().images[index] = null;

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

            final String dirPath = '${extDir.path}/images/${user.uid}/temporaryCaveImages';
            final String filePath = '${extDir.path}/images/${user.uid}/temporaryCaveImages/image${index.toString()}.jpg';

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


            if (context.read<CaveModel>().images[index] != null) {
              setState(() {
                //this is setting the image locally here
                context.read<CaveModel>().images[index] = changedImage;
                if (context.read<CaveModel>().temporaryPaths.length == 0) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (context.read<CaveModel>().temporaryPaths.length < index + 1) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                }
              });
            } else {
              setState(() {
                context.read<CaveModel>().images[index] = changedImage;
                if (context.read<CaveModel>().temporaryPaths.length == 0) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 0 && context.read<CaveModel>().temporaryPaths.length >= 1) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length < 2) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length >= 2) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length < 3) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length >= 3) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length < 4) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length >= 4) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length < 5) {
                  context.read<CaveModel>().temporaryPaths.add(path);
                } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length >= 5) {
                  context.read<CaveModel>().temporaryPaths[index] = path;
                }
              });
            }

            var encodedPaths = jsonEncode(context.read<CaveModel>().temporaryPaths);
            _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);

          }

          await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : 0, Strings.imageIndex: 0, Strings.formName: null});
          context.read<CaveModel>().getLostImage = false;
          context.read<CaveModel>().lostImage = null;

        } else if(cave[Strings.images] == null && context.read<CaveModel>().getLostImage == false){
          context.read<CaveModel>().temporaryPaths = [];
          context.read<CaveModel>().images = [
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

    if (context.read<CaveModel>().images[index] == null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (context.read<CaveModel>().images[index] != null && index == 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            context.read<CaveModel>().images[index],
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (index > 0 &&
        context.read<CaveModel>().images[minusIndex] != null &&
        context.read<CaveModel>().images[index] == null) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black),
            borderRadius: BorderRadius.circular(10.0)),
        child: Icon(
          Icons.camera_alt,
          color: Colors.black,
        ),
      );
    } else if (context.read<CaveModel>().images[index] != null && index > 0) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            borderRadius: BorderRadius.circular(10.0)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(
            context.read<CaveModel>().images[index],
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
            } else if (index > 0 && context.read<CaveModel>().images[minusIndex] == null) {
              return;
            } else {
              _openImagePicker(context, index);
            }
          },
          onTap: () {
            int minusIndex = index - 1;


            if (context.read<CaveModel>().images[index] != null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    return ImagesDialog(index);
                  });
            } else if (index == 0) {
              _openImagePicker(context, index);
            } else if (index > 0 && context.read<CaveModel>().images[minusIndex] == null) {
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
            height: _buildBottomSheetHeight(context.read<CaveModel>().images[index]),
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
                            height: context.read<CaveModel>().images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Camera', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),)),),
                        InkWell(onTap: () {
                          setState(() {
                            _disableScreen = true;
                          });
                          _pickPhoto(ImageSource.gallery, index);
                        }, child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Color.fromARGB(255, 217, 211, 210)))),
                            height: context.read<CaveModel>().images[index] == null
                                ? sheetHeight * 0.425
                                : sheetHeight * 0.283,
                            child: Center(child: Text('Use Gallery', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),)),),
                        context.read<CaveModel>().images[index] == null
                            ? Container()
                            : InkWell(onTap: () {
                          setState(() {
                            context.read<CaveModel>().images[index] = null;
                            context.read<CaveModel>().temporaryPaths[index] = null;

                            int maxImageNo = context.read<CaveModel>().images.length - 1;

                            //if the last image in the list
                            if (index == maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<CaveModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }

                            //if the image one in front is not null then replace this index with it
                            int plusOne = index + 1;
                            if (context.read<CaveModel>().images[plusOne] != null) {
                              context.read<CaveModel>().images[index] = context.read<CaveModel>().images[plusOne];
                              context.read<CaveModel>().images[plusOne] = null;
                              context.read<CaveModel>().temporaryPaths[index] =
                              context.read<CaveModel>().temporaryPaths[plusOne];
                              context.read<CaveModel>().temporaryPaths[plusOne] = null;
                            }

                            //if the image two in front is not null then replace this index with it
                            int plusTwo = index + 2;
                            if (plusTwo > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<CaveModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }

                            if (context.read<CaveModel>().images[plusTwo] != null) {
                              context.read<CaveModel>().images[plusOne] = context.read<CaveModel>().images[plusTwo];
                              context.read<CaveModel>().images[plusTwo] = null;
                              context.read<CaveModel>().temporaryPaths[plusOne] =
                              context.read<CaveModel>().temporaryPaths[plusTwo];
                              context.read<CaveModel>().temporaryPaths[plusTwo] = null;
                            }

                            //if the image three in front is not null then replace this index with it
                            int plusThree = index + 3;
                            if (plusThree > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<CaveModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);
                              Navigator.pop(context);
                              return;
                            }
                            if (context.read<CaveModel>().images[plusThree] != null) {
                              context.read<CaveModel>().images[plusTwo] = context.read<CaveModel>().images[plusThree];
                              context.read<CaveModel>().images[plusThree] = null;
                              context.read<CaveModel>().temporaryPaths[plusTwo] =
                              context.read<CaveModel>().temporaryPaths[plusThree];
                              context.read<CaveModel>().temporaryPaths[plusThree] = null;
                            }

                            //if the image four in front is not null then replace this index with it
                            int plusFour = index + 4;
                            if (plusFour > maxImageNo) {
                              var encodedPaths =
                              jsonEncode(context.read<CaveModel>().temporaryPaths);
                              _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);

                              Navigator.pop(context);
                              return;
                            }

                            if (context.read<CaveModel>().images[plusFour] != null) {
                              context.read<CaveModel>().images[plusThree] = context.read<CaveModel>().images[plusFour];
                              context.read<CaveModel>().images[plusFour] = null;
                              context.read<CaveModel>().temporaryPaths[plusThree] =
                              context.read<CaveModel>().temporaryPaths[plusFour];
                              context.read<CaveModel>().temporaryPaths[plusFour] = null;
                            }

                            var encodedPaths =
                            jsonEncode(context.read<CaveModel>().temporaryPaths);
                            _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);

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
        await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : 1, Strings.imageIndex: index, Strings.formName: Strings.caveTable});
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

        context.read<CaveModel>().images[index] = null;

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

      final String dirPath = '${extDir.path}/images/${user.uid}/temporaryCaveImages';
      final String filePath = '${extDir.path}/images/${user.uid}/temporaryCaveImages/image${index.toString()}.jpg';

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


      if (context.read<CaveModel>().images[index] != null) {

        setState(() {
          context.read<CaveModel>().images[index] = changedImage;
          if (context.read<CaveModel>().temporaryPaths.length == 0) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (context.read<CaveModel>().temporaryPaths.length < index + 1) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else {
            context.read<CaveModel>().temporaryPaths[index] = path;
          }
        });
      } else {

        setState(() {
          context.read<CaveModel>().images[index] = changedImage;
          if (context.read<CaveModel>().temporaryPaths.length == 0) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (index == 0 && context.read<CaveModel>().temporaryPaths.length >= 1) {
            context.read<CaveModel>().temporaryPaths[index] = path;
          } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length < 2) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (index == 1 && context.read<CaveModel>().temporaryPaths.length >= 2) {
            context.read<CaveModel>().temporaryPaths[index] = path;
          } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length < 3) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (index == 2 && context.read<CaveModel>().temporaryPaths.length >= 3) {
            context.read<CaveModel>().temporaryPaths[index] = path;
          } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length < 4) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (index == 3 && context.read<CaveModel>().temporaryPaths.length >= 4) {
            context.read<CaveModel>().temporaryPaths[index] = path;
          } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length < 5) {
            context.read<CaveModel>().temporaryPaths.add(path);
          } else if (index == 4 && context.read<CaveModel>().temporaryPaths.length >= 5) {
            context.read<CaveModel>().temporaryPaths[index] = path;
          }
        });
      }

      var encodedPaths = jsonEncode(context.read<CaveModel>().temporaryPaths);
      _databaseHelper.updateTemporaryCaveField({Strings.images : encodedPaths}, user.uid);

    } else {
      if(Platform.isAndroid){
        await _databaseHelper.update(Strings.cameraCrashTable, {Strings.hasCrashed : 0, Strings.imageIndex: 0, Strings.formName: null});
      }
    }
    // }
    setState(() {
      _disableScreen = false;
      _pickInProgress = false;
    });
  }


  Widget _buildNameTextField() {
    return TextFormField(
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a title';
        }
        return message;
      },
      focusNode: _nameFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _nameLabelColor),
          labelText: 'Name',
          suffixIcon: _nameTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _nameTextController.clear();
                  });
                });
              })
      ),
      controller: _nameTextController,
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      maxLines: 4,
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please enter a description';
        }
        return message;
      },
      focusNode: _descriptionFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _descriptionLabelColor),
          labelText: 'Cave Description',
          suffixIcon: _descriptionTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _descriptionTextController.clear();
                  });
                });
              })
      ),
      controller: _descriptionTextController,
    );
  }

  Widget _buildCaveLatitudeTextField() {
    return IgnorePointer(child: TextFormField(
      validator: (String value) {
        String message;
        if (value.trim().length <= 0 && value.isEmpty) {
          message = 'Please provide a cave latitude';
        }
        return message;
      },
      enabled: true,
      decoration: InputDecoration(
        labelText: 'Cave Latitude',
      ),
      controller: _caveLatitudeTextController,
    ),);
  }

  Widget _buildCaveLongitudeTextField() {
    return IgnorePointer(
      child: TextFormField(
        validator: (String value) {
          String message;
          if (value.trim().length <= 0 && value.isEmpty) {
            message = 'Please provide a cave longitude';
          }
          return message;
        },
        enabled: true,
        decoration: InputDecoration(
          labelText: 'Cave Longitude',
        ),
        controller: _caveLongitudeTextController,
      ),
    );
  }

  Widget _buildParkingLatitudeTextField() {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        labelText: 'Parking Latitude',
      ),
      controller: _parkingLatitudeTextController,
    );
  }

  Widget _buildParkingLongitudeTextField() {
    return TextFormField(
      enabled: false,
      decoration: InputDecoration(
        labelText: 'Parking Longitude',
      ),
      controller: _parkingLongitudeTextController,
    );
  }

  Widget _buildParkingPostCodeTextField() {
    return TextFormField(
      focusNode: _parkingPostCodeFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _parkingPostCodeLabelColor),
          labelText: 'Parking Post Code',
          suffixIcon: _parkingPostCodeTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _parkingPostCodeTextController.clear();
                  });
                });
              })
      ),
      controller: _parkingPostCodeTextController,
    );
  }

  Widget _buildVerticalRangeTextField() {
    return TextFormField(
      focusNode: _verticalRangeFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _verticalRangeLabelColor),
          labelText: 'Vertical Range (m)',
          suffixIcon: _verticalRangeTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _verticalRangeTextController.clear();
                  });
                });
              })
      ),
      controller: _verticalRangeTextController,
    );
  }

  Widget _buildLengthTextField() {
    return TextFormField(
      focusNode: _lengthFocusNode,
      decoration: InputDecoration(
          labelStyle: TextStyle(color: _lengthLabelColor),
          labelText: 'Length (km)',
          suffixIcon: _lengthTextController.text == ''
              ? null
              : IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    FocusScope.of(context).unfocus();
                    _lengthTextController.clear();
                  });
                });
              })
      ),
      controller: _lengthTextController,
    );
  }

  Widget _buildCountyDrop() {
    return DropdownFormField(
      expanded: true,
      hint: 'County',
      value: county,
      items: countyDrop.toList(),
      onChanged: (val) => setState(() {
        county = val;
        _databaseHelper.updateTemporaryCaveField(
            {Strings.county : val}, user.uid);
        FocusScope.of(context).unfocus();
      }),
      initialValue: county,
    );
  }

  void _resetCave() {
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
              child: Center(child: Text("Reset Cave", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
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
                        _nameTextController.clear();
                        _descriptionTextController.clear();
                        _caveLatitudeTextController.clear();
                        _caveLongitudeTextController.clear();
                        _parkingLatitudeTextController.clear();
                        _parkingLongitudeTextController.clear();
                        _parkingPostCodeTextController.clear();
                        _verticalRangeTextController.clear();
                        _lengthTextController.clear();
                        county = 'Select One';
                        context.read<CaveModel>().resetImages();
                      });
                      _databaseHelper.resetTemporaryCave(user.uid);
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
            child: StyledBlueButton(widget.edit ? 'Edit' : 'Submit', _submitForm, _disableScreen)));
  }

  Widget _buildCaveLocationRowButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StyledBlueButton('Current Location', _getCurrentLocation)),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StyledBlueButton('Use Map', () => _openMap(true)))

        ]);
  }

  Widget _buildParkingLocationRowButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StyledBlueButton('Current Location', () => _getCurrentLocation(false))),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05,
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StyledBlueButton('Use Map', () => _openMap(false)))

        ]);
  }

  _openMap(bool cave) {

    if(cave){
    Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSelect(updateLocation, _caveLatitudeTextController.text, _caveLongitudeTextController.text, true)));
  } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSelect(updateLocation, _parkingLatitudeTextController.text, _parkingLongitudeTextController.text, false)));

    }
  }


  void updateLocation(String lat, String long, bool cave){



    if(cave){
      _caveLatitudeTextController.text = lat;
      _caveLongitudeTextController.text = long;
    } else {
      _parkingLatitudeTextController.text = lat;
      _parkingLongitudeTextController.text = long;
    }
  }

  void _getCurrentLocation([bool cave = true]) async {

    bool updateLocation = false;

    try {
      Location location = new Location();

      LocationData currentLocation = await location.getLocation();


      print(currentLocation.latitude);
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) updateLocation = true;


      if (updateLocation) {

        String lat = (currentLocation.latitude).toString();
        String long = (currentLocation.longitude).toString();

        if(cave){
          setState(() {
            _caveLatitudeTextController.text = lat;
            _caveLongitudeTextController.text = long;
          });
        } else {
          setState(() {
            _parkingLatitudeTextController.text = lat;
            _parkingLongitudeTextController.text = long;
          });
        }

      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        GlobalFunctions.showToast(
            'Unable to get location, please accept these permissions');
      }
    }


  }

  void _submitForm() async {

    if (_formKey.currentState.validate()) {

      bool success;
      Map<String, dynamic> caveData = {
        Strings.name: _nameTextController.text,
        Strings.description: _descriptionTextController.text,
        Strings.caveLatitude: _caveLatitudeTextController.text,
        Strings.caveLongitude: _caveLongitudeTextController.text,
        Strings.parkingLatitude: _parkingLatitudeTextController.text,
        Strings.parkingLongitude: _parkingLongitudeTextController.text,
        Strings.parkingPostCode: _parkingPostCodeTextController.text,
        Strings.verticalRange: _verticalRangeTextController.text,
        Strings.county: county,
        Strings.length: _lengthTextController.text,
      };

      if(widget.edit) {
        success = await context.read<CaveModel>().submitCave(caveData, true);

      } else {
        success = await context.read<CaveModel>().submitCave(caveData);

      }

      if(success){
        setState(() {
          _nameTextController.clear();
          _descriptionTextController.clear();
          _caveLatitudeTextController.clear();
          _caveLongitudeTextController.clear();
          _parkingLatitudeTextController.clear();
          _parkingLongitudeTextController.clear();
          _parkingPostCodeTextController.clear();
          _verticalRangeTextController.clear();
          _lengthTextController.clear();
          county = 'Select One';
          context.read<CaveModel>().resetImages();
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
                  _buildNameTextField(),
                  _buildLengthTextField(),
                  _buildVerticalRangeTextField(),
                  _buildCountyDrop(),
                  _buildDescriptionTextField(),
                  _buildCaveLatitudeTextField(),
                  _buildCaveLongitudeTextField(),
                  SizedBox(height: 10,),
                  _buildCaveLocationRowButton(),
                  _buildParkingLatitudeTextField(),
                  _buildParkingLongitudeTextField(),
                  SizedBox(height: 10,),
                  _buildParkingLocationRowButton(),
                  SizedBox(height: 10,),
                  _buildParkingPostCodeTextField(),
                  SizedBox(height: 20.0,),
//                  widget.edit ? Container() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//                    Text('Images', style: TextStyle(fontWeight: FontWeight.bold),),
//                    SizedBox(height: 10,),
//                    Consumer<CaveModel>(
//                        builder: (context,  model, child) {
//                          return LayoutBuilder(builder:
//                              (BuildContext context, BoxConstraints constraints) {
//                            return Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: _buildGridTiles(constraints, context.read<CaveModel>().images.length),
//                            );
//                          });}),
//                    SizedBox(
//                      height: 10.0,
//                    ),
//                  ],),
                  _buildSubmitButton(),
                  SizedBox(height: 20.0,),
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
            child: Text('Add Cave', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
        actions: <Widget>[widget.edit ? Container() : IconButton(icon: Icon(Icons.refresh), onPressed: _resetCave)],),
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
    currentImage = context.read<CaveModel>().images[imageIndex];
    imagesLength = _getImagesLength();
    // TODO: implement initState
    super.initState();
  }

  int _getImagesLength(){

    int count = 0;

    for(File image in context.read<CaveModel>().images){
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
            currentImage = context.read<CaveModel>().images[imageIndex];
          });
        }, color: darkBlue,),margin: EdgeInsets.only(left: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),),
      imageIndex == (imagesLength -1) ? Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(child: IconButton(icon: Icon(Icons.arrow_forward),
        onPressed: (){
          imageIndex ++;
          setState(() {
            currentImage = context.read<CaveModel>().images[imageIndex];
          });
        }, color: darkBlue,),margin: EdgeInsets.only(right: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),)

    ],));
  }
}


class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
