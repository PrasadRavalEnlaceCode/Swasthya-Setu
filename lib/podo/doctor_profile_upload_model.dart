class DoctorProfileUploadModel {
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
      businessCountryIDF = "",
      degree = "",
      registrationNumber = "",
      whatsAppNo = "",
      appointmentNo = "",
      latitude = "",
      longitude = "";

  DoctorProfileUploadModel(
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
    this.gender, {
    this.speciality,
    this.practisingSince,
    this.residenceAddress,
    this.residenceMobileNo,
    this.residenceLandLineNo,
    this.businessAddress,
    this.businessMobileNo,
    this.businessLandLineNo,
    this.businessCityIDF,
    this.businessStateIDF,
    this.businessCountryIDF,
    this.degree,
    this.registrationNumber,
    this.whatsAppNo,
    this.appointmentNo,
    this.latitude,
    this.longitude,
  });

  String toJson() {
    return ("{" "\"DoctorIDP\":\"$patientIDP\"," +
        "\"FirstName\":\"$firstName\"," +
        "\"MiddleName\":\"$middleName\"," +
        "\"LastName\":\"$lastName\"," +
        "\"MobileNo\":\"$mobileNo\"," +
        "\"EmailID\":\"$emailID\"," +
        "\"DOB\":\"$dob\"," +
        /*"\"Address\":\"$address\"," +*/
        "\"CityIDF\":\"$cityIDF\"," +
        "\"StateIDF\":\"$stateIDF\"," +
        "\"CountryIDF\":\"$countryIDF\"," +
        /*"\"Married\":\"$married\"," +
        "\"NoOfFamilyMember\":\"$noOfFamilyMember\"," +
        "\"YourPostionInFamily\":\"$yourPositionInFamily\"," +*/
        /*"\"Weight\":\"$weight\"," +
        "\"Height\":\"$height\"," +
        "\"BloodGroup\":\"$bloodGroup\"," +
        "\"EmergencyNumber\":\"$emergencyNumber\"," +*/
        "\"Gender\":\"$gender\"," +
        "\"Degree\":\"$degree\"," +
        "\"Specility\":\"$speciality\"," +
        "\"PractisingSince\":\"$practisingSince\"," +
        "\"ResidenceAddress\":\"$residenceAddress\"," +
        "\"ResidenceMobileNo\":\"$residenceMobileNo\"," +
        /*"\"ResidenceLandline\":\"$residenceLandLineNo\"," +*/
        "\"BusinessAddress\":\"$businessAddress\"," +
        "\"BusinessMobileNo\":\"$businessMobileNo\"," +
        /*"\"BusinessLandline\":\"$businessLandLineNo\"," +*/
        "\"BCityIDF\":\"$businessCityIDF\"," +
        "\"BStateIDF\":\"$businessStateIDF\"," +
        "\"BCountryIDF\":\"$businessCountryIDF\"," +
        "\"RegistrationNo\":\"$registrationNumber\"," +
        "\"WhatsappNo\":\"$whatsAppNo\"," +
        "\"AppointmentNo\":\"$appointmentNo\"," +
        "\"Latitude\":\"$latitude\"," +
        "\"Longitude\":\"$longitude\"" +
        "}");
  }
}
