
import 'package:moor_flutter/moor_flutter.dart';

part 'tb_reminder.g.dart';

@DataClassName('TbReminderTable')
class TbReminder extends Table {
  IntColumn get reminderID => integer().autoIncrement()();

  IntColumn get notificationID => integer()();

  TextColumn get category => text().withLength(min: 1, max: 50)();

  TextColumn get desc => text().nullable().withLength(min: 0, max: 2000)();

  BoolColumn get isReminderOn => boolean().withDefault(Constant(false))();

  BoolColumn get isOnceOrFrequent => boolean().withDefault(Constant(false))();

  DateTimeColumn get onceTime => dateTime().nullable()();

  DateTimeColumn get fromTime => dateTime().nullable()();

  DateTimeColumn get toTime => dateTime().nullable()();

  DateTimeColumn get entryTime => dateTime().nullable()();

  IntColumn get frequentlyEveryHours => integer().nullable()();
}

@UseMoor(tables: [TbReminder])
class AppDatabase extends _$AppDatabase {
  /*AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'db.sqplite', logStatements: true));*/
  AppDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          logStatements: true,
        ));

  @override
  int get schemaVersion => 1;

  Future<List<TbReminderTable>> getAllActiveReminders() {
    return (select(tbReminder)..where((tb1) => tb1.isReminderOn.equals(true)))
        .get();
    /*(select(tbReminder)
          ..orderBy([(t) => OrderingTerm.asc(t.isReminderOn)]))
        .get();*/
  }

  /*Future<List<TbReminderTable>> getAllActiveRemindersThisHour() {
    DateTime now = DateTime.now();
    DateTime oneHourLater = now.add(Duration(hours: 1));
    return (select(tbReminder)
          ..where((tb1) =>
              tb1.isReminderOn.equals(true) &
              tb1.fromTime.isSmallerOrEqualValue(now) & tb1.toTime))
        .get();
  }*/

  Future<List<TbReminderTable>> getAllInactiveReminders() {
    return (select(tbReminder)
          ..where((tb1) => tb1.isReminderOn.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.entryTime)]))
        .get();
    /*return (select(tbReminder)
      ..orderBy([(t) => OrderingTerm.asc(t.isReminderOn)]))
        .get();*/
  }

  Future<int> insertReminder(TbReminderTable tb) => into(tbReminder).insert(tb);

  Future<bool> updateReminder(TbReminderTable tb) =>
      update(tbReminder).replace(tb);

  Future<int> deleteReminder(TbReminderTable tb) =>
      (delete(tbReminder)..where((tbl) => tbl.reminderID.equals(tb.reminderID!)))
          .go();
}
