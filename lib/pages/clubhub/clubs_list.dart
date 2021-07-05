import 'package:caving_app/models/authentication_model.dart';
import 'package:caving_app/models/club_model.dart';
import 'package:caving_app/widgets/styled_blue_button.dart';
import 'package:flutter/material.dart';
import '../../shared/global_config.dart';
import 'package:provider/provider.dart';

class ClubsListPage extends StatefulWidget {

  final List<Map<String, dynamic>> clubs;

  ClubsListPage(this.clubs);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ClubsListPageState();
  }
}

class _ClubsListPageState extends State<ClubsListPage> {

  @override
  initState() {

    super.initState();
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
                    Expanded(child: Text(widget.clubs[index]['name'], style: TextStyle(fontWeight: FontWeight.bold),),)
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.clubs[index]['description'])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<AuthenticationModel>(
                        builder: (context, authenticationModel, child) =>_buildJoinButton(index))
                  ],
                ),
              ],
            ),
          ),
          Divider(),
        ],
      );
  }

  Widget _buildPageContent() {

      return Column(
        children: [
          Container(
            margin: EdgeInsets.all(5),
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: new Text('Please select a club you would like to join, your request will need to be approved by an admin of that club.'))
                ],
              )),
          Expanded(child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _buildListTile(index);
            },
            itemCount: widget.clubs.length,
          ))
        ],
      );



  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ClubModel>(
      builder: (context, model, child) {
        return Scaffold(
            appBar: AppBar(iconTheme: IconThemeData(color: darkBlue),
              backgroundColor: mintGreen,
              title: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('Clubs', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),)),),
            body: _buildPageContent());
      },
    );
  }
}
