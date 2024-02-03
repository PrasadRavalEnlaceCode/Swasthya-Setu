class ModelInvestigationMaster {
  String? preInvestTypeIDP,
      groupType,
      groupName,
      investigationType,
      rangeValue,
      displayType,
      radioValue;

  bool isChecked, show = true;

  ModelInvestigationMaster(this.preInvestTypeIDP, this.groupType,
      this.groupName, this.investigationType, this.rangeValue, this.isChecked,
      {this.show = true, this.displayType, this.radioValue = ""});
}
