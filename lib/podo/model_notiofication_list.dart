import 'package:silvertouch/podo/model_notification_patient_data.dart';

class ModelNotificationList {
  String? notificationIDP, patientIDP, type, title, desc, idf, imgUrl;
  String? notificationType;
  ModelNotificationPatientData? modelNotificationPatientData;

  ModelNotificationList(
    String notificationIDP,
    String patientIDP,
    String type,
    String title,
    String message,
    String idf,
    String imgUrl, {
    this.notificationType,
    this.modelNotificationPatientData,
  }) {
    this.notificationIDP = notificationIDP;
    this.patientIDP = patientIDP;
    this.type = type;
    this.title = title;
    this.desc = message;
    this.idf = idf;
    this.imgUrl = imgUrl;
  }
}
