class PatientProfileUploadModel {
  String? patientIDP,
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
      gender = "",
      speciality = "",
      practisingSince = "",
      residenceAddress = "",
      residenceMobileNo = "",
      residenceLandLineNo = "",
      businessAddress = "",
      businessMobileNo = "",
      businessLandLineNo = "",
      businessCityIDF = "",
      businessStateIDF = "",
      businessCountryIDF = "";

  PatientProfileUploadModel(
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
      this.gender,
      {this.speciality,
      this.practisingSince,
      this.residenceAddress,
      this.residenceMobileNo,
      this.residenceLandLineNo,
      this.businessAddress,
      this.businessMobileNo,
      this.businessLandLineNo,
      this.businessCityIDF,
      this.businessStateIDF,
      this.businessCountryIDF});

  String toJson() {
    return ("{" "\"PatientIDP\":\"$patientIDP\"," +
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
        "\"Gender\":\"$gender\"," +
        "\"Specility\":\"$speciality\"," +
        "\"PractisingSince\":\"$practisingSince\"" +
        /*"\"ResidenceAddress\":\"$residenceAddress\"," +
        "\"ResidenceMobileNo\":\"$residenceMobileNo\"," +
        "\"ResidenceLandline\":\"$residenceLandLineNo\"," +
        "\"BusinessAddress\":\"$businessAddress\"," +
        "\"BusinessMobileNo\":\"$businessMobileNo\"," +
        "\"BusinessLandline\":\"$businessLandLineNo\"," +
        "\"BCityIDF\":\"$businessCityIDF\"," +
        "\"BStateIDF\":\"$businessStateIDF\"," +
        "\"BCountryIDF\":\"$businessCountryIDF\"" +*/
        "}");
  }
}
