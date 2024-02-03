class ModelPrescription {
  String drugIDP, drugName, drugDosage, duration, drugAdvice, notes;
  bool fromServer;

  ModelPrescription(this.drugIDP, this.drugName, this.drugDosage, this.duration,
      this.drugAdvice, this.notes, this.fromServer);
}
