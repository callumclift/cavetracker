import 'package:flutter/material.dart';
import '../../models/authentication_model.dart';
import 'package:provider/provider.dart';
import '../../widgets/side_drawer.dart';
import '../../shared/global_config.dart';

class HomePage extends StatelessWidget {
  final String argument;

  const HomePage({this.argument});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteGreen,
      appBar: AppBar(
        backgroundColor: mintGreen,
      ),
      drawer: SideDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login $argument'),
            Text('JOB APPPPPSSS $argument'),
            RaisedButton(
              onPressed: () => context.read<AuthenticationModel>().logout()
            )
          ],
        ),
      ),
    );
  }
}

