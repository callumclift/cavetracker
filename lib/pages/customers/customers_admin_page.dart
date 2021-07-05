//import 'package:flutter/material.dart';
//import '../../widgets/side_drawer.dart';
//import '../../shared/global_config.dart';
//import './customers_list.dart';
//import './customers_edit_page.dart';
//
//
//class CustomersAdminPage extends StatefulWidget {
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return CustomersAdminPageState();
//  }
//
//}
//
//class CustomersAdminPageState extends State<CustomersAdminPage> with SingleTickerProviderStateMixin {
//
//  TabController _tabController;
//
//  @override
//  void initState(){
//    super.initState();
//    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
//  }
//
//  @override
//  void didChangeDependencies() {
//    setState(() {
//      _tabController.addListener(handleTabChange);
//    });
//    super.didChangeDependencies();
//  }
//
//  handleTabChange() {
//    // do whatever handling required first
//    setState(() {
//      FocusScope.of(context).requestFocus(new FocusNode());
//    });
//  }
//
//  @override
//  void dispose() {
//    // TODO: implement dispose
//    _tabController.dispose();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return DefaultTabController(
//        length: 2,
//        child: Scaffold(
//          backgroundColor: whiteGreen,
//          drawer: SideDrawer(),
//          appBar: AppBar(backgroundColor: mintGreen, iconTheme: IconThemeData(color: darkBlue),
//            title: FittedBox(fit:BoxFit.fitWidth,
//                child: Text('Customers', style: TextStyle(color: darkBlue),)),
//            bottom: TabBar(indicatorColor: darkBlue,
//              controller: _tabController,
//              tabs: <Widget>[
//                Tab(child: Text('Customer List', style: TextStyle(color: darkBlue),),
//                  icon: Icon(Icons.list, color: darkBlue,),
//                ),
//                Tab(child: Text('Add Customer', style: TextStyle(color: darkBlue),),
//                  icon: Icon(Icons.person_add, color: darkBlue,),
//                ),
//              ],
//            ),
//          ),
//          body: TabBarView(
//            controller: _tabController,
//            children: <Widget>[
//              CustomersListPage(),
//              CustomersEditPage(),
//            ],
//          ),
//        ));
//  }
//}
//
