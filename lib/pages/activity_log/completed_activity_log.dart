import 'package:caving_app/models/activity_log_model.dart';
import 'package:caving_app/pages/activity_log/activity_log_page.dart';
import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../utils/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../shared/strings.dart';




class CompletedActivityLogPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedActivityLogPageState();
  }
}

class _CompletedActivityLogPageState
    extends State<CompletedActivityLogPage> {

  bool loading = false;
  bool hasImages = false;
  String imageMessage = 'No images attached to this log';
  final dateFormat = DateFormat("dd/MM/yyyy");
  DateTime date;


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {

    super.initState();
    getImages();
  }

  Widget _buildShareButton(BuildContext context) {

    String edit = 'Edit';

    final List<String> _shareOptions = [edit];


    return PopupMenuButton(
        onSelected: (String value) async{


          if(value == edit){

            Navigator.of(context).push(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ActivityLogPage(true);
                }));
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (BuildContext context) {
          return _shareOptions.map((String option) {

            return PopupMenuItem<String>(value: option, child: Row(children: <Widget>[

              Expanded(child: Text(option, style: TextStyle(fontWeight: FontWeight.bold),),),
              Icon(Icons.edit, color: darkBlue,),
            ],));

          }).toList();
        });
  }

  getImages() async{

    if(mounted){
      setState(() {
        loading = true;
      });
    }


    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/images${user.uid}/activityLogs/${context.read<ActivityLogModel>().selectedActivityLog[Strings.documentId]}';


    if(context.read<ActivityLogModel>().selectedActivityLog[Strings.images] != null) {
      List<String> imageUrls = [];
      List<String> imageFilePaths = [];

      //check if there is already images so that you do not have to do all this again!!
      if (context.read<ActivityLogModel>()
          .selectedActivityLog[Strings.imageFiles] != null) {
        if(mounted){
          setState(() {
            hasImages = true;
            loading = false;
          });
        }
      } else if (Directory(dirPath).existsSync()){

        dynamic itemsDynamic = await compute(jsonDecode, context.read<ActivityLogModel>().selectedActivityLog[Strings.images].toString());
        imageUrls = List.from(itemsDynamic);
        int localImageCount = imageUrls.length;



        if(localImageCount > 0) {
          int index = 1;

          for (String url in imageUrls) {
            final file = new File('$dirPath/image-${index.toString()}.jpg');
            imageFilePaths.add(file.path);
            index ++;
          }
        }

        if(imageFilePaths.length > 0){
          context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles] = imageFilePaths;
          if(mounted){
            setState(() {
              hasImages = true;
            });
          }
        }

        if(mounted){
          setState(() {
            loading = false;
          });
        }

      } else {

        var connectivityResult = await (new Connectivity().checkConnectivity());

        if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] != null){

          if(mounted){
            setState(() {
              hasImages = true;
            });
          }

          if(mounted){
            setState(() {
              loading = false;
            });
          }


        } else {
          if (connectivityResult != ConnectivityResult.none) {
            dynamic itemsDynamic = await compute(jsonDecode,
                context.read<ActivityLogModel>().selectedActivityLog[Strings
                    .images].toString());
            imageUrls = List.from(itemsDynamic);

            if (imageUrls.length > 0) {

              if (!Directory(dirPath).existsSync()) {
                new Directory(dirPath).createSync(recursive: true);
              }

              http.Client client = new http.Client();
              int index = 1;

              for (String url in imageUrls) {
                var req = await client.get(Uri.parse(url));
                var bytes = req.bodyBytes;
                final file = new File('$dirPath/image-${index.toString()}.jpg');
                file.writeAsBytesSync(bytes);
                //add actual image files now to the form object????
                imageFilePaths.add(file.path);
                index ++;
              }

              if (imageFilePaths.length > 0) {
                context.read<ActivityLogModel>()
                    .selectedActivityLog[Strings.imageFiles] =
                    imageFilePaths;
                if(mounted){
                  setState(() {
                    hasImages = true;
                  });
                }
              }
              setState(() {
                loading = false;
              });
            } else {
              if(mounted){
                setState(() {
                  loading = false;
                });
              }
            }
          } else {
            GlobalFunctions.showToast('No Data connection to fetch images');
            if(mounted){
              setState(() {
                loading = false;
                imageMessage = 'No data connection to fetch images';
              });
            }
          }
        }

      }
    } else {

      if(mounted){
        setState(() {
          loading = false;
        });
      }

    }
  }

  Widget _buildImagesSection(){

    Widget returnedWidget;

    if(!hasImages){
      returnedWidget = Text(imageMessage);
    } else {
      //returnedWidget = Image.file(File(context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles][1]));
      returnedWidget = LayoutBuilder(builder:
          (BuildContext context, BoxConstraints constraints) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildGridTiles(constraints, context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null ?
            context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles].length : context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages].length)
        );
      });
    }

    return returnedWidget;

  }



  List<Widget> _buildGridTiles(BoxConstraints constraints, int numOfTiles) {
    List<Container> containers =
    List<Container>.generate(numOfTiles, (int index) {
      return Container(
        padding: EdgeInsets.all(2.0),
        width: constraints.maxWidth / 5,
        height: constraints.maxWidth / 5,
        child: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ImagesDialog(index);
                });
          },
          child: gridColor(context, index),
        ),
      );
    });
    return containers;
  }

  Widget gridColor(BuildContext context, int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null ? Image.file(
          File(context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles][index]),
          fit: BoxFit.cover,
        ) : Image.memory(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages][index], fit: BoxFit.cover,),
      ),
    );

  }

  Widget _buildDateField() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: IgnorePointer(
                child: InputDecorator(
                  decoration: InputDecoration(labelText: 'Date:'),
                  child: Text(dateFormat.format(
                      DateTime.parse(context.read<ActivityLogModel>().selectedActivityLog[Strings.date])), style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
            IconButton(
                icon: Icon(Icons.access_time),
                onPressed: null)
          ],
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return InputDecorator(decoration: InputDecoration(labelText: 'Title'),
      child: Text(context.read<ActivityLogModel>().selectedActivityLog[Strings.title], style: TextStyle(fontSize: 16),),
    );
  }

  Widget _buildCaveField() {
    return InputDecorator(decoration: InputDecoration(labelText: 'Cave'),
      child: Text(context.read<ActivityLogModel>().selectedActivityLog[Strings.caveName], style: TextStyle(fontSize: 16),),
    );
  }

  Widget _buildDetailsField() {
    return InputDecorator(decoration: InputDecoration(labelText: 'Details'),
      child: Text(context.read<ActivityLogModel>().selectedActivityLog[Strings.details], style: TextStyle(fontSize: 16),),
    );
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
                  _buildTitleField(),
                  _buildCaveField(),
                  _buildDetailsField(),
                  SizedBox(height: 20.0,),
                  Text('Images', style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 10,),
                  loading ? Column(children: <Widget>[
                    SizedBox(height: 10,),
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text('Loading images...'),
                    SizedBox(height: 10,),
                  ],) : _buildImagesSection(),
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
    return Scaffold(
      appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
        title: FittedBox(fit:BoxFit.fitWidth,
            child: Text('Activity Log', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
        actions: <Widget>[
          //_buildShareButton(context)
        ],),
      body: _buildPageContent(context),
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
  Uint8List currentLocalImage;
  int imagesLength;
  int imageIndex;

  @override
  void initState() {
    imageIndex = widget.currentIndex;
    if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null) currentImage = File(context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles][imageIndex]);
    if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] != null) currentLocalImage = context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages][imageIndex];
    imagesLength = context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null ? context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles].length :
    context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages].length ;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: Stack(children: <Widget>[
      PinchZoomImage(
        image: context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null ? Image.file(currentImage) : Image.memory(currentLocalImage),
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
            if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null) currentImage = File(context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles][imageIndex]);
            if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] != null) currentLocalImage = currentLocalImage = context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages][imageIndex];
          });
        }, color: darkBlue,),margin: EdgeInsets.only(left: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),),
      imageIndex == (imagesLength -1) ? Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(),)) :
      Positioned.fill(child: Align(alignment: Alignment.centerRight ,child: Container(child: IconButton(icon: Icon(Icons.arrow_forward),
        onPressed: (){
          imageIndex ++;
          setState(() {
            if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] == null) currentImage = File(context.read<ActivityLogModel>().selectedActivityLog[Strings.imageFiles][imageIndex]);
            if(context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages] != null) currentLocalImage = currentLocalImage = context.read<ActivityLogModel>().selectedActivityLog[Strings.localImages][imageIndex];

          });
        }, color: darkBlue,),margin: EdgeInsets.only(right: 5),decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white70),width: 40, height: 40,)),)

    ],),);
  }
}
