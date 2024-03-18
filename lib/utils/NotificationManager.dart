import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:silvertouch/controllers/reminder_list_controller.dart';
import 'package:silvertouch/database/tb_notifications.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  ReminderListController reminderListController = Get.find();

  final StreamController<String> selectNotificationStream =
      StreamController<String>.broadcast();

  NotificationManager() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    initNotifications();
  }

  getNotificationInstance() {
    return flutterLocalNotificationsPlugin;
  }

  void initNotifications() {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@drawable/ic_notification');
    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse:
    //       (NotificationResponse notificationResponse) {
    //     switch (notificationResponse.notificationResponseType) {
    //       case NotificationResponseType.selectedNotification:
    //         selectNotificationStream.add(notificationResponse.payload);
    //         break;
    //       case NotificationResponseType.selectedNotificationAction:
    //         if (notificationResponse.actionId == navigationActionId) {
    //           selectNotificationStream.add(notificationResponse.payload);
    //         }
    //         break;
    //     }
    //   },
    //   onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    // );
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  void showNotificationDaily(
      int id, String title, String body, TimeOfDay onceTime) async {
    /*int notificationID = await reminderListController.insertNotification(
        TbNotificationTable(
            reminderID: id, shootTime: dateTimeFromTimeOfDay(onceTime)));*/
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     id,
    //     "Reminder for - " + title,
    //     body,
    //     _nextInstanceOfSpecifiedTime(onceTime.hour, onceTime.minute),
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'SwasthyaSetu_Channel',
    //         'SwasthyaSetu_Channel',
    //         // 'Notification channel for Reminder functionality in Swasthya Setu app.',
    //         priority: Priority.high,
    //         importance: Importance.max,
    //         playSound: true,
    //       ),
    //       iOS: iosNotificationDetails(),
    //     ),
    //     androidAllowWhileIdle: true,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.absoluteTime,
    //     matchDateTimeComponents: DateTimeComponents.time);
  }

  // const DarwinNotificationDetails iosNotificationDetails =
  // DarwinNotificationDetails(
  //   categoryIdentifier: darwinNotificationCategoryPlain,
  // );

  void showNotificationDailyAtSpecifiedInterval(int id, String title,
      String body, TimeOfDay fromTime, TimeOfDay toTime, int everyHour) async {
    List<tz.TZDateTime> scheduledDates = [];
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    DateTime fromDate =
        DateTime(now.year, now.month, now.day, fromTime.hour, fromTime.minute);
    DateTime toDate =
        DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, now.hour, now.minute);
    Duration duration = toDate.difference(fromDate);
    int totalHours = duration.inHours;
    debugPrint("hours difference - $totalHours");
    debugPrint("from - $fromDate");
    debugPrint("to - $toDate");
    for (int i = 0; i <= (totalHours / everyHour); i++) {
      scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
          fromTime.hour + (i * everyHour), fromTime.minute);
      print("scheduling notification");
      int notificationID = await reminderListController.insertNotification(
          TbNotificationTable(reminderID: id, shootTime: scheduledDate));
      debugPrint(
          "scheduled date - $scheduledDate, Notification ID - $notificationID");
      // await flutterLocalNotificationsPlugin.zonedSchedule(
      //   notificationID,
      //   "Reminder for - " + title,
      //   body,
      //   scheduledDate,
      //   const NotificationDetails(
      //     android: AndroidNotificationDetails(
      //       'SwasthyaSetu_Channel',
      //       'SwasthyaSetu_Channel',
      //       // 'Notification channel for Reminder functionality in Swasthya Setu app.',
      //       priority: Priority.high,
      //       importance: Importance.max,
      //       playSound: true,
      //     ),
      //     iOS: IOSNotificationDetails(),
      //   ),
      //   androidAllowWhileIdle: true,
      //   uiLocalNotificationDateInterpretation:
      //       UILocalNotificationDateInterpretation.absoluteTime,
      //   matchDateTimeComponents: DateTimeComponents.time,
      // );
    }
  }

  // getPlatformChannelSpecifics() {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'SwasthyaSetu_Channel',
  //       'SwasthyaSetu_Channel',
  //       // 'Notification channel for Reminder functionality in Swasthya Setu app.',
  //       importance: Importance.high,
  //       priority: Priority.max,
  //       ticker: 'Medicine Reminder');
  //   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //
  //   return platformChannelSpecifics;
  // }

  Future onSelectNotification(String payload) async {
    print('Notification clicked');
    return Future.value(0);
  }

  Future onDidReceiveLocalNotification(
      int? id, String? title, String? body, String? payload) async {
    return Future.value(1);
  }

  void removeReminder(int notificationId) async {
    final requests =
        await flutterLocalNotificationsPlugin!.pendingNotificationRequests();
    requests.removeWhere((element) => element.id == notificationId);
    await flutterLocalNotificationsPlugin!.cancel(notificationId);
  }

  _nextInstanceOfSpecifiedTime(int hour, int minute /*, int everyHour*/) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  _nextInstanceOfSpecifiedHoursInterval(TimeOfDay fromTime, TimeOfDay toTime,
      int everyHour, List<tz.TZDateTime> scheduledDates) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    /*debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    for (int i = 0; i < totalHours; i++) {
      debugPrint(scheduledDate.add(Duration(hours: 1)).toString());
    }*/
    /*for (int i = 0; i < totalHours; i++) {
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        return;
      } else {
        scheduledDate = scheduledDate.add(Duration(hours: everyHour));
      }
    }*/
    /*debugPrint("differences");
    debugPrint(scheduledDate.difference(fromDate).inSeconds.toString());
    debugPrint(scheduledDate.difference(toDate).inSeconds.toString());*/

    for (int i = 0; i < scheduledDates.length; i++) {
      if (scheduledDates[i].isAtSameMomentAs(now)) return scheduledDates[i];
    }
    return null;

    /*if (scheduledDate.difference(fromDate).inSeconds > 0 &&
        scheduledDate.difference(toDate).inSeconds < 0) {
      return scheduledDate = scheduledDate.add(Duration(hours: everyHour));
    } else {
      return null;
    }*/

    //return scheduledDate;
  }
}
