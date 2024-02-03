class ModelInvestigationMasterWithDateTime {
  String? preInvestTypeIDP,
      groupType,
      groupName,
      investigationType,
      rangeValue,
      date,
      time,
      entryTimeId,
      byWhom;

  bool isChecked;

  ModelInvestigationMasterWithDateTime(
    this.preInvestTypeIDP,
    this.groupType,
    this.groupName,
    this.investigationType,
    this.rangeValue,
    this.isChecked,
    this.date,
    this.time,
    this.entryTimeId, {
    this.byWhom,
  });
}
