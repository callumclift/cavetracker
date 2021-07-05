import 'package:caving_app/models/club_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/side_drawer.dart';
import '../../models/activity_log_model.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'package:provider/provider.dart';

class CompletedAnnouncementsListPage extends StatefulWidget {


  CompletedAnnouncementsListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedAnnouncementsListPageState();
  }
}

class _CompletedAnnouncementsListPageState extends State<CompletedAnnouncementsListPage> {

  bool _loadingMore = false;

  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ClubModel>().getAnnouncements();
    });
  }



  void _viewAnnouncement(int index){

    //delete announcement

//    context.read<ClubModel>().selectAnnouncement(context.read<ClubModel>().allAnnouncements[index]['document_id']);
//    Navigator.of(context)
//        .push(MaterialPageRoute(builder: (BuildContext context) {
//      return CompletedAnnouncementPage();
//    })).then((_) {
//      context.read<ClubModel>().selectAnnouncement(null);
//    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> announcements) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (announcements.length >= 10 && index == announcements.length) {
      if (_loadingMore) {
        returnedWidget = Center(child: Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              darkBlue),
        ),),);
      } else {
        returnedWidget = Container(
          child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: RaisedButton(color: greyDesign1,
            child: Text("Load More", style: TextStyle(color: darkBlue),),
            onPressed: () async {
              setState(() {
                _loadingMore = true;

              });
              await context.read<ClubModel>().getMoreAnnouncements();
              setState(() {
                _loadingMore = false;
              });
            },
          ),),),
        );
      }
    } else {
      returnedWidget = Column(
        children: <Widget>[


          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: darkBlue)
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: Text(announcements[index]['body']),)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(dateFormat.format(
                        DateTime.parse(announcements[index]['timestamp'])))
                  ],
                )
              ],
            ),
          ),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> announcements) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    if (context.read<ClubModel>().isLoading) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      darkBlue),
                ),
                SizedBox(height: 20.0),
                Text('Fetching Activity Logs')
              ]));
    } else if (announcements.length == 0) {
      return RefreshIndicator(
          color: darkBlue,
          child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
            Container(
                height: deviceHeight * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'No Activity Logs available pull down to refesh',
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
          onRefresh: () => context.read<ClubModel>().getAnnouncements());
    } else {
      return RefreshIndicator(
        color: darkBlue,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, announcements);
          },
          itemCount: announcements.length >= 10 ? announcements.length + 1 : announcements.length,
        ),
        onRefresh: () => context.read<ClubModel>().getAnnouncements(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ClubModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> announcements = model.allAnnouncements;
        return Scaffold(
            appBar: AppBar(iconTheme: IconThemeData(color: darkBlue),
              backgroundColor: mintGreen,
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Announcements', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),),
            body: _buildPageContent(announcements));
      },
    );
  }
}
