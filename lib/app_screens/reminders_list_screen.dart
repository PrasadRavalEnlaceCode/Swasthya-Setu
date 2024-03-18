import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/app_screens/add_reminder_screen.dart';
import 'package:silvertouch/controllers/reminder_list_controller.dart';
import 'package:silvertouch/database/tb_reminder.dart';
import 'package:silvertouch/global/SizeConfig.dart';
import 'package:silvertouch/global/utils.dart';
import 'package:silvertouch/podo/model_profile_patient.dart';
import 'package:silvertouch/podo/response_main_model.dart';
import 'package:silvertouch/utils/color.dart';
import 'package:silvertouch/utils/progress_dialog.dart';

import 'package:silvertouch/global/utils.dart' as utils;

class RemindersListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ReminderListController reminderListController =
        Get.put(ReminderListController());

    TbReminderTable reminderOther = TbReminderTable(
      reminderID: 0,
      notificationID: 5,
      category: "Other",
      desc: "null",
      isReminderOn: false,
      isOnceOrFrequent: false,
      onceTime: reminderListController.dateTimeWithHourAndMinute(9, 0),
      fromTime: reminderListController.dateTimeWithHourAndMinute(9, 0),
      toTime: reminderListController.dateTimeWithHourAndMinute(21, 0),
      frequentlyEveryHours: 1,
      entryTime: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Reminders"),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            AddTodoScreen(),
            transition: Transition.downToUp,
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),*/
      body: Container(
        child: Obx(() {
          if (reminderListController.isLoading.value)
            return Center(
              child: CircularProgressIndicator(),
            );
          else
            /*if (reminderListController.activeReminderList.length > 0)*/
            return ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                    vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  child: Text(
                    "Active Reminders",
                    style: TextStyle(
                      color: Colors.red[300],
                      fontWeight: FontWeight.w500,
                      fontSize: SizeConfig.blockSizeHorizontal! * 5.0,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                reminderListController.activeReminderList.length > 0
                    ? ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          TbReminderTable? reminder =
                              reminderListController.activeReminderList[index];
                          return ListTile(
                            onTap: () {
                              debugPrint(reminder!.fromTime.toString() +
                                  " " +
                                  reminder.toTime.toString());
                              debugPrint(reminder.onceTime.toString());
                              /*Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AddReminderScreen(reminder);
                              }));*/
                              Get.to(() => AddReminderScreen(reminder));
                            },
                            title: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    color: Colors.blue,
                                    size: SizeConfig.blockSizeHorizontal! * 8.0,
                                  ),
                                  SizedBox(
                                    width:
                                        SizeConfig.blockSizeHorizontal! * 4.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: reminder!.desc != "null"
                                              ? 0
                                              : SizeConfig.blockSizeVertical! *
                                                  1.5,
                                        ),
                                        Text(
                                          reminder.category,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4.5,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(
                                          height: reminder.desc != "null"
                                              ? SizeConfig.blockSizeVertical! *
                                                  0.5
                                              : SizeConfig.blockSizeVertical! *
                                                  1.5,
                                        ),
                                        reminder.desc != "null"
                                            ? Text(
                                                reminder.desc!,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey,
                                                  letterSpacing: 1.5,
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height:
                                              SizeConfig.blockSizeVertical! *
                                                  1.0,
                                        ),
                                        Text(
                                          textForReminder(reminder),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color:
                                                textForReminderColor(reminder),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  reminder.category == "Other"
                                      ? IconButton(
                                          onPressed: () {
                                            reminderListController
                                                .deleteReminderAndCorrespondingNotifications(
                                                    reminder);
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6.0,
                                          ),
                                          color: Colors.red,
                                        )
                                      : Container(),
                                  Text(
                                    "EDIT",
                                    style: TextStyle(
                                      color: Colors.red,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              color: Colors.white,
                              height: 1.0,
                            ),
                          );
                        },
                        itemCount:
                            reminderListController.activeReminderList.length,
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal! * 5.0,
                        ),
                        child: Text(
                          "No Active Reminders",
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 2.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 3.0,
                    vertical: SizeConfig.blockSizeHorizontal! * 3.0,
                  ),
                  child: Text(
                    "Inactive Reminders",
                    style: TextStyle(
                      color: Colors.red[300],
                      fontWeight: FontWeight.w500,
                      fontSize: SizeConfig.blockSizeHorizontal! * 5.0,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final TbReminderTable? reminder =
                        reminderListController.inactiveReminderList[index];
                    return ListTile(
                      onTap: () {
                        debugPrint(reminder!.fromTime.toString() +
                            " " +
                            reminder.toTime.toString());
                        debugPrint(reminder.onceTime.toString());
                        /*Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return AddReminderScreen(reminder);
                        }));*/
                        Get.to(() => AddReminderScreen(reminder));
                      },
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              color: Colors.blue,
                              size: SizeConfig.blockSizeHorizontal! * 8.0,
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 4.0,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: reminder!.desc != "null"
                                        ? 0
                                        : SizeConfig.blockSizeVertical! * 1.5,
                                  ),
                                  Text(
                                    reminder.category,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: reminder.desc != "null"
                                        ? SizeConfig.blockSizeVertical! * 0.5
                                        : SizeConfig.blockSizeVertical! * 1.5,
                                  ),
                                  /*Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                          top: 3,
                        ),
                        child:*/
                                  reminder.desc != "null"
                                      ? Text(
                                          reminder.desc!,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey,
                                            letterSpacing: 1.5,
                                          ),
                                        )
                                      : Container(),
                                  /*),*/
                                ],
                              ),
                            ),
                            reminder.category == "Other"
                                ? IconButton(
                                    onPressed: () {
                                      reminderListController
                                          .deleteReminderAndCorrespondingNotifications(
                                              reminder);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size:
                                          SizeConfig.blockSizeHorizontal! * 6.0,
                                    ),
                                    color: Colors.red,
                                  )
                                : Container(),
                            Text(
                              /*reminder.category != "Other" ? "EDIT" :*/
                              "ADD",
                              style: TextStyle(
                                color: Colors.red,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        color: Colors.white,
                        height: 1.0,
                      ),
                    );
                  },
                  itemCount: reminderListController.inactiveReminderList.length,
                ),
                ListTile(
                  onTap: () {
                    Get.to(() => AddReminderScreen(reminderOther));
                  },
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          color: Colors.blue,
                          size: SizeConfig.blockSizeHorizontal! * 8.0,
                        ),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 4.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: reminderOther.desc != "null"
                                    ? 0
                                    : SizeConfig.blockSizeVertical! * 1.5,
                              ),
                              Text(
                                reminderOther.category,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 4.5,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: reminderOther.desc != "null"
                                    ? SizeConfig.blockSizeVertical! * 0.5
                                    : SizeConfig.blockSizeVertical! * 1.5,
                              ),
                              reminderOther.desc != "null"
                                  ? Text(
                                      reminderOther.desc!,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Container(),
                              /*),*/
                            ],
                          ),
                        ),
                        Text(
                          /*reminder.category != "Other" ? "EDIT" :*/
                          "ADD",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          /*else return Container();*/
          /*else
            return Center(
              child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child:
                      Container()
                  ),
            );*/
        }),
      ),
    );
  }

  String textForReminder(TbReminderTable reminder) {
    if (reminder.isReminderOn) {
      if (reminder.isOnceOrFrequent)
        return "Remind Everyday at ${utils.getFormattedTimeInStrFromTimeOfDay(TimeOfDay.fromDateTime(reminder.onceTime!))}";
      else
        return "Remind Every ${reminder.frequentlyEveryHours} hour from ${utils.getFormattedTimeInStrFromTimeOfDay(TimeOfDay.fromDateTime(reminder.fromTime!))} to ${utils.getFormattedTimeInStrFromTimeOfDay(TimeOfDay.fromDateTime(reminder.toTime!))}";
    }
    return "Reminder is off.";
  }

  Color textForReminderColor(TbReminderTable reminder) {
    if (reminder.isReminderOn) {
      return Colors.green;
    }
    return Colors.red;
  }
}
