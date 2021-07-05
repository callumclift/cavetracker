import 'package:caving_app/pages/activity_log/activity_log_list.dart';
import 'package:caving_app/pages/activity_log/activity_log_page.dart';
import 'package:caving_app/pages/activity_log/club_activity_log_list.dart';
import 'package:caving_app/pages/call_out/call_out_page.dart';
import 'package:caving_app/pages/caves/cave.dart';
import 'package:caving_app/pages/caves/cave_list.dart';
import 'package:caving_app/pages/caves/location_select.dart';
import 'package:caving_app/pages/caves/create_cave_page.dart';
import 'package:caving_app/pages/clubhub/announcements_list.dart';
import 'package:caving_app/pages/clubhub/clubhub.dart';
import 'package:caving_app/pages/login_page/sign_up_page.dart';
import 'package:caving_app/pages/settings/settings_page.dart';
import 'package:caving_app/subscription/subscription.dart';
import 'package:flutter/material.dart';
import 'package:caving_app/constants/route_paths.dart' as routes;
import './pages/login_page/login_page.dart';
import './pages/home_page/home_page.dart';
import './pages/customers/customers_admin_page.dart';
import './pages/customers/customers_edit_page.dart';
import './pages/undefined_page/undefined_page.dart';
import 'constants/route_paths.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch(settings.name) {
    case routes.HomePageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => HomePage(argument: argument,));
    case routes.LoginPageRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case routes.SettingsPageRoute:
      return MaterialPageRoute(builder: (context) => SettingsPage());
    case routes.ActivityLogPageRoute:
      return MaterialPageRoute(builder: (context) => ActivityLogPage());
    case routes.ActivityLogListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedActivityLogsListPage());
    case routes.ClubActivityLogListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedClubActivityLogsListPage());
    case routes.CreateCavePageRoute:
      return MaterialPageRoute(builder: (context) => CreateCavePage());
    case routes.CavePageRoute:
      return MaterialPageRoute(builder: (context) => CavePage());
    case routes.CaveListRoute:
      return MaterialPageRoute(builder: (context) => CaveListPage());
    case routes.ClubhubPageRoute:
      return MaterialPageRoute(builder: (context) => Clubhub());
    case routes.LocationSelectRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => LocationSelect(argument, argument, argument, argument));
//    case routes.CustomersRoute:
//      return MaterialPageRoute(builder: (context) => CustomersAdminPage());
//    case routes.CustomersEditPageRoute:
//      return MaterialPageRoute(builder: (context) => CustomersEditPage());
    case routes.SignUpPageRoute:
      return MaterialPageRoute(builder: (context) => SignUpPage());
    case routes.SubscriptionPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => SubscriptionPage());
    case routes.AnnouncementsListPageRoute:
      return MaterialPageRoute(builder: (context) => CompletedAnnouncementsListPage());
    case routes.CallOutPageRoute:
      return MaterialPageRoute(builder: (context) => CallOutPage());

      break;
    default:
      return MaterialPageRoute(builder: (context) => UndefinedPage(name: settings.name,));
  }

}
