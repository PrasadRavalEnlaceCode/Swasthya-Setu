import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swasthyasetu/database/tb_reminder.dart';
import 'package:swasthyasetu/global/utils.dart' as utils;

class AddReminderController extends GetxController {
  Rx<TbReminderTable> reminder = TbReminderTable(
          reminderID: 0,
          notificationID: 0,
          category: "0",
          isReminderOn: false,
          isOnceOrFrequent: false)
      .obs;

  /*= TbReminderTable(
      reminderID: null,
      notificationID: 0,
      category: "",
      isReminderOn: null,
      isOnceOrFrequent: null);*/

  AddReminderController(TbReminderTable reminder) {
    this.reminder.value = reminder;
    debugPrint(
        "controller - ${this.reminder.value.fromTime} , ${this.reminder.value.toTime}");
    debugPrint("controller - ${this.reminder.value.onceTime}");
    //setReminderDefaultValues();
  }

  RxInt reminderRadioValue = (-1).obs;
  RxString fromTimeStr = "9:00 AM".obs;
  RxString toTimeStr = "9:00 PM".obs;
  RxBool reminderOnOff = false.obs;
  RxString remindEveryHour = "1 Hour".obs;
  RxString remindOnceTimeStr = "9:00 AM".obs;
  Rx<TextEditingController> reminderDetailsController =
      TextEditingController().obs;
  Rx<TimeOfDay> pickedFromTime =
      TimeOfDay.now().replacing(hour: 9, minute: 0).obs;
  Rx<TimeOfDay> pickedToTime =
      TimeOfDay.now().replacing(hour: 21, minute: 0).obs;
  Rx<TimeOfDay> pickedOnceTime =
      TimeOfDay.now().replacing(hour: 9, minute: 0).obs;
  RxList<String?>? listHours = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint("onit called");
    setReminderDefaultValues();
    addHoursToList();
    //setReminderDefaultValues();
  }

  @override
  void onReady() {
    debugPrint("on ready called");
    super.onReady();
  }

  @override
  void onClose() {
    debugPrint("closing add controller");
    resetAll();
    super.onClose();
  }

  setReminder(TbReminderTable reminder) {
    this.reminder.value = reminder;
    //setReminderDefaultValues();
  }

  bool isFromTimeToTimeType() {
    return reminderRadioValue.value == 0;
  }

  bool isRemindOnceType() {
    return reminderRadioValue.value == 1;
  }

  void insertOrUpdateReminder() async {}

  showTimeSelectionDialog(BuildContext context, String type) async {
    if (type == "fromTime") {
      reminderRadioValue.value = 0;
      final time =
          await utils.showTimeSelectionDialog(context, pickedFromTime.value);
      pickedFromTime.value = time;
      fromTimeStr.value = utils.getFormattedTimeInStrFromTimeOfDay(time);
      addHoursToList();
    } else if (type == "toTime") {
      reminderRadioValue.value = 0;
      final time =
          await utils.showTimeSelectionDialog(context, pickedToTime.value);
      pickedToTime.value = time;
      toTimeStr.value = utils.getFormattedTimeInStrFromTimeOfDay(time);
      addHoursToList();
    } else if (type == "onceTime") {
      reminderRadioValue.value = 1;
      final time =
          await utils.showTimeSelectionDialog(context, pickedOnceTime.value);
      pickedOnceTime.value = time;
      remindOnceTimeStr.value =
          utils.getFormattedTimeInStrFromTimeOfDay(time);
    }
  }

  void addHoursToList() {
    /* if (reminder.value.category == "Other") {
      if (reminder.value.desc == "null")
      reminderDetailsController.value = TextEditingController(text: "");
      else
    } else {*/
    if (reminder.value.desc == "null") {
      if (reminder.value.category == "Other")
        reminderDetailsController.value = TextEditingController(text: "");
      else
        reminderDetailsController.value =
            TextEditingController(text: reminder.value.category);
    }
    //reminderDetailsController.value.text = reminder.value.category;
    else
      reminderDetailsController.value =
          TextEditingController(text: reminder.value.desc);
    /*}*/

    /*reminderDetailsController.value.text =
        reminder.value.category != "Other" ? reminder.value.desc : "";*/
    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day,
        pickedFromTime.value.hour, pickedFromTime.value.minute);
    DateTime toDate = DateTime(now.year, now.month, now.day,
        pickedToTime.value.hour, pickedToTime.value.minute);
    Duration duration;
    duration = toDate.difference(fromDate);
    int totalHours = duration.inHours;
    int totalMins = duration.inMinutes;
    debugPrint("hours difference - $totalHours");
    debugPrint("mins difference - $totalMins");
    listHours = <String>[].obs;

    /*if (totalHours < 0) {
      DateFormat formatter = new DateFormat('a');
      String suffixFrom = formatter.format(fromDate);
      String suffixTo = formatter.format(toDate);
      if (suffixFrom == "PM")
    }*/
    if (totalHours == 0) remindEveryHour.value = "X Hours";
    /*else
      remindEveryHour.value = "1 Hour";*/
    //if (totalMins % 60 == 0) totalHours--;
    String prefix;
    for (int i = 0; i < totalHours; i++) {
      if (i == 0)
        prefix = "Hour";
      else
        prefix = "Hours";
        listHours!.add("${(i + 1).toString()} $prefix");
      /*if (i != listHours.length - 1)
        listHours.add((i + 1).toString());
      else
        listHours.add((i).toString());*/
    }
  }

  void setReminderDefaultValues() {
    if (reminder.value.isOnceOrFrequent == null)
      reminderRadioValue.value = -1;
    else if (reminder.value.isOnceOrFrequent == false)
      reminderRadioValue.value = 0;
    else if (reminder.value.isOnceOrFrequent == true)
      reminderRadioValue.value = 1;
    /*reminderRadioValue.value = reminder.value.isOnceOrFrequent == null
        ? -1
        : reminder.value.isOnceOrFrequent == true
        ? 0
        : 1;*/
    reminderOnOff.value = reminder.value.isReminderOn;
    String prefix;
    if (reminder.value.frequentlyEveryHours == 1)
      prefix = "Hour";
    else
      prefix = "Hours";
    debugPrint("hours - ${reminder.value.frequentlyEveryHours}");

    remindEveryHour.value = "${reminder.value.frequentlyEveryHours} $prefix";

    //reminderDetailsController.value.text = reminder.value.desc;

    fromTimeStr.value = utils.getFormattedTimeInStrFromTimeOfDay(
        TimeOfDay.fromDateTime(reminder.value.fromTime!));

    // This should change also desc
    pickedFromTime.value = TimeOfDay.now().replacing(
        hour: reminder.value.fromTime!.hour,
        minute: reminder.value.fromTime!.minute);

    toTimeStr.value = utils.getFormattedTimeInStrFromTimeOfDay(
        TimeOfDay.fromDateTime(reminder.value.toTime!));
    pickedToTime.value = TimeOfDay.now().replacing(
        hour: reminder.value.toTime!.hour,
        minute: reminder.value.toTime!.minute);

    remindOnceTimeStr.value = utils.getFormattedTimeInStrFromTimeOfDay(
        TimeOfDay.fromDateTime(reminder.value.onceTime!));
    pickedOnceTime.value = TimeOfDay.now().replacing(
        hour: reminder.value.onceTime!.hour,
        minute: reminder.value.onceTime!.minute);

    debugPrint("controller - ${pickedFromTime.value} , ${pickedToTime.value}");
    debugPrint("controller - ${pickedOnceTime.value}");
    debugPrint("str - ${fromTimeStr.value} , ${toTimeStr.value}");
    debugPrint("str - ${remindOnceTimeStr.value}");
    update();
    /*RxString fromTimeStr = "9:00 AM".obs;*/
    /*RxString toTimeStr = "9:00 PM".obs;
    RxString remindOnceTimeStr = "9:00 AM".obs;*/
  }

  void resetAll() {
    reminder.close();
    reminderRadioValue.close(); // = (-1).obs;
    fromTimeStr.close(); //= "9:00 AM".obs;
    toTimeStr.close(); //= "9:00 PM".obs;
    reminderOnOff.close(); //= false.obs;
    remindEveryHour.close(); //= "1 Hour".obs;
    remindOnceTimeStr.close(); //= "9:00 AM".obs;
    reminderDetailsController.close(); //=TextEditingController().obs;
    pickedFromTime
        .close(); //= TimeOfDay.now().replacing(hour: 9, minute: 0).obs;
    pickedToTime
        .close(); //= TimeOfDay.now().replacing(hour: 21, minute: 0).obs;
    pickedOnceTime
        .close(); //= TimeOfDay.now().replacing(hour: 9, minute: 0).obs;
    listHours!.close(); //= List<String>().obs;
  }
}
