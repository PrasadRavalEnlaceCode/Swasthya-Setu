import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/controllers/add_reminder_controller.dart';
import 'package:silvertouch/controllers/reminder_list_controller.dart';
import 'package:silvertouch/database/tb_notifications.dart';
import 'package:silvertouch/database/tb_reminder.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/NotificationManager.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/multipart_request_with_progress.dart';
import 'package:silvertouch/utils/progress_dialog.dart';
import 'package:silvertouch/utils/progress_dialog_with_percentage.dart';

final TextEditingController reminderDetailsController = TextEditingController();

class AddReminderScreen extends StatelessWidget {
  final TbReminderTable reminder;
  final NotificationManager notificationManager = NotificationManager();

  AddReminderScreen(this.reminder);

  bool built = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    debugPrint("reminder table - ${reminder.fromTime} , ${reminder.toTime}");
    debugPrint("reminder table - ${reminder.onceTime}");
    ReminderListController reminderListController = Get.find();
    AddReminderController addReminderController =
        Get.put(AddReminderController(reminder));
    if (!built) {
      if (reminder.desc == "null") {
        setReminderDetails();
        /*if (reminder.category == "Other")
          reminderDetailsController.text = "";
        else
          reminderDetailsController.text = reminder.category;*/
      } else
        reminderDetailsController.text = reminder.desc!;
      built = true;
    }
    //addReminderController.setReminder(reminder);
    /*addReminderController.reminderDetailsController.value.text =
        reminder.category != "Other" ? reminder.category : "";*/

    void _handleRadioValueChange(value) {
      addReminderController.reminderRadioValue.value = value;
    }

    void updateQuery() {
      reminderListController.updateReminder(TbReminderTable(
        reminderID: reminder.reminderID,
        notificationID: reminder.reminderID!,
        category: reminder.category,
        desc: reminderDetailsController.text,
        isReminderOn: reminder.reminderID == null
            ? true
            : addReminderController.reminderOnOff.value,
        isOnceOrFrequent: isOnceOrFrequent(addReminderController),
        onceTime: onceTime(addReminderController),
        fromTime: fromTime(addReminderController),
        toTime: toTime(addReminderController),
        frequentlyEveryHours:
            cleanParseInt(addReminderController.remindEveryHour.value),
        entryTime: DateTime.now(),
      ));
      notificationLogic(
          addReminderController, reminder.reminderID!, reminderListController);
    }

    void insertQuery() async {
      int reminderID =
          await reminderListController.insertReminder(TbReminderTable(
        notificationID: 0,
        category: reminder.category,
        desc: reminderDetailsController.text,
        isReminderOn: true /*addReminderController.reminderOnOff.value*/,
        isOnceOrFrequent: isOnceOrFrequent(addReminderController),
        onceTime: onceTime(addReminderController),
        fromTime: fromTime(addReminderController),
        toTime: toTime(addReminderController),
        frequentlyEveryHours:
            cleanParseInt(addReminderController.remindEveryHour.value),
        entryTime: DateTime.now(),
      ));

      notificationLogic(
          addReminderController, reminderID, reminderListController);
    }

    void validateAndSubmitReminder(context) {
      if (addReminderController.reminderRadioValue.value == -1) {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please select Reminder type first."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      } else {
        String hoursStr = addReminderController.remindEveryHour.value
            .replaceFirst("Hours", "")
            .replaceFirst("Hour", "")
            .trim();
        debugPrint("hours - $hoursStr");
        int hours;
        if (hoursStr.toLowerCase() == "x")
          hours = -1;
        else
          hours = int.parse(hoursStr);
        if (addReminderController.reminderRadioValue.value == 0 &&
            (hours == 0 || hours < 0)) {
          final snackBar = SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please select Hours to repeat"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
      }

      if (reminder.category != "Other") {
        updateQuery();
      } else {
        if (reminder.reminderID == null)
          insertQuery();
        else
          updateQuery();
      }
      Navigator.of(context).pop();
    }

    titleColorForFromTo() {
      return addReminderController.isFromTimeToTimeType()
          ? Colors.black
          : Colors.grey;
    }

    timeColorForFromTo() {
      return addReminderController.isFromTimeToTimeType()
          ? Colors.red
          : Colors.grey;
    }

    titleColorForRemindOnce() {
      return addReminderController.isRemindOnceType()
          ? Colors.black
          : Colors.grey;
    }

    timeColorForRemindOnce() {
      return addReminderController.isRemindOnceType()
          ? Colors.red
          : Colors.grey;
    }

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: SizeConfig.blockSizeVertical! * 15,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reminder",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ).paddingOnly(
                  bottom: SizeConfig.blockSizeVertical! * 1.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(
                      () => Switch(
                          activeColor: Colors.green,
                          value: addReminderController.reminderOnOff.value,
                          onChanged: (isOn) {
                            addReminderController.reminderOnOff.value = isOn;
                          }),
                    ).paddingOnly(
                      right: SizeConfig.blockSizeHorizontal! * 3.0,
                    ),
                    MaterialButton(
                      //minWidth: SizeConfig.screenWidth,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          side: BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          )),
                      onPressed: () {
                        validateAndSubmitReminder(context);
                      },
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          /*actions: [
            Obx(() =>
                Switch(
                activeColor: Colors.white,
                value: addReminderController.reminderOnOff.value,
                onChanged: (isOn) {
                  addReminderController.reminderOnOff.value = isOn;
                }))
          ],*/
        ),
        body: Builder(
          builder: (context) {
            return ColoredBox(
                color: Colors.white,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${reminder.category} Reminder",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.blockSizeHorizontal! * 6.0,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          .paddingOnly(
                            bottom: SizeConfig.blockSizeVertical! * 1.5,
                            top: SizeConfig.blockSizeVertical! * 1.0,
                          )
                          .paddingSymmetric(
                              horizontal:
                                  SizeConfig.blockSizeHorizontal! * 5.0),
                      Expanded(
                          child: Obx(() => ListView(
                                shrinkWrap: true,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.blockSizeHorizontal! *
                                                5.0),
                                    child: TextField(
                                      controller: reminderDetailsController,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              SizeConfig.blockSizeVertical! *
                                                  2.3),
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.3),
                                        labelStyle: TextStyle(
                                            color: Colors.green,
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                    2.3),
                                        labelText: "Reminder Details",
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: SizeConfig.blockSizeVertical! * 2.0,
                                  ),
                                  RadioListTile(
                                    value: 0,
                                    groupValue: addReminderController
                                        .reminderRadioValue.value,
                                    onChanged: _handleRadioValueChange,
                                    title: Row(
                                      children: [
                                        Text("From  ",
                                            style: TextStyle(
                                                color: titleColorForFromTo(),
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4)),
                                        InkWell(
                                          onTap: () async {
                                            addReminderController
                                                .showTimeSelectionDialog(
                                                    context, "fromTime");
                                          },
                                          child: Text(
                                            addReminderController
                                                .fromTimeStr.value,
                                            style: TextStyle(
                                              color: timeColorForFromTo(),
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.5,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  1.0,
                                        ),
                                        Text("  To   ",
                                            style: TextStyle(
                                                color: titleColorForFromTo(),
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4)),
                                        InkWell(
                                          onTap: () async {
                                            addReminderController
                                                .showTimeSelectionDialog(
                                                    context, "toTime");
                                          },
                                          child: Text(
                                            addReminderController
                                                .toTimeStr.value,
                                            style: TextStyle(
                                              color: timeColorForFromTo(),
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.5,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  addReminderController.isFromTimeToTimeType()
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  18.0,
                                            ),
                                            Text("Remind every  ",
                                                style: TextStyle(
                                                    color:
                                                        titleColorForFromTo(),
                                                    fontSize: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        4)),
                                            InkWell(
                                                onTap: () {
                                                  showHoursSelectionDialog(
                                                      context);
                                                },
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      addReminderController
                                                          .remindEveryHour
                                                          .value,
                                                      style: TextStyle(
                                                        color:
                                                            timeColorForFromTo(),
                                                        fontSize: SizeConfig
                                                                .blockSizeHorizontal! *
                                                            4.5,
                                                      ),
                                                    ),
                                                    /*SizedBox(
                                        width: SizeConfig.blockSizeHorizontal *
                                            1.0,
                                      ),
                                      Text(
                                        "Hour",
                                        style: TextStyle(
                                          color: timeColorForFromTo(),
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  4.5,
                                        ),
                                      ),*/
                                                    SizedBox(
                                                      width: SizeConfig
                                                              .blockSizeHorizontal! *
                                                          1.0,
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )
                                      : Container(),
                                  RadioListTile(
                                    value: 1,
                                    groupValue: addReminderController
                                        .reminderRadioValue.value,
                                    onChanged: _handleRadioValueChange,
                                    title: Row(
                                      children: [
                                        Text("Remind me once at  ",
                                            style: TextStyle(
                                                color:
                                                    titleColorForRemindOnce(),
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    4)),
                                        InkWell(
                                          onTap: () {
                                            addReminderController
                                                .showTimeSelectionDialog(
                                                    context, "onceTime");
                                          },
                                          child: Text(
                                            addReminderController
                                                .remindOnceTimeStr.value,
                                            style: TextStyle(
                                              color: timeColorForRemindOnce(),
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  4.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))),
                      /*MaterialButton(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0,)),
                    onPressed: () {
                      validateAndSubmitReminder(context);
                    },
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),*/
                    ]));
          },
        ));
  }

  void showHoursSelectionDialog(BuildContext context) {
    AddReminderController addReminderController = Get.find();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  height: SizeConfig.blockSizeVertical! * 8,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.red,
                            size: SizeConfig.blockSizeHorizontal! * 6.2,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 50,
                          height: SizeConfig.blockSizeVertical! * 8,
                          child: Center(
                            child: Text(
                              "Hours",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                        itemCount: addReminderController.listHours!.length,
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                addReminderController.remindEveryHour.value =
                                    addReminderController.listHours![index]!;
                                //setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 90,
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                        left: 5,
                                        right: 5,
                                      ),
                                      decoration: new BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 2.0, color: Colors.grey),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 10.0,
                                            offset: const Offset(0.0, 10.0),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          addReminderController
                                              .listHours![index]!,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ))));
                        }),
                  ),
                ),
                /*Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ))*/
              ],
            )));
  }

  int cleanParseInt(String text) {
    return int.parse(
        text.replaceFirst("Hours", "").replaceFirst("Hour", "").trim());
  }

  void scheduleNewNotificationOnceDaily(
      int reminderID,
      NotificationManager notificationManager,
      AddReminderController addReminderController,
      ReminderListController reminderListController) {
    /*reminderListController.insertNotification(
        TbNotificationTable(reminderID: reminderID,
            shootTime: dateTimeFromTimeOfDay(
                addReminderController.pickedOnceTime.value)));*/
    notificationManager.showNotificationDaily(
      reminderID,
      addReminderController.reminder.value.category,
      reminderDetailsController.text,
      addReminderController.pickedOnceTime.value,
    );
  }

  void scheduleNewNotificationEveryHours(
      int reminderID,
      NotificationManager notificationManager,
      AddReminderController addReminderController,
      ReminderListController reminderListController) {
    debugPrint(addReminderController.pickedFromTime.value.toString() +
        " " +
        addReminderController.pickedToTime.value.toString() +
        " " +
        cleanParseInt(addReminderController.remindEveryHour.value).toString());
    notificationManager.showNotificationDailyAtSpecifiedInterval(
      reminderID,
      addReminderController.reminder.value.category,
      reminderDetailsController.text,
      addReminderController.pickedFromTime.value,
      addReminderController.pickedToTime.value,
      cleanParseInt(addReminderController.remindEveryHour.value),
    );
  }

  void removeReminder(NotificationManager notificationManager, int reminderID) {
    notificationManager.removeReminder(reminderID);
  }

  void notificationLogic(AddReminderController addReminderController,
      int reminderID, ReminderListController reminderListController) async {
    if (addReminderController.reminderOnOff.value) {
      if (addReminderController.reminderRadioValue.value == 1)
        scheduleNewNotificationOnceDaily(reminderID, notificationManager,
            addReminderController, reminderListController);
      else
        scheduleNewNotificationEveryHours(reminderID, notificationManager,
            addReminderController, reminderListController);
    } else {
      List<TbNotificationTable> listNotifications = await reminderListController
          .getNotificationsWithReminderID(reminderID);
      for (int i = 0; i < listNotifications.length; i++) {
        removeReminder(
            notificationManager, listNotifications[i].notificationID!);
      }
    }
  }

  void setReminderDetails() {
    switch (reminder.category) {
      case "Water":
        reminderDetailsController.text = "Drink Water";
        break;
      case "Food":
        reminderDetailsController.text = "Take Food";
        break;
      case "Exercise":
        reminderDetailsController.text = "Do Exercise";
        break;
      case "Medicine":
        reminderDetailsController.text = "Take Medicine";
        break;
      case "Other":
        reminderDetailsController.text = "Remind me for";
        break;
    }
  }

  toTime(AddReminderController addReminderController) {
    addReminderController.reminderRadioValue.value == 0
        ? dateTimeFromTimeOfDay(addReminderController.pickedToTime.value)
        : null;
  }

  isOnceOrFrequent(AddReminderController addReminderController) {
    addReminderController.reminderRadioValue.value == 1
        ? true
        : addReminderController.reminderRadioValue.value == 0
            ? false
            : null;
  }

  onceTime(AddReminderController addReminderController) {
    addReminderController.reminderRadioValue.value == 1
        ? dateTimeFromTimeOfDay(addReminderController.pickedOnceTime.value)
        : null;
  }

  fromTime(AddReminderController addReminderController) {
    addReminderController.reminderRadioValue.value == 0
        ? dateTimeFromTimeOfDay(addReminderController.pickedFromTime.value)
        : null;
  }
}

/*class AddReminderScreenState extends State<AddReminderScreen> {
  @override

}*/
