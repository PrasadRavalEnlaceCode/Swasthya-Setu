class DoctorPatientProfileUploadModel {
  String patientIDP,
      firstName,
      lastName,
      mobileNo,
      emailID,
      dob,
      address,
      cityIDF,
      stateIDF,
      countryIDF,
      married,
      noOfFamilyMember,
      yourPositionInFamily,
      middleName = "",
      weight = "",
      height = "",
      bloodGroup = "",
      emergencyNumber = "",
      gender = "";

  DoctorPatientProfileUploadModel(
      this.patientIDP,
      this.firstName,
      this.lastName,
      this.mobileNo,
      this.emailID,
      this.dob,
      this.address,
      this.cityIDF,
      this.stateIDF,
      this.countryIDF,
      this.married,
      this.noOfFamilyMember,
      this.yourPositionInFamily,
      this.middleName,
      this.weight,
      this.height,
      this.bloodGroup,
      this.emergencyNumber,
      this.gender);

  String toJson() {
    return ("{" "\"DoctorIDP\":\"$patientIDP\"," +
        "\"FirstName\":\"$firstName\"," +
        "\"LastName\":\"$lastName\"," +
        "\"MobileNo\":\"$mobileNo\"," +
        "\"EmailID\":\"$emailID\"," +
        "\"DOB\":\"$dob\"," +
        "\"Address\":\"$address\"," +
        "\"CityIDF\":\"$cityIDF\"," +
        "\"StateIDF\":\"$stateIDF\"," +
        "\"CountryIDF\":\"$countryIDF\"," +
        "\"Married\":\"$married\"," +
        "\"NoOfFamilyMember\":\"$noOfFamilyMember\"," +
        "\"YourPostionInFamily\":\"$yourPositionInFamily\"," +
        "\"MiddleName\":\"$middleName\"," +
        "\"Weight\":\"$weight\"," +
        "\"Height\":\"$height\"," +
        "\"BloodGroup\":\"$bloodGroup\"," +
        "\"EmergencyNumber\":\"$emergencyNumber\"," +
        "\"Gender\":\"$gender\"" +
        "}");
  }
}
