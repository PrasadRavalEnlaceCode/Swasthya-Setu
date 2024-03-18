import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:silvertouch/database/tb_notifications.dart';
import 'package:silvertouch/database/tb_reminder.dart';
import 'package:silvertouch/main.dart';

class ReminderListController extends GetxController {
  RxList<TbReminderTable?> activeReminderList = <TbReminderTable>[].obs;
  RxList<TbReminderTable?> inactiveReminderList = <TbReminderTable>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    /*getUserType().then((value) {
      if(value != 'frontoffice')
        getAllReminders();
    });*/
    getAllReminders();
  }

  void getAllReminders() async {
    getAllNotifications();
    isLoading.value = true;
    activeReminderList.assignAll(await db
        .getAllActiveReminders()); /* = (await db.getAllActiveReminders()).obs;*/
    inactiveReminderList.assignAll(await db.getAllInactiveReminders());
    if (inactiveReminderList.isEmpty) {
      /*db.insertReminder(TbReminderTable(
          reminderID: 1,
          notificationID: 0,
          category: "Water",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: null));*/
      /*db.insertReminder(
        TbReminderTable(
          reminderID: 5,
          notificationID: 5,
          category: "Other",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: null,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0),
          frequentlyEveryHours: 1,
          entryTime: DateTime.now(),
        ),
      );*/
      db.insertReminder(
        TbReminderTable(
          reminderID: 4,
          notificationID: 4,
          category: "Medicine",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: false,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0),
          frequentlyEveryHours: 1,
          entryTime: DateTime.now(),
        ),
      );
      db.insertReminder(
        TbReminderTable(
          reminderID: 3,
          notificationID: 3,
          category: "Exercise",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: false,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0),
          frequentlyEveryHours: 1,
          entryTime: DateTime.now(),
        ),
      );
      db.insertReminder(
        TbReminderTable(
          reminderID: 2,
          notificationID: 2,
          category: "Food",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: false,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0),
          frequentlyEveryHours: 1,
          entryTime: DateTime.now(),
        ),
      );
      db.insertReminder(
        TbReminderTable(
          reminderID: 1,
          notificationID: 1,
          category: "Water",
          desc: "null",
          isReminderOn: false,
          isOnceOrFrequent: false,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0),
          frequentlyEveryHours: 1,
          entryTime: DateTime.now(),
        ),
      );
      getAllReminders();
    } else {
      /*db.updateReminder(TbReminderTable(
          reminderID: 1,
          notificationID: 0,
          category: "Water",
          desc: "null",
          isReminderOn: true,
          isOnceOrFrequent: true,
          onceTime: dateTimeWithHourAndMinute(9, 0),
          fromTime: dateTimeWithHourAndMinute(9, 0),
          toTime: dateTimeWithHourAndMinute(21, 0)));*/
    }
    printInfo(info: "length of active - ${activeReminderList.length}");
    isLoading.value = false;
  }

  Future<List<TbReminderTable>> getAllActiveReminders() async {
    List<TbReminderTable>? activeReminders;
    activeReminders!.assignAll(await db.getAllActiveReminders());
    return activeReminders;
  }

  Future<int> insertReminder(TbReminderTable tb) async {
    int id = await db.insertReminder(tb);

    /*if (tb.isOnceOrFrequent)
      insertNotification(
          TbNotificationTable(reminderID: id, shootTime: tb.onceTime));
    else {
      Duration duration = tb.toTime.difference(tb.fromTime);
      int totalHours = duration.inHours;
      for (int i = 0; i <= totalHours / tb.frequentlyEveryHours; i++) {
        DateTime now = DateTime.now();
        tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            tb.fromTime.hour + i * tb.frequentlyEveryHours,
            tb.fromTime.minute);
        insertNotification(
            TbNotificationTable(reminderID: id, shootTime: scheduledDate));
      }
    }*/
    getAllReminders();
    return id;
  }

  void deleteReminderAndCorrespondingNotifications(TbReminderTable tb) async {
    db.deleteReminder(tb);
    deleteNotification(
        TbNotificationTable(reminderID: tb.reminderID!), tb.reminderID!);
    getAllReminders();
  }

  void updateReminder(TbReminderTable tb) async {
    db.updateReminder(tb);
    getAllReminders();
    /*deleteNotification(
        TbNotificationTable(reminderID: tb.reminderID), tb.reminderID);*/
    if (!tb.isReminderOn) {
      deleteNotification(
          TbNotificationTable(reminderID: tb.reminderID!), tb.reminderID!);
    }
    getAllNotifications();
    /*deleteNotification(
        TbNotificationTable(reminderID: tb.reminderID), tb.reminderID);
    if (tb.isOnceOrFrequent)
      insertNotification(TbNotificationTable(
          reminderID: tb.reminderID, shootTime: tb.onceTime));
    else {
      Duration duration = tb.toTime.difference(tb.fromTime);
      int totalHours = duration.inHours;
      for (int i = 0; i <= totalHours / tb.frequentlyEveryHours; i++) {
        DateTime now = DateTime.now();
        tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            tb.fromTime.hour + i * tb.frequentlyEveryHours,
            tb.fromTime.minute);
        insertNotification(TbNotificationTable(
            reminderID: tb.reminderID, shootTime: scheduledDate));
      }
    }*/
  }

  Future<int> insertNotification(TbNotificationTable tb) async {
    int id = await dbNotification.insertNotification(tb);
    return id;
  }

  Future<int> deleteNotification(TbNotificationTable tb, int reminderID) async {
    int id = await dbNotification.deleteNotification(tb, reminderID);
    return id;
  }

  getAllNotifications() async {
    List<TbNotificationTable> listNotifications =
        await dbNotification.getAllNotifications();
    debugPrint("Notification list");
    for (int i = 0; i < listNotifications.length; i++) {
      debugPrint(listNotifications[i].notificationID.toString() +
          " " +
          listNotifications[i].reminderID.toString() +
          " " +
          listNotifications[i].shootTime.toString());
    }
  }

  getNotificationsWithReminderID(int reminderID) async {
    List<TbNotificationTable> listNotifications =
        await dbNotification.getNotificationsWithReminderID(reminderID);
    return listNotifications;
  }

  getNotificationsWithReminderIDAndBetweenTimes(
      int reminderID, DateTime fromDate, DateTime toDate) async {
    List<TbNotificationTable> listNotifications =
        await dbNotification.getNotificationsWithReminderIDAndBetweenTimes(
            reminderID, fromDate, toDate);
    return listNotifications;
  }

  DateTime dateTimeWithHourAndMinute(int hour, int min) {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      min,
    );
  }
}
