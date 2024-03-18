import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:silvertouch/controllers/certificate_controller.dart';
import 'package:silvertouch/podo/model_certificate.dart';

import '../global/SizeConfig.dart';
import '../utils/color.dart';

class FitnessCertificateScreen extends StatelessWidget {
  final ModelCertificate? cert;

  final idp;

  final patientIDP;

  FitnessCertificateScreen({Key? key, this.cert, this.idp, this.patientIDP})
      : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(CertificateController());
    // controller.submitCertificate(idp,patientIDP,cert.certificateTypeIDP,context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            cert!.certificateTypeName!,
            style: TextStyle(fontSize: SizeConfig.blockSizeVertical! * 2.5),
          ),
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: IconThemeData(color: Colorsblack),
          toolbarTextStyle: TextTheme(
                  titleMedium:
                      TextStyle(color: Colorsblack, fontFamily: "Ubuntu"))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  titleMedium:
                      TextStyle(color: Colorsblack, fontFamily: "Ubuntu"))
              .titleLarge,
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal! * 3),
                  child: Column(
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: controller.certFor,
                                style: TextStyle(color: Colors.green),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.black),
                                  labelStyle: TextStyle(color: Colors.black),
                                  labelText: "Certificate For",
                                  hintText: "",
                                  counterText: "",
                                ),
                                validator: (value) {
                                  if (value!.length == 0)
                                    return 'Please enter certificate for';
                                  return null;
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                minLines: 1,
                                maxLength: 500,
                              ),
                              TextFormField(
                                controller: controller.certRemarks,
                                style: TextStyle(color: Colors.green),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.black),
                                  labelStyle: TextStyle(color: Colors.black),
                                  labelText: "Remarks",
                                  hintText: "",
                                  counterText: "",
                                ),
                                validator: (value) {
                                  if (value!.length == 0)
                                    return 'Please enter certificate remarks';
                                  return null;
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                minLines: 1,
                                maxLength: 500,
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeHorizontal! * 3,
                  horizontal: SizeConfig.blockSizeHorizontal! * 3),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding:
                      EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 2.5),
                  decoration: BoxDecoration(
                    color: Color(0xFF06A759),
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate())
                        controller.submitCertificate(
                            idp, patientIDP, cert!.certificateTypeIDP, context);
                    },
                    child: Image(
                      width: SizeConfig.blockSizeHorizontal! * 5.5,
                      height: SizeConfig.blockSizeHorizontal! * 5.5,
                      //height: 80,
                      image: AssetImage("images/ic_right_arrow_triangular.png"),
                    ),
                    customBorder: CircleBorder(),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
