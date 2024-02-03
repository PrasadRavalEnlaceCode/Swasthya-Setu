// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_notifications.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class TbNotificationTable extends DataClass
    implements Insertable<TbNotificationTable> {
  final int? notificationID;
  final int reminderID;
  final DateTime? shootTime;
  final DateTime? entryTime;
  TbNotificationTable(
      {this.notificationID,
      required this.reminderID,
      this.shootTime,
      this.entryTime});
  factory TbNotificationTable.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TbNotificationTable(
      notificationID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}notification_i_d'])!,
      reminderID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reminder_i_d'])!,
      shootTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}shoot_time']),
      entryTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}entry_time']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_i_d'] = Variable<int>(notificationID!);
    map['reminder_i_d'] = Variable<int>(reminderID);
    if (!nullToAbsent || shootTime != null) {
      map['shoot_time'] = Variable<DateTime?>(shootTime);
    }
    if (!nullToAbsent || entryTime != null) {
      map['entry_time'] = Variable<DateTime?>(entryTime);
    }
    return map;
  }

  TbNotificationCompanion toCompanion(bool nullToAbsent) {
    return TbNotificationCompanion(
      notificationID: Value(notificationID!),
      reminderID: Value(reminderID),
      shootTime: shootTime == null && nullToAbsent
          ? const Value.absent()
          : Value(shootTime),
      entryTime: entryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(entryTime),
    );
  }

  factory TbNotificationTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TbNotificationTable(
      notificationID: serializer.fromJson<int>(json['notificationID']),
      reminderID: serializer.fromJson<int>(json['reminderID']),
      shootTime: serializer.fromJson<DateTime?>(json['shootTime']),
      entryTime: serializer.fromJson<DateTime?>(json['entryTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationID': serializer.toJson<int>(notificationID!),
      'reminderID': serializer.toJson<int>(reminderID),
      'shootTime': serializer.toJson<DateTime?>(shootTime),
      'entryTime': serializer.toJson<DateTime?>(entryTime),
    };
  }

  TbNotificationTable copyWith(
          {int? notificationID,
          int? reminderID,
          DateTime? shootTime,
          DateTime? entryTime}) =>
      TbNotificationTable(
        notificationID: notificationID ?? this.notificationID,
        reminderID: reminderID ?? this.reminderID,
        shootTime: shootTime ?? this.shootTime,
        entryTime: entryTime ?? this.entryTime,
      );
  @override
  String toString() {
    return (StringBuffer('TbNotificationTable(')
          ..write('notificationID: $notificationID, ')
          ..write('reminderID: $reminderID, ')
          ..write('shootTime: $shootTime, ')
          ..write('entryTime: $entryTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(notificationID, reminderID, shootTime, entryTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TbNotificationTable &&
          other.notificationID == this.notificationID &&
          other.reminderID == this.reminderID &&
          other.shootTime == this.shootTime &&
          other.entryTime == this.entryTime);
}

class TbNotificationCompanion extends UpdateCompanion<TbNotificationTable> {
  final Value<int> notificationID;
  final Value<int> reminderID;
  final Value<DateTime?> shootTime;
  final Value<DateTime?> entryTime;
  const TbNotificationCompanion({
    this.notificationID = const Value.absent(),
    this.reminderID = const Value.absent(),
    this.shootTime = const Value.absent(),
    this.entryTime = const Value.absent(),
  });
  TbNotificationCompanion.insert({
    this.notificationID = const Value.absent(),
    required int reminderID,
    this.shootTime = const Value.absent(),
    this.entryTime = const Value.absent(),
  }) : reminderID = Value(reminderID);
  static Insertable<TbNotificationTable> custom({
    Expression<int>? notificationID,
    Expression<int>? reminderID,
    Expression<DateTime?>? shootTime,
    Expression<DateTime?>? entryTime,
  }) {
    return RawValuesInsertable({
      if (notificationID != null) 'notification_i_d': notificationID,
      if (reminderID != null) 'reminder_i_d': reminderID,
      if (shootTime != null) 'shoot_time': shootTime,
      if (entryTime != null) 'entry_time': entryTime,
    });
  }

  TbNotificationCompanion copyWith(
      {Value<int>? notificationID,
      Value<int>? reminderID,
      Value<DateTime?>? shootTime,
      Value<DateTime?>? entryTime}) {
    return TbNotificationCompanion(
      notificationID: notificationID ?? this.notificationID,
      reminderID: reminderID ?? this.reminderID,
      shootTime: shootTime ?? this.shootTime,
      entryTime: entryTime ?? this.entryTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationID.present) {
      map['notification_i_d'] = Variable<int>(notificationID.value);
    }
    if (reminderID.present) {
      map['reminder_i_d'] = Variable<int>(reminderID.value);
    }
    if (shootTime.present) {
      map['shoot_time'] = Variable<DateTime?>(shootTime.value);
    }
    if (entryTime.present) {
      map['entry_time'] = Variable<DateTime?>(entryTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TbNotificationCompanion(')
          ..write('notificationID: $notificationID, ')
          ..write('reminderID: $reminderID, ')
          ..write('shootTime: $shootTime, ')
          ..write('entryTime: $entryTime')
          ..write(')'))
        .toString();
  }
}

class $TbNotificationTable extends TbNotification
    with TableInfo<$TbNotificationTable, TbNotificationTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TbNotificationTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _notificationIDMeta =
      const VerificationMeta('notificationID');
  @override
  late final GeneratedColumn<int?> notificationID = GeneratedColumn<int?>(
      'notification_i_d', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _reminderIDMeta = const VerificationMeta('reminderID');
  @override
  late final GeneratedColumn<int?> reminderID = GeneratedColumn<int?>(
      'reminder_i_d', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _shootTimeMeta = const VerificationMeta('shootTime');
  @override
  late final GeneratedColumn<DateTime?> shootTime = GeneratedColumn<DateTime?>(
      'shoot_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _entryTimeMeta = const VerificationMeta('entryTime');
  @override
  late final GeneratedColumn<DateTime?> entryTime = GeneratedColumn<DateTime?>(
      'entry_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [notificationID, reminderID, shootTime, entryTime];
  @override
  String get aliasedName => _alias ?? 'tb_notification';
  @override
  String get actualTableName => 'tb_notification';
  @override
  VerificationContext validateIntegrity(
      Insertable<TbNotificationTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notification_i_d')) {
      context.handle(
          _notificationIDMeta,
          notificationID.isAcceptableOrUnknown(
              data['notification_i_d']!, _notificationIDMeta));
    }
    if (data.containsKey('reminder_i_d')) {
      context.handle(
          _reminderIDMeta,
          reminderID.isAcceptableOrUnknown(
              data['reminder_i_d']!, _reminderIDMeta));
    } else if (isInserting) {
      context.missing(_reminderIDMeta);
    }
    if (data.containsKey('shoot_time')) {
      context.handle(_shootTimeMeta,
          shootTime.isAcceptableOrUnknown(data['shoot_time']!, _shootTimeMeta));
    }
    if (data.containsKey('entry_time')) {
      context.handle(_entryTimeMeta,
          entryTime.isAcceptableOrUnknown(data['entry_time']!, _entryTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationID};
  @override
  TbNotificationTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TbNotificationTable.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $TbNotificationTable createAlias(String alias) {
    return $TbNotificationTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabaseNotification extends GeneratedDatabase {
  _$AppDatabaseNotification(QueryExecutor e)
      : super(SqlTypeSystem.defaultInstance, e);
  late final $TbNotificationTable tbNotification = $TbNotificationTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tbNotification];
}
