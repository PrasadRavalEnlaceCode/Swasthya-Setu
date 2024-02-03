class ModelVitalsList {
  String patientIDP,
      vitalIDP,
      BPSystolic,
      BPDiastolic,
      FBS,
      RBS,
      PPBS,
      temprature,
      pulse,
      sPO2,
      vitalEntryDate,
      vitalEntryTime,
      vitalEntryTimeID;

  ModelVitalsList(
      this.patientIDP,
      this.vitalIDP,
      this.BPSystolic,
      this.BPDiastolic,
      this.FBS,
      this.RBS,
      this.PPBS,
      this.temprature,
      this.pulse,
      this.sPO2,
      this.vitalEntryDate,
      this.vitalEntryTime,
      this.vitalEntryTimeID);

  String toJson() {
    return ("{" "\"PatientIDP\":\"$patientIDP\"," +
        "\"BPSystolic\":\"$BPSystolic\"," +
        "\"BPDiastolic\":\"$BPDiastolic\"," +
        /*"\"FBS\":\"$FBS\"," +
        "\"RBS\":\"$RBS\"," +
        "\"PPBS\":\"$PPBS\"," +*/
        "\"Temprature\":\"$temprature\"," +
        "\"Pulse\":\"$pulse\"," +
        "\"SPO2\":\"$sPO2\"," +
        "\"VitalEntryDate\":\"$vitalEntryDate\"," +
        "\"VitalEntryTime\":\"$vitalEntryTime\"" +
        "}");
  }
}
