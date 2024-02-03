import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:swasthyasetu/app_screens/chat_screen.dart';
import 'package:swasthyasetu/app_screens/feelings_list_screen.dart';
import 'package:swasthyasetu/app_screens/health_tips_screen.dart';
import 'package:swasthyasetu/app_screens/investigations_list_with_graph.dart';
import 'package:swasthyasetu/app_screens/lab_reports.dart';
import 'package:swasthyasetu/app_screens/music_list_screen.dart';
import 'package:swasthyasetu/app_screens/my_appointments_patient.dart';
import 'package:swasthyasetu/app_screens/notification_list_screen.dart';
import 'package:swasthyasetu/app_screens/play_video_screen.dart';
import 'package:swasthyasetu/app_screens/report_patient_screen.dart';
import 'package:swasthyasetu/app_screens/vitals_list.dart';
import 'package:swasthyasetu/enums/list_type.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/services/navigation_service.dart';


class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final getItLocator = GetIt.instance;
  bool fromLaunch = false;
  RemoteMessage? messageData;
  String notificationType = "";
  var navigationService;

  Future initialise() async {
    navigationService = getItLocator<NavigationService>();
    if (Platform.isIOS) {
      iOS_Permission();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      fromLaunch = true;
      onMessageOpened(message);
    });

    /*_fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //showNotificationOfTypeDataForOnMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fromLaunch = true;
        print("onLaunch: $message");
        messageData = message;
        String userType = await getUserType();
        if (userType == "doctor") showNotificationOfTypeData(message, 0);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        messageData = message;
        showNotificationOfTypeData(message, 1);
      },
    );*/
  }

  void iOS_Permission() async {
    /*_firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true));
  _firebaseMessaging.onIosSettingsRegistered
      .listen((IosNotificationSettings settings) {
    print("Settings registered: $settings");
  });*/
    NotificationSettings settings = await _fcm.requestPermission(
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

  /* Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
    print("onLaunch: $message");
    messageData = message;
    showNotificationOfTypeDataForOnMessage(message);
  }*/

  /*void showNotificationOfTypeDataForOnMessage(
    RemoteMessage message,
  ) async {
    var android = AndroidNotificationDetails(
        "SwasthyaSetu_Channel", "SwasthyaSetu_Channel", "SwasthyaSetu_Channel");
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
            navigationService.navigatorKey.currentState.push(MaterialPageRoute(
                builder: (context) =>
                    TypicalListsScreen(patientIDP, ListTypes.HealthTips)));
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
            navigationService.navigatorKey.currentState.push(MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(vidUrl, title, body)));
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
              if (navigationService.navigatorKey.currentState.canPop()) {
                navigationService.navigatorKey.currentState.pop();
              }
            });
            navigationService.navigatorKey.currentState
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
                                    navigationService.navigatorKey.currentState
                                        .pop(),
                                  }),
                          iconTheme:
                              IconThemeData(color: Colors.white, size: 25),
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
      if (type != "video")
        flutterLocalNotificationsPluginWithSelectNotification.show(
            0, title, body, notificationDetails);
      else {
        var vidUrl = data['videourl'];
        var image = data['image'];
        showBigPictureNotification(vidUrl, title, body, image);
      }
    }
  }

  void showNotificationOfTypeData(RemoteMessage message, int fromType) async {
    var android = AndroidNotificationDetails(
        "SwasthyaSetu_Channel", "SwasthyaSetu_Channel", "SwasthyaSetu_Channel",
        priority: Priority.high);
    var ios = IOSNotificationDetails();
    var notificationDetails = NotificationDetails(android: android, iOS: ios);
    if (message.data != null) {
      // Handle notification message
      //final dynamic notification = message['data'];
      var data = message.data;
      String title = data['title'];
      var body = data['body'];
      var type = data['type'];
      notificationType = type;
      if (type == "healthtips") {
        print("Type is health tips");
        //print(GlobalKey().currentContext);
        String patientIDP = await getPatientIDP();
        Future.delayed(Duration(seconds: 1), () {
          navigationService.navigatorKey.currentState.push(MaterialPageRoute(
              builder: (context) =>
                  TypicalListsScreen(patientIDP, ListTypes.HealthTips)));
          flutterLocalNotificationsPlugin.cancel(0);
        });
      } else if (type == "video") {
        print("Type is video");
        //print(GlobalKey().currentContext);
        var vidUrl = data['videourl'];
        var image = data['image'];
        var vidTitle = "";
        var vidDesc = "";
        await showBigPictureNotification(vidUrl, title, body, image);
        Future.delayed(Duration(seconds: 1), () {
          navigationService.navigatorKey.currentState.push(MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(vidUrl, title, body)));
          flutterLocalNotificationsPlugin.cancel(0);
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
            if (navigationService.navigatorKey.currentState.canPop()) {
              navigationService.navigatorKey.currentState.pop();
            }
          });
          navigationService.navigatorKey.currentState
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
                                  navigationService.navigatorKey.currentState
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
          flutterLocalNotificationsPlugin.cancel(0);
        });
      } else if (type == "chat") {
        print("Type is chat");
        String messageIdp = data['messageidp'];
        //print(GlobalKey().currentContext);
        Future.delayed(Duration(seconds: 1), () {
          getItLocator<NavigationService>()
              .navigatorKey
              .currentState
              .push(MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        patientIDP: messageIdp,
                        patientName: title
                            .toLowerCase()
                            .replaceFirst("message from", "")
                            .replaceFirst("-", "")
                            .trim(),
                        patientImage: "",
                      )));
          flutterLocalNotificationsPlugin.cancel(0);
        });
        return;
      } else if (type == "notify") {
        print("Type is notify");
        Future.delayed(Duration(seconds: 1), () {
          getItLocator<NavigationService>().navigatorKey.currentState.push(
              MaterialPageRoute(builder: (context) => NotificationList()));
          flutterLocalNotificationsPlugin.cancel(0);
        });
        return;
      } else if (type == "myappointment") {
        print("Type is myappointment");
        Future.delayed(Duration(seconds: 1), () {
          getItLocator<NavigationService>().navigatorKey.currentState.push(
              MaterialPageRoute(
                  builder: (context) => MyAppointmentsPatientScreen()));
          flutterLocalNotificationsPlugin.cancel(0);
        });
        return;
      }
      //if (fromType == 0)
      flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
    }
  }*/

  Future<String> downloadAndSaveImage(String imgUrl) async {
    var response = await http.get(Uri.parse(imgUrl));
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var imgFile = File('$tempPath/temp_notification');
    imgFile.writeAsBytesSync(response.bodyBytes);
    return "$tempPath/temp_notification";
  }

  Future<void> showBigPictureNotification(vidUrl, title, body, image) async {
    var ios = DarwinNotificationDetails();
    /*var bigPicturePath =*/
    await downloadAndSaveImage('$image').then((bigPicturePath) {
      var bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: true);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "SwasthyaSetu_Channel", "SwasthyaSetu_Channel",
          // "SwasthyaSetu_Channel",
          styleInformation: bigPictureStyleInformation);
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: ios);
      flutterLocalNotificationsPlugin.show(
          0, title, body, platformChannelSpecifics);
    });
    /*var bigPictureStyleInformation = BigPictureStyleInformation(
      bigPicturePath, BitmapSource.FilePath,
      largeIconBitmapSource: BitmapSource.FilePath,
      contentTitle: 'overridden <b>big</b> content title',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true);*/
  }

  void onMessageOpened(RemoteMessage message) async {
    debugPrint("Opened notification : ${message.data}");
    var data = message.data;
    messageData = message;
    String title = data['title'];
    var body = data['body'];
    var type = data['type'];
    notificationType = type;
    if (type == "healthtips") {
      print("Type is health tips");
      //print(GlobalKey().currentContext);
      String patientIDP = await getPatientOrDoctorIDP();
      Future.delayed(Duration(seconds: 1), () {
        navigationService.navigatorKey.currentState.push(MaterialPageRoute(
            builder: (context) =>
                TypicalListsScreen(patientIDP, ListTypes.HealthTips)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "video") {
      print("Type is video");
      //print(GlobalKey().currentContext);
      var vidUrl = data['videourl'];
      var image = data['image'];
      var vidTitle = "";
      var vidDesc = "";
      await showBigPictureNotification(vidUrl, title, body, image);
      Future.delayed(Duration(seconds: 1), () {
        navigationService.navigatorKey.currentState.push(MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(vidUrl, title, body)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
      return;
    } else if (type == "generalurl") {
      print("Type is general url");
      //print(GlobalKey().currentContext);
      var url = data['url'];
      Future.delayed(Duration(seconds: 1), () {
        //SizeConfig().init(navigatorKeyLocal.currentContext);
        // final flutterWebViewPlugin = FlutterWebviewPlugin();
        // flutterWebViewPlugin.onDestroy.listen((_) {
        //   if (navigationService.navigatorKey.currentState.canPop()) {
        //     navigationService.navigatorKey.currentState.pop();
        //   }
        // });
        // navigationService.navigatorKey.currentStaterentState
        //     .push(MaterialPageRoute(builder: (mContext) {
        //   return new MaterialApp(
        //     debugShowCheckedModeBanner: false,
        //     theme: ThemeData(
        //         fontFamily: "Ubuntu", primaryColor: Color(0xFF06A759)),
        //     routes: {
        //       "/": (_) => new WebviewScaffold(
        //             withLocalStorage: true,
        //             withJavascript: true,
        //             url: url,
        //             appBar: new AppBar(
        //               backgroundColor: Color(0xFFFFFFFF),
        //               title: new Text(title),
        //               leading: new IconButton(
        //                   icon:
        //                       new Icon(Icons.arrow_back_ios, color: colorBlack),
        //                   onPressed: () => {
        //                         navigationService.navigatorKey.currentState
        //                             .pop(),
        //                       }),
        //               iconTheme: IconThemeData(color: colorBlack, size: 25),
        //               textTheme: TextTheme(
        //                   subtitle1: TextStyle(
        //                       color: colorBlack,
        //                       fontFamily: "Ubuntu",
        //                       fontSize: 15)),
        //             ),
        //           ),
        //     },
        //   );
        // }));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "chat") {
      print("Type is chat");
      String messageIdp = data['messageidp'];
      //print(GlobalKey().currentContext);
      Future.delayed(Duration(seconds: 1), () async {
        getItLocator<NavigationService>()
            .navigatorKey
            .currentState
            !.push(MaterialPageRoute(
                builder: (context) => ChatScreen(
                      patientIDP: messageIdp,
                      patientName: title
                          .replaceFirst("Message from", "")
                          .replaceFirst("-", "")
                          .trim(),
                      patientImage: "",
                    )));
        flutterLocalNotificationsPlugin.cancel(0);
        /*await ConnectycubeFlutterCallKit.showCallNotification(
          sessionId: data['messageidp'],
          callType: 0,
          callerName: "Sunil Shah",
          callerId: 0,
          opponentsIds: Set(),
        );*/
      });
      return;
    } else if (type == "notify") {
      print("Type is notify");
      Future.delayed(Duration(seconds: 1), () async{
        String userType = await getUserType();
        String patientIDP = await getPatientOrDoctorIDP();
        if (userType == "patient"){
        getItLocator<NavigationService>()
            .navigatorKey
            .currentState
            !.push(MaterialPageRoute(builder: (context) => NotificationList()));
        flutterLocalNotificationsPlugin.cancel(0);
        }else if (userType == "doctor") {
          getItLocator<NavigationService>().navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => LabReportsScreen()));
          flutterLocalNotificationsPlugin.cancel(0);
        }
      });
      return;
    } else if (type == "myappointment") {
      print("Type is myappointment");
      Future.delayed(Duration(seconds: 1), () {
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => MyAppointmentsPatientScreen()));
        flutterLocalNotificationsPlugin.cancel(0);
      });
      return;
    } else if (type == "labreport") {
      print("Type is Lab Report");
      Future.delayed(Duration(milliseconds: 500), () async {
        String userType = await getUserType();
        String patientIDP = await getPatientOrDoctorIDP();
        if (userType == "patient") {
          getItLocator<NavigationService>().navigatorKey.currentState!.push(
              MaterialPageRoute(
                  builder: (context) =>
                      PatientReportScreen(patientIDP, "dashboard",false)));
          flutterLocalNotificationsPlugin.cancel(0);
        } else if (userType == "doctor") {
          getItLocator<NavigationService>().navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => LabReportsScreen()));
          flutterLocalNotificationsPlugin.cancel(0);
        }
      });
      return;
    } else if (type == "bloodpressure") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => VitalsListScreen(patientIDP, "1")));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "sugar") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>()
            .navigatorKey
            .currentState
            !.push(MaterialPageRoute(
                builder: (context) => InvestigationsListWithGraph(
                      patientIDP,
                      from: "sugar",
                    )));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "vitals") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => VitalsListScreen(patientIDP, "2")));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "water") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => VitalsListScreen(patientIDP, "7")));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "feeling") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => FeelingsListScreen(patientIDP)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "exercise") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => VitalsListScreen(patientIDP, "5")));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "healthreceipes") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) =>
                    TypicalListsScreen(patientIDP, ListTypes.Recipes)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "importantlinks") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) =>
                    TypicalListsScreen(patientIDP, ListTypes.ImportantLinks)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    } else if (type == "meditation") {
      Future.delayed(Duration(milliseconds: 500), () async {
        String patientIDP = await getPatientOrDoctorIDP();
        getItLocator<NavigationService>().navigatorKey.currentState!.push(
            MaterialPageRoute(
                builder: (context) => MusicListScreen(patientIDP)));
        flutterLocalNotificationsPlugin.cancel(0);
      });
    }
  }
}
