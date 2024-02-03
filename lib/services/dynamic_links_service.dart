import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get_it/get_it.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/app_screens/login_screen.dart';
import 'package:swasthyasetu/app_screens/patient_dashboard_screen.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/services/navigation_service.dart';

class DynamicLinksService {
  var navigationService;
  final getItLocator = GetIt.instance;
  var doctorIDP = "";

  Future initialiseDynamicLinks() async {
    navigationService = getItLocator<NavigationService>();
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      _handleDeepLink(dynamicLink);
    }).onError((e){
      print('Link Failed: ${e.message}');
    });

    /*FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });*/
  }

  void _handleDeepLink(PendingDynamicLinkData? data) async {
    if(data!=null)
      {
        final Uri deepLink = data!.link;
        if (deepLink != null) {
          var referCode = deepLink.path.replaceAll('/', '');
          doctorIDP = referCode.substring(5).replaceAll("0", "");
          String userType = await getUserType();
          if (userType != "") {
            if (userType == "patient") {
              navigationService.navigateTo(PatientDashboardScreen(doctorIDP));
            } else if (userType == "doctor") {
              navigationService.navigateTo(DoctorDashboardScreen());
            }
          } else {
            navigationService.navigateTo(LoginScreen(doctorIDP));
          }
        } else {}
      }
  }
}
