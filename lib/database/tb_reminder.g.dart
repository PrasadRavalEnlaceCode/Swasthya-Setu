// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_reminder.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: type=lint
class TbReminderTable extends DataClass implements Insertable<TbReminderTable> {
  final int? reminderID;
  final int notificationID;
  final String category;
  final String? desc;
  final bool isReminderOn;
  final bool isOnceOrFrequent;
  final DateTime? onceTime;
  final DateTime? fromTime;
  final DateTime? toTime;
  final DateTime? entryTime;
  final int? frequentlyEveryHours;
  TbReminderTable(
      {this.reminderID,
      required this.notificationID,
      required this.category,
      this.desc,
      required this.isReminderOn,
      required this.isOnceOrFrequent,
      this.onceTime,
      this.fromTime,
      this.toTime,
      this.entryTime,
      this.frequentlyEveryHours});
  factory TbReminderTable.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return TbReminderTable(
      reminderID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reminder_i_d'])!,
      notificationID: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}notification_i_d'])!,
      category: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category'])!,
      desc: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}desc']),
      isReminderOn: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_reminder_on'])!,
      isOnceOrFrequent: const BoolType().mapFromDatabaseResponse(
          data['${effectivePrefix}is_once_or_frequent'])!,
      onceTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}once_time']),
      fromTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}from_time']),
      toTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}to_time']),
      entryTime: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}entry_time']),
      frequentlyEveryHours: const IntType().mapFromDatabaseResponse(
          data['${effectivePrefix}frequently_every_hours']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reminder_i_d'] = Variable<int>(reminderID!);
    map['notification_i_d'] = Variable<int>(notificationID);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || desc != null) {
      map['desc'] = Variable<String?>(desc);
    }
    map['is_reminder_on'] = Variable<bool>(isReminderOn);
    map['is_once_or_frequent'] = Variable<bool>(isOnceOrFrequent);
    if (!nullToAbsent || onceTime != null) {
      map['once_time'] = Variable<DateTime?>(onceTime);
    }
    if (!nullToAbsent || fromTime != null) {
      map['from_time'] = Variable<DateTime?>(fromTime);
    }
    if (!nullToAbsent || toTime != null) {
      map['to_time'] = Variable<DateTime?>(toTime);
    }
    if (!nullToAbsent || entryTime != null) {
      map['entry_time'] = Variable<DateTime?>(entryTime);
    }
    if (!nullToAbsent || frequentlyEveryHours != null) {
      map['frequently_every_hours'] = Variable<int?>(frequentlyEveryHours);
    }
    return map;
  }

  TbReminderCompanion toCompanion(bool nullToAbsent) {
    return TbReminderCompanion(
      reminderID: Value(reminderID!),
      notificationID: Value(notificationID),
      category: Value(category),
      desc: desc == null && nullToAbsent ? const Value.absent() : Value(desc),
      isReminderOn: Value(isReminderOn),
      isOnceOrFrequent: Value(isOnceOrFrequent),
      onceTime: onceTime == null && nullToAbsent
          ? const Value.absent()
          : Value(onceTime),
      fromTime: fromTime == null && nullToAbsent
          ? const Value.absent()
          : Value(fromTime),
      toTime:
          toTime == null && nullToAbsent ? const Value.absent() : Value(toTime),
      entryTime: entryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(entryTime),
      frequentlyEveryHours: frequentlyEveryHours == null && nullToAbsent
          ? const Value.absent()
          : Value(frequentlyEveryHours),
    );
  }

  factory TbReminderTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TbReminderTable(
      reminderID: serializer.fromJson<int>(json['reminderID']),
      notificationID: serializer.fromJson<int>(json['notificationID']),
      category: serializer.fromJson<String>(json['category']),
      desc: serializer.fromJson<String?>(json['desc']),
      isReminderOn: serializer.fromJson<bool>(json['isReminderOn']),
      isOnceOrFrequent: serializer.fromJson<bool>(json['isOnceOrFrequent']),
      onceTime: serializer.fromJson<DateTime?>(json['onceTime']),
      fromTime: serializer.fromJson<DateTime?>(json['fromTime']),
      toTime: serializer.fromJson<DateTime?>(json['toTime']),
      entryTime: serializer.fromJson<DateTime?>(json['entryTime']),
      frequentlyEveryHours:
          serializer.fromJson<int?>(json['frequentlyEveryHours']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reminderID': serializer.toJson<int>(reminderID!),
      'notificationID': serializer.toJson<int>(notificationID),
      'category': serializer.toJson<String>(category),
      'desc': serializer.toJson<String?>(desc),
      'isReminderOn': serializer.toJson<bool>(isReminderOn),
      'isOnceOrFrequent': serializer.toJson<bool>(isOnceOrFrequent),
      'onceTime': serializer.toJson<DateTime?>(onceTime),
      'fromTime': serializer.toJson<DateTime?>(fromTime),
      'toTime': serializer.toJson<DateTime?>(toTime),
      'entryTime': serializer.toJson<DateTime?>(entryTime),
      'frequentlyEveryHours': serializer.toJson<int?>(frequentlyEveryHours),
    };
  }

  TbReminderTable copyWith(
          {int? reminderID,
          int? notificationID,
          String? category,
          String? desc,
          bool? isReminderOn,
          bool? isOnceOrFrequent,
          DateTime? onceTime,
          DateTime? fromTime,
          DateTime? toTime,
          DateTime? entryTime,
          int? frequentlyEveryHours}) =>
      TbReminderTable(
        reminderID: reminderID ?? this.reminderID,
        notificationID: notificationID ?? this.notificationID,
        category: category ?? this.category,
        desc: desc ?? this.desc,
        isReminderOn: isReminderOn ?? this.isReminderOn,
        isOnceOrFrequent: isOnceOrFrequent ?? this.isOnceOrFrequent,
        onceTime: onceTime ?? this.onceTime,
        fromTime: fromTime ?? this.fromTime,
        toTime: toTime ?? this.toTime,
        entryTime: entryTime ?? this.entryTime,
        frequentlyEveryHours: frequentlyEveryHours ?? this.frequentlyEveryHours,
      );
  @override
  String toString() {
    return (StringBuffer('TbReminderTable(')
          ..write('reminderID: $reminderID, ')
          ..write('notificationID: $notificationID, ')
          ..write('category: $category, ')
          ..write('desc: $desc, ')
          ..write('isReminderOn: $isReminderOn, ')
          ..write('isOnceOrFrequent: $isOnceOrFrequent, ')
          ..write('onceTime: $onceTime, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('entryTime: $entryTime, ')
          ..write('frequentlyEveryHours: $frequentlyEveryHours')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      reminderID,
      notificationID,
      category,
      desc,
      isReminderOn,
      isOnceOrFrequent,
      onceTime,
      fromTime,
      toTime,
      entryTime,
      frequentlyEveryHours);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TbReminderTable &&
          other.reminderID == this.reminderID &&
          other.notificationID == this.notificationID &&
          other.category == this.category &&
          other.desc == this.desc &&
          other.isReminderOn == this.isReminderOn &&
          other.isOnceOrFrequent == this.isOnceOrFrequent &&
          other.onceTime == this.onceTime &&
          other.fromTime == this.fromTime &&
          other.toTime == this.toTime &&
          other.entryTime == this.entryTime &&
          other.frequentlyEveryHours == this.frequentlyEveryHours);
}

class TbReminderCompanion extends UpdateCompanion<TbReminderTable> {
  final Value<int> reminderID;
  final Value<int> notificationID;
  final Value<String> category;
  final Value<String?> desc;
  final Value<bool> isReminderOn;
  final Value<bool> isOnceOrFrequent;
  final Value<DateTime?> onceTime;
  final Value<DateTime?> fromTime;
  final Value<DateTime?> toTime;
  final Value<DateTime?> entryTime;
  final Value<int?> frequentlyEveryHours;
  const TbReminderCompanion({
    this.reminderID = const Value.absent(),
    this.notificationID = const Value.absent(),
    this.category = const Value.absent(),
    this.desc = const Value.absent(),
    this.isReminderOn = const Value.absent(),
    this.isOnceOrFrequent = const Value.absent(),
    this.onceTime = const Value.absent(),
    this.fromTime = const Value.absent(),
    this.toTime = const Value.absent(),
    this.entryTime = const Value.absent(),
    this.frequentlyEveryHours = const Value.absent(),
  });
  TbReminderCompanion.insert({
    this.reminderID = const Value.absent(),
    required int notificationID,
    required String category,
    this.desc = const Value.absent(),
    this.isReminderOn = const Value.absent(),
    this.isOnceOrFrequent = const Value.absent(),
    this.onceTime = const Value.absent(),
    this.fromTime = const Value.absent(),
    this.toTime = const Value.absent(),
    this.entryTime = const Value.absent(),
    this.frequentlyEveryHours = const Value.absent(),
  })  : notificationID = Value(notificationID),
        category = Value(category);
  static Insertable<TbReminderTable> custom({
    Expression<int>? reminderID,
    Expression<int>? notificationID,
    Expression<String>? category,
    Expression<String?>? desc,
    Expression<bool>? isReminderOn,
    Expression<bool>? isOnceOrFrequent,
    Expression<DateTime?>? onceTime,
    Expression<DateTime?>? fromTime,
    Expression<DateTime?>? toTime,
    Expression<DateTime?>? entryTime,
    Expression<int?>? frequentlyEveryHours,
  }) {
    return RawValuesInsertable({
      if (reminderID != null) 'reminder_i_d': reminderID,
      if (notificationID != null) 'notification_i_d': notificationID,
      if (category != null) 'category': category,
      if (desc != null) 'desc': desc,
      if (isReminderOn != null) 'is_reminder_on': isReminderOn,
      if (isOnceOrFrequent != null) 'is_once_or_frequent': isOnceOrFrequent,
      if (onceTime != null) 'once_time': onceTime,
      if (fromTime != null) 'from_time': fromTime,
      if (toTime != null) 'to_time': toTime,
      if (entryTime != null) 'entry_time': entryTime,
      if (frequentlyEveryHours != null)
        'frequently_every_hours': frequentlyEveryHours,
    });
  }

  TbReminderCompanion copyWith(
      {Value<int>? reminderID,
      Value<int>? notificationID,
      Value<String>? category,
      Value<String?>? desc,
      Value<bool>? isReminderOn,
      Value<bool>? isOnceOrFrequent,
      Value<DateTime?>? onceTime,
      Value<DateTime?>? fromTime,
      Value<DateTime?>? toTime,
      Value<DateTime?>? entryTime,
      Value<int?>? frequentlyEveryHours}) {
    return TbReminderCompanion(
      reminderID: reminderID ?? this.reminderID,
      notificationID: notificationID ?? this.notificationID,
      category: category ?? this.category,
      desc: desc ?? this.desc,
      isReminderOn: isReminderOn ?? this.isReminderOn,
      isOnceOrFrequent: isOnceOrFrequent ?? this.isOnceOrFrequent,
      onceTime: onceTime ?? this.onceTime,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      entryTime: entryTime ?? this.entryTime,
      frequentlyEveryHours: frequentlyEveryHours ?? this.frequentlyEveryHours,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reminderID.present) {
      map['reminder_i_d'] = Variable<int>(reminderID.value);
    }
    if (notificationID.present) {
      map['notification_i_d'] = Variable<int>(notificationID.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (desc.present) {
      map['desc'] = Variable<String?>(desc.value);
    }
    if (isReminderOn.present) {
      map['is_reminder_on'] = Variable<bool>(isReminderOn.value);
    }
    if (isOnceOrFrequent.present) {
      map['is_once_or_frequent'] = Variable<bool>(isOnceOrFrequent.value);
    }
    if (onceTime.present) {
      map['once_time'] = Variable<DateTime?>(onceTime.value);
    }
    if (fromTime.present) {
      map['from_time'] = Variable<DateTime?>(fromTime.value);
    }
    if (toTime.present) {
      map['to_time'] = Variable<DateTime?>(toTime.value);
    }
    if (entryTime.present) {
      map['entry_time'] = Variable<DateTime?>(entryTime.value);
    }
    if (frequentlyEveryHours.present) {
      map['frequently_every_hours'] =
          Variable<int?>(frequentlyEveryHours.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TbReminderCompanion(')
          ..write('reminderID: $reminderID, ')
          ..write('notificationID: $notificationID, ')
          ..write('category: $category, ')
          ..write('desc: $desc, ')
          ..write('isReminderOn: $isReminderOn, ')
          ..write('isOnceOrFrequent: $isOnceOrFrequent, ')
          ..write('onceTime: $onceTime, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('entryTime: $entryTime, ')
          ..write('frequentlyEveryHours: $frequentlyEveryHours')
          ..write(')'))
        .toString();
  }
}

class $TbReminderTable extends TbReminder
    with TableInfo<$TbReminderTable, TbReminderTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TbReminderTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _reminderIDMeta = const VerificationMeta('reminderID');
  @override
  late final GeneratedColumn<int?> reminderID = GeneratedColumn<int?>(
      'reminder_i_d', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _notificationIDMeta =
      const VerificationMeta('notificationID');
  @override
  late final GeneratedColumn<int?> notificationID = GeneratedColumn<int?>(
      'notification_i_d', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _categoryMeta = const VerificationMeta('category');
  @override
  late final GeneratedColumn<String?> category = GeneratedColumn<String?>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: const StringType(),
      requiredDuringInsert: true);
  final VerificationMeta _descMeta = const VerificationMeta('desc');
  @override
  late final GeneratedColumn<String?> desc = GeneratedColumn<String?>(
      'desc', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 2000),
      type: const StringType(),
      requiredDuringInsert: false);
  final VerificationMeta _isReminderOnMeta =
      const VerificationMeta('isReminderOn');
  @override
  late final GeneratedColumn<bool?> isReminderOn = GeneratedColumn<bool?>(
      'is_reminder_on', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_reminder_on IN (0, 1))',
      defaultValue: Constant(false));
  final VerificationMeta _isOnceOrFrequentMeta =
      const VerificationMeta('isOnceOrFrequent');
  @override
  late final GeneratedColumn<bool?> isOnceOrFrequent = GeneratedColumn<bool?>(
      'is_once_or_frequent', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_once_or_frequent IN (0, 1))',
      defaultValue: Constant(false));
  final VerificationMeta _onceTimeMeta = const VerificationMeta('onceTime');
  @override
  late final GeneratedColumn<DateTime?> onceTime = GeneratedColumn<DateTime?>(
      'once_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _fromTimeMeta = const VerificationMeta('fromTime');
  @override
  late final GeneratedColumn<DateTime?> fromTime = GeneratedColumn<DateTime?>(
      'from_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _toTimeMeta = const VerificationMeta('toTime');
  @override
  late final GeneratedColumn<DateTime?> toTime = GeneratedColumn<DateTime?>(
      'to_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _entryTimeMeta = const VerificationMeta('entryTime');
  @override
  late final GeneratedColumn<DateTime?> entryTime = GeneratedColumn<DateTime?>(
      'entry_time', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  final VerificationMeta _frequentlyEveryHoursMeta =
      const VerificationMeta('frequentlyEveryHours');
  @override
  late final GeneratedColumn<int?> frequentlyEveryHours = GeneratedColumn<int?>(
      'frequently_every_hours', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        reminderID,
        notificationID,
        category,
        desc,
        isReminderOn,
        isOnceOrFrequent,
        onceTime,
        fromTime,
        toTime,
        entryTime,
        frequentlyEveryHours
      ];
  @override
  String get aliasedName => _alias ?? 'tb_reminder';
  @override
  String get actualTableName => 'tb_reminder';
  @override
  VerificationContext validateIntegrity(Insertable<TbReminderTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reminder_i_d')) {
      context.handle(
          _reminderIDMeta,
          reminderID.isAcceptableOrUnknown(
              data['reminder_i_d']!, _reminderIDMeta));
    }
    if (data.containsKey('notification_i_d')) {
      context.handle(
          _notificationIDMeta,
          notificationID.isAcceptableOrUnknown(
              data['notification_i_d']!, _notificationIDMeta));
    } else if (isInserting) {
      context.missing(_notificationIDMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('desc')) {
      context.handle(
          _descMeta, desc.isAcceptableOrUnknown(data['desc']!, _descMeta));
    }
    if (data.containsKey('is_reminder_on')) {
      context.handle(
          _isReminderOnMeta,
          isReminderOn.isAcceptableOrUnknown(
              data['is_reminder_on']!, _isReminderOnMeta));
    }
    if (data.containsKey('is_once_or_frequent')) {
      context.handle(
          _isOnceOrFrequentMeta,
          isOnceOrFrequent.isAcceptableOrUnknown(
              data['is_once_or_frequent']!, _isOnceOrFrequentMeta));
    }
    if (data.containsKey('once_time')) {
      context.handle(_onceTimeMeta,
          onceTime.isAcceptableOrUnknown(data['once_time']!, _onceTimeMeta));
    }
    if (data.containsKey('from_time')) {
      context.handle(_fromTimeMeta,
          fromTime.isAcceptableOrUnknown(data['from_time']!, _fromTimeMeta));
    }
    if (data.containsKey('to_time')) {
      context.handle(_toTimeMeta,
          toTime.isAcceptableOrUnknown(data['to_time']!, _toTimeMeta));
    }
    if (data.containsKey('entry_time')) {
      context.handle(_entryTimeMeta,
          entryTime.isAcceptableOrUnknown(data['entry_time']!, _entryTimeMeta));
    }
    if (data.containsKey('frequently_every_hours')) {
      context.handle(
          _frequentlyEveryHoursMeta,
          frequentlyEveryHours.isAcceptableOrUnknown(
              data['frequently_every_hours']!, _frequentlyEveryHoursMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reminderID};
  @override
  TbReminderTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    return TbReminderTable.fromData(data, attachedDatabase,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $TbReminderTable createAlias(String alias) {
    return $TbReminderTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $TbReminderTable tbReminder = $TbReminderTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tbReminder];
}
