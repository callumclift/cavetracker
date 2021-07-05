import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/side_drawer.dart';
import '../../models/activity_log_model.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import 'completed_activity_log.dart';
import 'package:provider/provider.dart';

class CompletedActivityLogsListPage extends StatefulWidget {


  CompletedActivityLogsListPage();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CompletedActivityLogsListPageState();
  }
}

class _CompletedActivityLogsListPageState extends State<CompletedActivityLogsListPage> {

  bool _loadingMore = false;

  @override
  initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ActivityLogModel>().getActivityLogs();
    });
  }



  void _viewActivityLog(int index){
    context.read<ActivityLogModel>().selectActivityLog(context.read<ActivityLogModel>().allActivityLogs[index]['document_id']);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedActivityLogPage();
    })).then((_) {
      context.read<ActivityLogModel>().selectActivityLog(null);
    });
  }

  void loadMore() async {
    setState(() {
      _loadingMore = true;

    });
    await context.read<ActivityLogModel>().getMoreActivityLogs();
    setState(() {
      _loadingMore = false;
    });
  }

  Widget _buildListTile(int index, List<Map<String, dynamic>> activityLogs) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
    Widget returnedWidget;

    if (activityLogs.length >= 10 && index == activityLogs.length) {
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
          InkWell(onTap: () => _viewActivityLog(index),
            child: ListTile(
              leading: Image.asset('assets/icons/activityLogIcon.png', height: 25,),
              title: GlobalFunctions.boldTitleText('Title: ', activityLogs[index]['title'], context),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                GlobalFunctions.boldTitleText('Cave: ', activityLogs[index]['cave_name'], context),
                GlobalFunctions.boldTitleText('Date: ', dateFormat.format(
                    DateTime.parse(activityLogs[index]['timestamp'])), context),
              ],),
            ),),
          Divider(),
        ],
      );
    }
    return returnedWidget;

  }

  Widget _buildPageContent(List<Map<String, dynamic>> activityLogs) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    if (context.read<ActivityLogModel>().isLoading) {
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
    } else if (activityLogs.length == 0) {
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
          onRefresh: () => context.read<ActivityLogModel>().getActivityLogs());
    } else {
      return RefreshIndicator(
        color: darkBlue,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _buildListTile(index, activityLogs);
          },
          itemCount: activityLogs.length >= 10 ? activityLogs.length + 1 : activityLogs.length,
        ),
        onRefresh: () => context.read<ActivityLogModel>().getActivityLogs(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ActivityLogModel>(
      builder: (context, model, child) {
        List<Map<String, dynamic>> activityLogs = model.allActivityLogs;
        return Scaffold(
            appBar: AppBar(iconTheme: IconThemeData(color: darkBlue),
              backgroundColor: mintGreen,
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('My Activity Logs', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),),
            drawer: SideDrawer(),
            body: _buildPageContent(activityLogs));
      },
    );
  }
}
