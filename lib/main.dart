import 'dart:convert';
import 'dart:io';
// import 'dart:html';
//import 'package:android_alarm_manager/android_alarm_manager.dart';
/*import 'package:audio_service/audio_service.dart';*/
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swasthyasetu/api/api_helper.dart';
import 'package:swasthyasetu/app_screens/check_expiry_blank_screen.dart';
import 'package:swasthyasetu/app_screens/doctor_dashboard_screen.dart';
import 'package:swasthyasetu/app_screens/landing_screen.dart';
import 'package:swasthyasetu/app_screens/nurse/nurse_dashboard_screen.dart';
import 'package:swasthyasetu/app_screens/reception_dashboard_screen.dart';
import 'package:swasthyasetu/controllers/reminder_list_controller.dart';
import 'package:swasthyasetu/database/tb_reminder.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:swasthyasetu/services/dynamic_links_service.dart';
import 'package:swasthyasetu/services/navigation_service.dart';
import 'package:swasthyasetu/services/push_notification_service.dart';
import 'package:swasthyasetu/utils/NotificationManager.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'database/tb_notifications.dart';
import 'utils/color.dart';
import 'utils/connectycube_flutter_call_kit.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Widget? _defaultHome;
GlobalKey<NavigatorState>? navigatorKey;
String doctorIDP = "";
final getItLocator = GetIt.instance;
String? patientIDP;
ReminderListController? reminderListController;
NotificationManager notificationManger = NotificationManager();
bool comingFromOnLaunch = false;
PushNotificationService? _pushNotificationService;

final AppDatabase db = AppDatabase();
final AppDatabaseNotification dbNotification = AppDatabaseNotification();

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  List<TbReminderTable> tbReminderList =
  await reminderListController!.getAllActiveReminders();
  DateTime now = DateTime.now();
  DateTime oneHourLater = now.add(Duration(hours: 1));
  tbReminderList.forEach((element) {
    List<TbNotificationTable> tbNotificationList = reminderListController!
        .getNotificationsWithReminderIDAndBetweenTimes(
        element.reminderID!, now, oneHourLater);
    tbNotificationList.forEach((elementNotification) {
      notificationManger.showNotificationDaily(
          element.reminderID!,
          element.category,
          element.desc!,
          TimeOfDay.fromDateTime(elementNotification.shootTime!));
    });
  });
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  navigatorKey = GlobalKey<NavigatorState>(); // Initialize navigatorKey here
  await Firebase.initializeApp();
  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug:
      true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
      true // option: set to false to disable working with http links (default: false)
  );
  reminderListController = Get.put(ReminderListController());
  //navigatorKey = getItLocator<NavigationService>().navigatorKey;
  await _configureLocalTimeZone();
  initPlatformState();
  await clearSelectedOrganizationFromSharedPreferences();


  /*final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), helloAlarmID, printHello);*/
  getItLocator.registerLazySingleton(() => DynamicLinksService());
  getItLocator.registerLazySingleton(() => NavigationService());
  getItLocator.registerLazySingleton(() => PushNotificationService());
  _pushNotificationService = getItLocator<PushNotificationService>();
  await _pushNotificationService!.initialise();
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) async {
    if (message != null) {
      _pushNotificationService!.fromLaunch = true;
      _pushNotificationService!.messageData = message;
      String userType = await getUserType();
      if (userType == "doctor" && _pushNotificationService!.fromLaunch)
        _pushNotificationService!.onMessageOpened(message);
      //_pushNotificationService.fromLaunch = false;
      //_pushNotificationService.messageData = null;
    }
  });
  final DynamicLinksService _dynamicLinkService =
  getItLocator<DynamicLinksService>();
  await _dynamicLinkService.initialiseDynamicLinks();
  initializeCallUILogic();
  //initDynamicLinks();
  runTheApp();
}

Future<void> clearSelectedOrganizationFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('selectedOrganizationIDF');
  prefs.remove('selectedOrganizationName');
  prefs.remove('selectedOrganizationUnit');
}

void initializeCallUILogic() async {
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: (
        String sessionId,
        int callType,
        int callerId,
        String callerName,
        Set opponentsIds,
        ) async {
      debugPrint("Call accepted.");
      return null;
    },
    onCallRejected: (String sessionId, int callType, int callerId,
        String callerName, Set opponentsIds) {
      debugPrint("Call rejected.");
      return null!;
    },
  );
  /*await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
    isVisible: true,
  );*/
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //_pushNotificationService.
  //showNotificationOfTypeDataForOnMessage(message);
  /*_pushNotificationService = getItLocator<PushNotificationService>();
  await _pushNotificationService.initialise();
  print("Handling a background message: ${message.messageId}");
  _pushNotificationService.fromLaunch = true;
  print("onLaunch: $message");
  _pushNotificationService.messageData = message;
  _pushNotificationService.showNotificationOfTypeDataForOnMessage(message);*/
}

/*void showNotificationOfTypeDataForOnMessage(
  RemoteMessage message,
) async {
  var android = AndroidNotificationDetails(
      "SwasthyaSetu_Channel", "SwasthyaSetu_Channel", "SwasthyaSetu_Channel", priority: Priority.high);
  var ios = IOSNotificationDetails();
  var notificationDetails = NotificationDetails(android: android, iOS: ios);
  var vidUrl, image;
  if (message.data != null) {
    // Handle notification message
    final dynamic data = message.data;
    var title = data['title'];
    var body = data['body'];
    var type = data['type'];
    debugPrint("Inside Notification");
    var android = AndroidInitializationSettings('drawable/ic_notification');
    var ios = IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: android, iOS: ios);
    var flutterLocalNotificationsPluginWithSelectNotification =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPluginWithSelectNotification.initialize(
        initializationSettings, onSelectNotification: (String payload) async {
      debugPrint("Clicked on notification");
      if (type == "healthtips") {
        print("Type is health tips");
        //print(GlobalKey().currentContext);
        String patientIDP = await getPatientIDP();
        Future.delayed(Duration(seconds: 1), () {
          getItLocator<NavigationService>().navigatorKey.currentState.push(
              MaterialPageRoute(
                  builder: (context) => HealthTipsScreen(patientIDP)));
          flutterLocalNotificationsPluginWithSelectNotification.cancel(0);
        });
      } else if (type == "video") {
        print("Type is video");
        //print(GlobalKey().currentContext);
        vidUrl = data['videourl'];
        image = data['image'];
        var vidTitle = "";
        var vidDesc = "";
        Future.delayed(Duration(seconds: 1), () {
          getItLocator<NavigationService>().navigatorKey.currentState.push(
              MaterialPageRoute(
                  builder: (context) =>
                      VideoPlayerScreen(vidUrl, title, body)));
          flutterLocalNotificationsPluginWithSelectNotification.cancel(0);
        });
        return;
      } else if (type == "generalurl") {
        print("Type is general url");
        //print(GlobalKey().currentContext);
        var url = data['url'];
        Future.delayed(Duration(seconds: 1), () {
          //SizeConfig().init(navigatorKeyLocal.currentContext);
          final flutterWebViewPlugin = FlutterWebviewPlugin();
          flutterWebViewPlugin.onDestroy.listen((_) {
            if (getItLocator<NavigationService>()
                .navigatorKey
                .currentState
                .canPop()) {
              getItLocator<NavigationService>().navigatorKey.currentState.pop();
            }
          });
          getItLocator<NavigationService>()
              .navigatorKey
              .currentState
              .push(MaterialPageRoute(builder: (mContext) {
            return new MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
              routes: {
                "/": (_) => new WebviewScaffold(
                      withLocalStorage: true,
                      withJavascript: true,
                      url: url,
                      appBar: new AppBar(
                        backgroundColor: Color(0xFFFFFFFF),
                        title: new Text(title),
                        leading: new IconButton(
                            icon: new Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () => {
                                  getItLocator<NavigationService>()
                                      .navigatorKey
                                      .currentState
                                      .pop(),
                                }),
                        iconTheme: IconThemeData(color: Colors.white, size: 25),
                        textTheme: TextTheme(
                            title: TextStyle(
                                color: Colors.white,
                                fontFamily: "Ubuntu",
                                fontSize: 15)),
                      ),
                    ),
              },
            );
          }));
          flutterLocalNotificationsPluginWithSelectNotification.cancel(0);
        });
      }
      //flutterLocalNotificationsPluginWithSelectNotification.cancel(0);
    });
    flutterLocalNotificationsPluginWithSelectNotification.show(
        0, title, body, notificationDetails);
    */
/*if (type != "video")
      flutterLocalNotificationsPluginWithSelectNotification.show(
          0, title, body, notificationDetails);
    else {
      var vidUrl = data['videourl'];
      var image = data['image'];
      showBigPictureNotification(vidUrl, title, body, image);
    }*/ /*
  }
}*/

Future<void> initPlatformState() async {
  // Configure BackgroundFetch.
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE), (String taskId) async {
    // <-- Event handler
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received $taskId");
    // IMPORTANT:  You must signal completion of your task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }, (String taskId) async {
    // <-- Task timeout handler.
    // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  });
  print('[BackgroundFetch] configure success: $status');
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  /*final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));*/
}

void initDynamicLinks() async {
  final PendingDynamicLinkData? data =
  await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data!.link;

  if (deepLink != null) {
    debugPrint("Inside Initial Link");
    var referCode = deepLink.path.replaceAll('/', '');
    doctorIDP = referCode.substring(5).replaceAll("0", "");
    debugPrint("Invite code - $doctorIDP");
    runTheApp();
    //showInviteDialog();
    /*setState(() {
      inviteCode = deepLink.path.replaceAll('/', '');
    });*/
    //Navigator.pushNamed(context, deepLink.path);
  } else {
    debugPrint("Invite code - $doctorIDP");
    runTheApp();
  }

  FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
    final Uri deepLink = dynamicLink.link;

    if (deepLink != null) {
      debugPrint("Inside OnLink");
      var referCode = deepLink.path.replaceAll('/', '');
      doctorIDP = referCode.substring(5).replaceAll("0", "");
      debugPrint("Invite code - $doctorIDP");
      runTheApp();
      /*showInviteDialog();
      setState(() {
        inviteCode = deepLink.path.replaceAll('/', '');
      });*/
      //Navigator.pushNamed(context, deepLink.path);
    } else {
      debugPrint("Invite code - $doctorIDP");
      runTheApp();
    }
  }).onError((e) {
    print('onLinkError');
    print(e.message);
  });

  /*FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
    final Uri deepLink = dynamicLink?.link;

    if (deepLink != null) {
      debugPrint("Inside OnLink");
      var referCode = deepLink.path.replaceAll('/', '');
      doctorIDP = referCode.substring(5).replaceAll("0", "");
      debugPrint("Invite code - $doctorIDP");
      runTheApp();
      */
  /*showInviteDialog();
      setState(() {
        inviteCode = deepLink.path.replaceAll('/', '');
      });*/
  /*
      //Navigator.pushNamed(context, deepLink.path);
    } else {
      debugPrint("Invite code - $doctorIDP");
      runTheApp();
    }
  }, onError: (OnLinkErrorException e) async {
    print('onLinkError');
    print(e.message);
  });*/
}

String encodeBase64(String text) {
  var bytes = utf8.encode(text);
  //var base64str =
  return base64.encode(bytes);
  //= Base64Encoder().convert()
}

void bindUnbindDoctor(String bindFlag) async {
  ApiHelper apiHelper = ApiHelper();
  debugPrint("Bind doctor : " + doctorIDP);
  String loginUrl = "${baseURL}patientBindDoctor.php";
  //listIcon = new List();
  String patientIDP = await getPatientOrDoctorIDP();
  String patientUniqueKey = await getPatientUniqueKey();
  String userType = await getUserType();
  debugPrint("Key and type");
  debugPrint(patientUniqueKey);
  debugPrint(userType);
  String jsonStr = "{" +
      "\"" +
      "PatientIDP" +
      "\"" +
      ":" +
      "\"" +
      patientIDP +
      "\"" +
      "," +
      "\"" +
      "DoctorIDP" +
      "\"" +
      ":" +
      "\"" +
      doctorIDP +
      "\"" +
      "," +
      "\"" +
      "FirstName" +
      "\"" +
      ":" +
      "\"" +
      "\"" +
      "," +
      "\"" +
      "LastName" +
      "\"" +
      ":" +
      "\"" +
      "\"" +
      "," +
      "\"" +
      "BindFlag" +
      "\"" +
      ":" +
      "\"" +
      bindFlag +
      "\"" +
      "}";

  debugPrint(jsonStr);

  String encodedJSONStr = encodeBase64(jsonStr);
  var response = await apiHelper.callApiWithHeadersAndBody(
    url: loginUrl,
    headers: {
      "u": patientUniqueKey,
      "type": userType,
    },
    body: {"getjson": encodedJSONStr},
  );
  //var resBody = json.decode(response.body);
  debugPrint(response.body.toString());
  final jsonResponse = json.decode(response.body.toString());
  ResponseModel model = ResponseModel.fromJSON(jsonResponse);
  //pr.hide();

  /*if (model.status == "OK") {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("Doctor Binded Successfully"),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //getPatientProfileDetails();
  }*/
}

void runTheApp() async {
  //_defaultHome = LoginScreen(doctorIDP);
  _defaultHome = LandingScreen();
  String mobNo = await getMobNo();
  String userType = await getUserType();

  BackgroundFetch.start().then((int status) {
    print('[BackgroundFetch] start success: $status');
  }).catchError((e) {
    print('[BackgroundFetch] start FAILURE: $e');
  });

  if (userType != "") {
    if (userType == "patient") {
      //bindUnbindDoctor("1");
      /*CheckExpiryBlankScreen(doctorIDP)*/
      /*if (!_pushNotificationService.fromLaunch)
        _defaultHome = CheckExpiryBlankScreen(doctorIDP, "launch");
      else*/
      _defaultHome = CheckExpiryBlankScreen(
          doctorIDP,
          "main",
          _pushNotificationService!.fromLaunch,
          _pushNotificationService!.messageData);
      /*ApplyCouponCodeOrPayScreen(doctorIDP)*/
      //_defaultHome = FillProfileDetails();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new MyApp());
      });
      /*SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new Flutter_Downloader_Demo_Screen());
      });*/
    } else if (userType == "doctor") {
      _defaultHome = DoctorDashboardScreen();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new MyApp());
      });
    } else if (userType == "frontoffice") {
      _defaultHome = ReceptionDashboardScreen();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new MyApp());
      });
    }
    else if (userType == "nursing") {
      _defaultHome = NurseDashboardScreen();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(new MyApp());
      });
    }
  } else {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(new MyApp());
    });
  }
}

void generateToken() async {
  String token = await getToken();
  if (token == "") {
    _firebaseMessaging.getToken().then((token) {
      print('token $token');
      setToken(token!);
      //submitTokenToService(con);
    });
  }
}

void iOS_Permission() async {
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

void firebaseCloudMessaging_Listeners(
    BuildContext context, GlobalKey<NavigatorState> navigatorKey) async {
  if (Platform.isIOS) {
    iOS_Permission();
  }

  String token = await getToken();
  if (token == "") {
    _firebaseMessaging.getToken().then((token) {
      print('token $token');
      setToken(token!);
    });
  }

  var android = AndroidInitializationSettings('drawable/ic_notification');
  var ios = DarwinInitializationSettings();
  var initializationSettings =
  InitializationSettings(android: android, iOS: ios);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<String> downloadAndSaveImage(String imgUrl) async {
  var response = await http.get(Uri.parse(imgUrl));
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  var imgFile = File('$tempPath/temp_notification');
  imgFile.writeAsBytesSync(response.bodyBytes);
  return "$tempPath/temp_notification";
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print('navigatorKey $navigatorKey');
    if (navigatorKey != null) {
      Future.delayed(Duration.zero, () {
        firebaseCloudMessaging_Listeners(context, navigatorKey!);
        //getIconsList(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    generateToken();
    // FirebaseAnalytics analytics = FirebaseAnalytics();
    return GetMaterialApp(
      title: 'Silver Touch',
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(
        milliseconds: 500,
      ),
      /* navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],*/
      navigatorKey: getItLocator<NavigationService>().navigatorKey,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Ubuntu',
          textTheme: TextTheme(
            bodySmall: textTheme(),
            labelLarge: textTheme(),
            labelSmall: textTheme(),
          ),
          appBarTheme: AppBarTheme(
              titleTextStyle: TextStyle(
                color: black,
                fontFamily: "Ubuntu",
                fontSize: 18,
              ))),
      debugShowCheckedModeBanner: false,
      home: _defaultHome,
      // home: MedicalCertificate(),
      //home: AudioServiceWidget(child: _defaultHome),
    );
  }

  textTheme() {
    return TextStyle(
      letterSpacing: 1.0,
    );
  }
}

/*class AlarmApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AlarmAppState();
  }
}

class AlarmAppState extends State<AlarmApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      firebaseCloudMessaging_Listeners(context, navigatorKey);
      //getIconsList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    generateToken();
    FirebaseAnalytics analytics = FirebaseAnalytics();
    return MaterialApp(
      title: 'Swasthya Setu',
      navigatorKey: getItLocator<NavigationService>().navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Ubuntu',
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      debugShowCheckedModeBanner: false,
      //home: _defaultHome,
      home: Text("Alarm!!!!!!\n Take Water please."),
    );
  }
}*/
