import 'dart:convert';
import 'package:caving_app/constants/route_paths.dart';
import 'package:caving_app/models/authentication_model.dart';
import 'package:caving_app/models/club_model.dart';
import 'package:caving_app/pages/clubhub/announcements_list.dart';
import 'package:caving_app/pages/clubhub/clubs_list.dart';
import 'package:caving_app/pages/clubhub/create_announcement.dart';
import 'package:caving_app/pages/clubhub/leave_club.dart';
import 'package:caving_app/widgets/side_drawer.dart';
import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/global_config.dart';
import '../../shared/global_functions.dart';
import '../../utils/database_helper.dart';
import 'package:provider/provider.dart';
import '../../shared/strings.dart';
import '../../models/call_out_model.dart';
import 'package:share/share.dart';

import 'create_club.dart';




class Clubhub extends StatefulWidget {

  final bool edit;

  Clubhub([this.edit = false]);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ClubhubState();
  }
}

class _ClubhubState
    extends State<Clubhub> {

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
  List<Map<String, dynamic>> clubMembers = [];
  List<Map<String, dynamic>> memberRequests = [];


  @override
  initState() {
    super.initState();
    _loadingTemporary = true;
    _setupFocusNodes();
    _setupTextControllerListeners();
    _getTemporaryCallOut();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getData();
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

  _getData() async{

    if(user.clubId != ''){
      await context.read<ClubModel>().getAnnouncements();
      clubMembers = await context.read<ClubModel>().getClubMembers();
      memberRequests = await context.read<ClubModel>().getMemberRequests();
    }
    setState(() {
      _loadingTemporary = false;
    });
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

        if (mounted) {
          setState(() {
            //_loadingTemporary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            //_loadingTemporary = false;
          });
        }
      }
    }
  }


  _joinClub() async{

    List<Map<String, dynamic>> clubs = [];

    bool hasConnection = await GlobalFunctions.hasDataConnection();

    if(hasConnection){
      GlobalFunctions.showLoadingDialog('Loading Clubs...');
      clubs = await context.read<ClubModel>().getClubs();
      GlobalFunctions.dismissLoadingDialog();
      if(clubs.length < 1){
        GlobalFunctions.showToast('No clubs found');
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ClubsListPage(clubs)));
      }

    } else {
      GlobalFunctions.showToast('No data connection, unable to search for clubs');
    }



  }


  _viewAllAnnouncements(){
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CompletedAnnouncementsListPage();
    }));
  }



  updateCavers(List<Map<String, dynamic>> updatedList){
    cavers = updatedList;

    if(!widget.edit) _databaseHelper.updateTemporaryCallOutField({
      Strings.cavers: jsonEncode(cavers)
    }, user.uid);
  }

  Widget _buildListTile(int index) {

    Widget returnedWidget;

    if(clubMembers.length < 1) {
      returnedWidget = Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Center(child: Text('No Club Members found'),),
        SizedBox(height: 10,)
      ],);
    } else {
      returnedWidget = Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.person,
              color: darkBlue,
              size: 30.0,
            ),
            trailing: user.clubRole == 'Admin' ? _buildIconButton(clubMembers[index]) : null,
            title: Text(clubMembers[index]['username']),
          ),
          Divider(),
        ],
      );
    }

    return returnedWidget;
  }

  Widget _buildListTileRequests(int index) {

    Widget returnedWidget;

    if(memberRequests.length < 1) {
      returnedWidget = Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        SizedBox(height: 10,),
        Center(child: Text('No current requests'),),
        SizedBox(height: 10,)
      ],);
    } else {
      returnedWidget = Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.person,
              color: darkBlue,
              size: 30.0,
            ),
            trailing: _buildIconButtonRequests(memberRequests[index]),
            title: Text(memberRequests[index]['name']),
          ),
          Divider(),
        ],
      );
    }

    return returnedWidget;
  }

  Widget _buildIconButton(Map<String, dynamic> selectedClubMember){

    Widget returnedWidget;

    if(selectedClubMember['uid'] == user.uid){
      returnedWidget = null;
    } else {
      returnedWidget = IconButton(icon: Icon(Icons.remove, color: darkBlue,), onPressed: () async{
        try{

          bool success = await context.read<ClubModel>().removeClubMember(selectedClubMember['uid']);

          if(success){
            setState(() {
              clubMembers.removeWhere((clubMember) => clubMember['uid'] == selectedClubMember['uid']);
        });
          }
        } catch (e){
          print(e);
        }
      });
    }

    return returnedWidget;
  }

  Widget _buildIconButtonRequests(Map<String, dynamic> selectedMemberRequest){

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(Icons.done, color: darkBlue,), onPressed: () async{
          Map<String, dynamic> returnedInfo = await context.read<ClubModel>().acceptMemberRequest(selectedMemberRequest['uid'], memberRequests);
          if(returnedInfo['success'] == true){
            setState(() {
              memberRequests = returnedInfo['member_requests'];
              clubMembers.add({'username': selectedMemberRequest['name'], 'uid': selectedMemberRequest['uid']});
            });

          }
        }),
        SizedBox(
          width: 10,
        ),
        IconButton(icon: Icon(Icons.clear, color: darkBlue,), onPressed: () async{
          memberRequests = await context.read<ClubModel>().rejectMemberRequest(selectedMemberRequest['uid'], memberRequests);
          setState(() {
            memberRequests = memberRequests;
          });
        }),

      ],
    );
  }

  _createAnnouncement(){

    showGeneralDialog(barrierDismissible: false,
        context: context,
        pageBuilder: (BuildContext context, Animation animation, Animation secondAnimation) {
          return CreateAnnouncement();
        });

  }

  _createClub(){
    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CreateClub();
        });
  }

  Column _buildLatestAnnouncement(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Text(context.read<ClubModel>().allAnnouncements[0]['body']),)
          ],
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(dateFormat.format(
                DateTime.parse(context.read<ClubModel>().allAnnouncements[0]['timestamp'])))
          ],
        )
      ],
    );
  }

  Widget _buildClubMemberRequests(){

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Text('Member Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkBlue),)
        ],),
        SizedBox(
          height: 10,
        ),
        ListView.builder(shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: memberRequests.length < 1 ? 1 : memberRequests.length,
          itemBuilder: (BuildContext context, int index) {
            print(memberRequests.length);
            return _buildListTileRequests(index);
          },),
      ],
    );
  }


  _leaveClub(){

    showGeneralDialog(barrierDismissible: false,
        context: context,
        pageBuilder: (BuildContext context, Animation animation, Animation secondAnimation) {
          return LeaveClub();
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
                  Text('Latest Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkBlue),),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: darkBlue)
                    ),
                    child: Consumer<ClubModel>(
                        builder: (context, clubModel, child) => clubModel.allAnnouncements.length >0 ? _buildLatestAnnouncement() : Text("No announcement found, please add your first announcement using the create button")),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Consumer<AuthenticationModel>(
                          builder: (context, authenticationModel, child) => user != null && user.clubRole == 'Admin' ? StyledBlueButton('Create', _createAnnouncement) : Container()),
                    SizedBox(width: 5,),
                    StyledBlueButton('View All', _viewAllAnnouncements),
                  ],),
                  SizedBox(
                    height: 10,
                  ),
                  user.clubRole == 'Admin' ? _buildClubMemberRequests() : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Club Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkBlue),),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: clubMembers.length < 1 ? 1 : clubMembers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildListTile(index);
                    },),
                  SizedBox(height: 10,),
                  Text('Leave Club', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkBlue),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      StyledBlueButton('Leave', _leaveClub),
                    ],),

                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContentNoClub(BuildContext context) {
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
                  Text('Latest Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: darkBlue),),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: darkBlue)
                    ),
                    child: Text("Welcome to cavetrackers clubhub! \n \nHere is where you will find all of your clubs latest announcements, why not search for a club to join or create your own club and "
                        "invite your friends & family to join!\n\ncavetracker can still be enjoyed solo, you'll still be able to add & view caves as well as record your own activity logs & create call outs! \n\nWe hope you enjoy using this app!"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                    StyledBlueButton('Join a Club', _joinClub),
                    SizedBox(width: 10,),
                    StyledBlueButton('Create a Club', _createClub),
                  ],),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _choosePageContent(){
    Widget returnedWidget;

    if(user == null){
      returnedWidget = Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
        ),
      );
    } else if(user.clubId == ''){

      returnedWidget = _buildPageContentNoClub(context);
    } else {
      returnedWidget = _buildPageContent(context);
    }




    return returnedWidget;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(drawer: SideDrawer(),
      appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {

            return Image.asset(
              'assets/images/clubhub.png', height: AppBar().preferredSize.height * 0.9);
          },
        ),       ),
      body: _loadingTemporary
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
        ),
      )
          : Consumer<AuthenticationModel>(
        builder: (context, authenticationModel, child) => _choosePageContent(),
      ),
    );
  }
}







class JoinClub extends StatefulWidget {

  final List<Map<String, dynamic>> clubs;

  JoinClub(this.clubs);

  @override
  _JoinClubState createState() => _JoinClubState();
}

class _JoinClubState extends State<JoinClub> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _applyToJoin(Map<String, dynamic> club) async{
      await context.read<ClubModel>().joinClub(club['document_id']);

  }

  _cancelJoin(Map<String, dynamic> club) async{
      await context.read<ClubModel>().cancelRequest(club['document_id']);
  }


  Widget _buildJoinButton(int index) {

    Widget returnedWidget;

    if(user.requestedClubId == widget.clubs[index]['document_id']){
       returnedWidget = StyledBlueButton('Cancel', () => _cancelJoin(widget.clubs[index]));
    } else if (user.requestedClubId == null || user.requestedClubId == ''){
      returnedWidget = StyledBlueButton('Join', () => _applyToJoin(widget.clubs[index]));
    } else if(user.requestedClubId != '' && user.requestedClubId != widget.clubs[index]['document_id']){
      returnedWidget = RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: Colors.grey,
        textColor: whiteGreen,
        child: Text('Join', style: TextStyle(fontWeight: FontWeight.bold),),
        onPressed: () => null,
      );
    }
    return returnedWidget;
  }


  Widget _buildListTile(int index) {

    return Column(
      children: <Widget>[
        ExpansionTile(childrenPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(widget.clubs[index]['name']),
          children: [
            SizedBox(
              height: 100,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(widget.clubs[index]['description'])
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
    Consumer<AuthenticationModel>(
    builder: (context, authenticationModel, child) =>_buildJoinButton(index))
              ],
            )
          ],
        ),
        Divider(),
      ],
    );
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
        child: Center(child: Text("Join Club", style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),),),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please select a club you would like to join, your request will need to be approved by an admin of that club.'),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return _buildListTile(index);
              },
              itemCount: widget.clubs.length,
            )
          ],
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
            'Close',
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}



