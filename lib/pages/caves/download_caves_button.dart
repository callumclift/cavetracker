import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/shared/global_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class DownloadCavesButton extends StatelessWidget {

  final Function getCaves;

  DownloadCavesButton(this.getCaves);

  @override
  Widget build(BuildContext context) {
    return IconButton(color: darkBlue, icon: Icon(Icons.cloud_download), onPressed: () => showDialog(
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
                      await getCaves();
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
        }));
  }
}







