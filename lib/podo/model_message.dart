import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String? chatIDP,
      patientIDP,
      doctorIDP,
      messageContent,
      imageStatus,
      imageName,
      date,
      time,
      dateFormatted,
      timeFormatted,
      messageFrom,
      videoCallRequestStatus,
      videoCallStartedStatus,
      healthRecordsDisplayStatus,
      notificationDisplayStatus,
      audioCallRequestStatus,
      audioCallStartedStatus;

  Message({
    this.chatIDP,
    this.patientIDP,
    this.doctorIDP,
    this.messageContent,
    this.imageStatus,
    this.imageName,
    this.date,
    this.time,
    this.dateFormatted,
    this.timeFormatted,
    this.messageFrom,
    this.videoCallRequestStatus,
    this.videoCallStartedStatus,
    this.audioCallRequestStatus,
    this.audioCallStartedStatus,
    this.healthRecordsDisplayStatus,
    this.notificationDisplayStatus,
  });

  @override
  List<Object> get props => [
        this.chatIDP!,
        this.patientIDP!,
        this.doctorIDP!,
        this.messageContent!,
        this.imageStatus!,
        this.imageName!,
        this.date!,
        this.time!,
        this.dateFormatted!,
        this.timeFormatted!,
        this.messageFrom!,
        this.videoCallRequestStatus!,
        this.videoCallStartedStatus!,
        this.healthRecordsDisplayStatus!,
        this.notificationDisplayStatus!,
        this.audioCallRequestStatus!,
        this.audioCallStartedStatus!,
      ];
}
