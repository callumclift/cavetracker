import 'dart:io' show Platform;
import 'package:caving_app/models/activity_log_model.dart';
import 'package:caving_app/models/cave_model.dart';
import 'package:caving_app/models/club_model.dart';
import 'package:caving_app/models/purchasing_model.dart';
import 'package:caving_app/models/purchasing_model.dart';
import 'package:caving_app/pages/clubhub/clubhub.dart';
import 'package:caving_app/subscription/subscription.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:caving_app/services/navigation_service.dart';
import 'package:caving_app/shared/global_config.dart';
import 'package:provider/provider.dart';
import './models/authentication_model.dart';
import './models/customers_model.dart';
import 'pages/home_page/home_page.dart';
import 'pages/login_page/login_page.dart';
import 'package:bot_toast/bot_toast.dart';
import './shared/global_config.dart';
import './shared/global_functions.dart';
import './locator.dart';
import './router.dart' as router;
import './constants/route_paths.dart';
import 'package:purchases_flutter/purchases_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //InAppPurchaseConnection.enablePendingPurchases();
  await Purchases.setDebugLogsEnabled(true);
  await Purchases.setup(purchasesKey);
  sharedPreferences = await SharedPreferences.getInstance();
  setupLocator();
  String firebaseAppId = GlobalFunctions.getFirebaseAppId();
  final FirebaseOptions firebaseOptions = FirebaseOptions(
    storageBucket: firebaseStorageBucket,
    appId: firebaseAppId,
    apiKey: firebaseApiKey,
    projectId: firebaseProjectId,
    messagingSenderId: firebaseMessagingSenderId,
  );

  Firebase.initializeApp(options: firebaseOptions);

  runApp(MyApp());
}


class MyApp extends StatefulWidget {

  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  AuthenticationModel _authenticationModel = AuthenticationModel();
  //PurchasingModel _purchasingModel;
  PurchaserInfo purchaserInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authenticationModel.autoLogin();
    initPlatformState();
    // _purchasingModel = PurchasingModel(_authenticationModel);
    // _purchasingModel.initialize();

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('didChangeDependancies');
  }

  @override
  void dispose() {
    //_purchasingModel.subscription.cancel();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // await Purchases.setDebugLogsEnabled(true);

    purchaserInfo = await Purchases.getPurchaserInfo();
  }

  Widget chooseHomePage(){
    Widget returnedRoute;
    if(user == null){
      returnedRoute = LoginPage();
    } else {
      // print(_purchasingModel.products);
      // print('after');
      print(purchaserInfo);
      print(purchaserInfo.activeSubscriptions);
      print(purchaserInfo.latestExpirationDate);
      print(purchaserInfo.firstSeen);
      purchaserInfo.entitlements.active.isEmpty ? returnedRoute = SubscriptionPage() : returnedRoute = Clubhub();
      //returnedRoute = SubscriptionPage(_purchasingModel);
    }
    return returnedRoute;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationModel>(create: (_) => _authenticationModel),
        ChangeNotifierProxyProvider<AuthenticationModel, ActivityLogModel>(
          update: (context, authenticationModel, activityLogModel) => ActivityLogModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, CaveModel>(
          update: (context, authenticationModel, caveModel) => CaveModel(authenticationModel),
        ),
        ChangeNotifierProxyProvider<AuthenticationModel, ClubModel>(
          update: (context, authenticationModel, clubModel) => ClubModel(authenticationModel),
        ),
        // ChangeNotifierProxyProvider<AuthenticationModel, PurchasingModel>(
        //   update: (context, authenticationModel, purchasingModel) => PurchasingModel(authenticationModel), create: (_) => _purchasingModel
        // )
      ],
      child: MaterialApp(
        onGenerateRoute: router.generateRoute,
        initialRoute: HomePageRoute,
        navigatorKey: locator<NavigationService>().navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'cave tracker',
        builder: BotToastInit(),
        navigatorObservers: [
          BotToastNavigatorObserver(),
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: whiteGreen,
          fontFamily: 'Open Sans',
          primarySwatch: Colors.indigo,
          primaryColor: darkBlue,
          buttonColor: darkBlue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthenticationModel>(
            builder: (BuildContext context, model, child) {
              return model.isLoading? Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [mintGreen, fadedGreen])
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
                  ),
                ),) : chooseHomePage();
            }),
      ),
    );
  }
}




