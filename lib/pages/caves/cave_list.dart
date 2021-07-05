import 'package:caving_app/shared/strings.dart';
import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/side_drawer.dart';
import '../../models/cave_model.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'cave.dart';
import 'package:provider/provider.dart';

class CaveListPage extends StatefulWidget {


  CaveListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CaveListPageState();
  }
}

class _CaveListPageState extends State<CaveListPage> {

  bool _loadingMore = false;

  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<CaveModel>().getCaves();
    });
  }



  void _viewCave(int index){
    context.read<CaveModel>().selectCave(context.read<CaveModel>().allCaves[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CavePage();
    })).then((_) {
      context.read<CaveModel>().selectCave(null);
    });
  }

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await context.read<CaveModel>().getMoreCaves();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> caves) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (caves.length >= 10 && index == caves.length) {
      if (_loadingMore) {
        returnedWidget = Center(child: Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              darkBlue),
        ),),);
      } else {
        returnedWidget = Container(
          child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: StyledBlueButton('Load More', loadMore),),),
        );
      }
    } else {
      returnedWidget = Column(
        children: <Widget>[
          InkWell(onTap: () => _viewCave(index),
            child: ListTile(
              leading: Image.asset('assets/icons/caveIcon.png', height: 25,),
              title: Text(caves[index][Strings.name], style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('County: ', caves[index][Strings.county], context),
                GlobalFunctions.boldTitleText('Length (km): ', caves[index][Strings.length], context),
                GlobalFunctions.boldTitleText('Vertical Range (m): ', caves[index][Strings.verticalRange], context),
              ],),
            ),),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> caves) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    if (context.read<CaveModel>().isLoading) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      darkBlue),
                ),
                SizedBox(height: 20.0),
                Text('Fetching Caves')
              ]));
    } else if (caves.length == 0) {
      return RefreshIndicator(
          color: darkBlue,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Caves available pull down to refesh',
                      textAlign: TextAlign.center,
                    ),
                    Icon(
                      Icons.warning,
                      size: 40.0,
                      color: darkBlue,
                    )
                  ],
                ))
          ]),
          onRefresh: () => context.read<CaveModel>().getCaves());
    } else {
      return RefreshIndicator(
        color: darkBlue,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, caves);
          },
          itemCount: caves.length >= 10 ? caves.length + 1 : caves.length,
        ),
        onRefresh: () => context.read<CaveModel>().getCaves(),
      );
    }
  }

  void _downloadCaves() {
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
              child: Center(child: Text("Download All Caves", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
            ),
            content: Text('Are you sure you wish to download all caves to your device?'),
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
                    onPressed: () async {

                      await context.read<CaveModel>().downloadAllCaves();
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<CaveModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> caves = model.allCaves;
        return Scaffold(
            appBar: AppBar(iconTheme: IconThemeData(color: darkBlue),
              backgroundColor: mintGreen,
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Caves', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),
            actions: [
              IconButton(icon: Icon(Icons.cloud_download), onPressed: _downloadCaves)
            ],),
            drawer: SideDrawer(),
            body: _buildPageContent(caves));
      },
    );
  }
}
