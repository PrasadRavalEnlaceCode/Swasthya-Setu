import 'package:moor_flutter/moor_flutter.dart';

part 'tb_notifications.g.dart';

@DataClassName('TbNotificationTable')
class TbNotification extends Table {
  IntColumn get notificationID => integer().autoIncrement()();

  IntColumn get reminderID => integer()();

  DateTimeColumn get shootTime => dateTime().nullable()();

  DateTimeColumn get entryTime => dateTime().nullable()();
}

@UseMoor(tables: [TbNotification])
class AppDatabaseNotification extends _$AppDatabaseNotification {
  /*AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqplite', logStatements: true));*/
  AppDatabaseNotification()
      : super(FlutterQueryExecutor.inDatabaseFolder(
    path: 'db_notification.sqlite',
    logStatements: true,
  ));

  @override
  int get schemaVersion => 1;

  Future<List<TbNotificationTable>> getAllNotifications() {
    return select(tbNotification).get();
  }

  Future<List<TbNotificationTable>> getNotificationsWithReminderID(
      int reminderID) {
    return (select(tbNotification)
      ..where((tbl) => tbl.reminderID.equals(reminderID)))
        .get();
  }

  Future<
      List<TbNotificationTable>> getNotificationsWithReminderIDAndBetweenTimes(
      int reminderID, DateTime fromTime, DateTime toTime) {
    return (select(tbNotification)
      ..where((tbl) =>
      tbl.reminderID.equals(reminderID) &
      tbl.shootTime.isBiggerOrEqualValue(fromTime) &
      tbl.shootTime.isSmallerThanValue(toTime)))
        .get();
  }

  Future<int> insertNotification(TbNotificationTable tb) =>
      into(tbNotification).insert(tb);

  Future<bool> updateNotification(TbNotificationTable tb) =>
      update(tbNotification).replace(tb);

  deleteNotification(TbNotificationTable tb, int reminderID) =>
      (delete(tbNotification)
        ..where((tbl) => tbl.reminderID.equals(reminderID)))
          .go();
}
