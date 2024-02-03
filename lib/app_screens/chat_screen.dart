import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:swasthyasetu/app_screens/custom_dialog.dart';
import 'package:swasthyasetu/app_screens/fullscreen_image.dart';
import 'package:swasthyasetu/app_screens/selected_patient_screen.dart';
import 'package:swasthyasetu/global/SizeConfig.dart';
import 'package:swasthyasetu/global/utils.dart';
import 'package:swasthyasetu/podo/chat_group_datewise.dart';
import 'package:swasthyasetu/podo/model_message.dart';
import 'package:swasthyasetu/podo/response_main_model.dart';
import 'package:http/http.dart' as http;
import 'package:swasthyasetu/utils/multipart_request_with_progress.dart';
import 'package:swasthyasetu/utils/progress_dialog.dart';
import 'package:swasthyasetu/utils/progress_dialog_with_percentage.dart';
import 'package:swasthyasetu/widgets/blinking_widget.dart';
import 'package:swasthyasetu/widgets/extensions.dart';

class ChatScreen extends StatefulWidget {
  String? patientIDP, patientName, type, doctorIDP, patientImage;
  String? gender, age, cityName, patientID, heroTag;
  File? image;

  ChatScreen({
    this.patientIDP,
    this.patientName,
    this.patientImage,
    this.gender,
    this.age,
    this.cityName,
    this.patientID,
    this.heroTag,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  List<Message> listMessages = [];
  List<ChatGroup> listChatGroups = [];
  List<String> listDates = [];
  GlobalKey<ProgressDialogWithPercentageState> progressKey = GlobalKey();

  List<List<Message>> listMessagesDateWise = [];
  bool isLoadingListView = false;
  bool isLoadingBottomProgress = false;
  bool isLoadingTextMessage = false;
  int startIndex = 0;
  GlobalKey<_ChatScreenState> chatScreenKey = GlobalKey();
  String latestDate = "";
  TextEditingController textController = TextEditingController();
  String? userType;
  Timer? chatTimer;
  final picker = ImagePicker();
  AppLifecycleState? _state;

  _buildMessageComposer(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: isLoadingBottomProgress ? 0.3 : 1.0,
          child: Column(
            children: [
              widget.image != null
                  ? Container(
                      /*color: Colors.white,*/
                      width: SizeConfig.screenWidth,
                      padding: EdgeInsets.all(
                        SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.0,
                            color: Colors.grey,
                          )),
                      child: Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Image(
                                  image: FileImage(widget.image!),
                                  width: SizeConfig.blockSizeHorizontal !* 35,
                                  height: SizeConfig.blockSizeHorizontal !* 35,
                                  fit: BoxFit.fill,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: MaterialButton(
                                    minWidth:
                                        SizeConfig.blockSizeHorizontal !* 2.0,
                                    height:
                                        SizeConfig.blockSizeHorizontal !* 2.0,
                                    onPressed: () {
                                      removeImage();
                                    },
                                    /*child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),*/
                                    child: Image(
                                      image: AssetImage("images/ic_cancel.png"),
                                      color: Colors.white,
                                      width: SizeConfig.blockSizeHorizontal !* 6,
                                      height:
                                          SizeConfig.blockSizeHorizontal !* 6,
                                    ),
                                    /* ),*/
                                    padding: EdgeInsets.all(0),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: CircleBorder(),
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: !isLoadingBottomProgress
                                      ? TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          controller: textController,
                                          minLines: 1,
                                          maxLines: 5,
                                          onChanged: (value) {},
                                          decoration: InputDecoration.collapsed(
                                            hintText: 'Enter Caption',
                                          ),
                                        )
                                      : TextField(
                                          readOnly: true,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          controller: textController,
                                          minLines: 1,
                                          maxLines: 5,
                                          onChanged: (value) {},
                                          decoration: InputDecoration.collapsed(
                                            hintText: 'Enter Caption',
                                          ),
                                        ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 6.0,
                                    bottom: 6.0,
                                    right: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.send),
                                    iconSize: 24.0,
                                    color: Colors.white,
                                    onPressed: () {
                                      if (!isLoadingBottomProgress) {
                                        submitChat(context);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                  : /*Container(),*/
                  Container(
                      /*height: 70.0,*/
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.photo),
                            iconSize: 25.0,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              if (!isLoadingBottomProgress) {
                                showImageTypeSelectionDialog(context);
                              }
                            },
                          ),
                          Expanded(
                            child: !isLoadingBottomProgress
                                ? isLoadingTextMessage
                                    ? Stack(
                                        children: [
                                          TextField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: textController,
                                            minLines: 1,
                                            maxLines: 5,
                                            onChanged: (value) {},
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: 'Enter message',
                                            ),
                                          ),
                                          Positioned(
                                            right: 10,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.grey),
                                            ),
                                          )
                                        ],
                                      )
                                    : TextField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        keyboardType: TextInputType.multiline,
                                        controller: textController,
                                        minLines: 1,
                                        maxLines: 5,
                                        onChanged: (value) {},
                                        decoration: InputDecoration.collapsed(
                                          hintText: 'Enter message',
                                        ),
                                      )
                                : TextField(
                                    readOnly: true,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    controller: textController,
                                    minLines: 1,
                                    maxLines: 5,
                                    onChanged: (value) {},
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Enter message',
                                    ),
                                  ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 6.0,
                              bottom: 6.0,
                              right: 5.0,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.send),
                              iconSize: 24.0,
                              color: Colors.white,
                              onPressed: () {
                                if (!isLoadingBottomProgress) {
                                  submitChat(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getPatientOrDoctorIDP().then((value) => widget.doctorIDP = value);
    getUserType().then((value) => userType = value);
    getChatList();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    chatTimer!.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF76736e),
    ));
    return Scaffold(
      backgroundColor: Colors.brown[600],
      appBar: AppBar(
        backgroundColor: Colors.brown[600],
        title: InkWell(
          child: Text(
            widget.patientName!,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal !* 4.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            /*debugPrint(widget.patientIDP +
                "" +
                widget.patientName +
                "" +
                widget.gender +
                "" +
                widget.age +
                "" +
                widget.cityName +
                "" +
                widget.patientImage +
                "" +
                widget.patientID +
                "" +
                widget.heroTag);*/
            String userType = await getUserType();
            if (userType ==
                    "doctor" /*&&
                widget.age != null &&
                widget.cityName != null*/
                ) {
              String displayStatus, notificationDisplayStatus;
              if (listMessages.length > 0) {
                displayStatus = listMessages[0].healthRecordsDisplayStatus!;
                notificationDisplayStatus =
                    listMessages[0].notificationDisplayStatus!;
              } else {
                displayStatus = "1";
                notificationDisplayStatus = "1";
              }
              Navigator.of(context).push(PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (context, _, __) {
                    return SelectedPatientScreen(
                      widget.patientIDP!,
                      displayStatus,
                      /*widget.patientName,
                      widget.gender,
                      widget.age,
                      widget.cityName,
                      widget.patientImage,
                      widget.patientID,*/
                      "chat_${widget.patientIDP}",
                      notificationDisplayStatus: notificationDisplayStatus,
                    );
                  }));
            }
          },
        ),
        elevation: 0.0,
        /*actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],*/
      ),
      body: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: SizeConfig.blockSizeVertical !* 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE6DC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            Visibility(
                                visible: isLoadingListView,
                                child: Container(
                                    width: SizeConfig.blockSizeHorizontal !* 10,
                                    height: SizeConfig.blockSizeHorizontal !* 10,
                                    child: Center(
                                      child: LinearProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blueGrey),
                                      ),
                                    ))),
                            Expanded(
                              child: !isLoadingListView &&
                                      listMessages.length == 0
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                              /*decoration: BoxDecoration(
                                                color: Colors.blueGrey[700],
                                                shape: BoxShape.circle,
                                              ),*/
                                              child: Padding(
                                            padding: EdgeInsets.all(
                                                SizeConfig.blockSizeHorizontal !*
                                                    3),
                                            child: Icon(
                                              Icons.chat,
                                              color: Colors.grey[900],
                                              size: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  12.0,
                                            ),
                                          )),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockSizeVertical !*
                                                    0.5,
                                          ),
                                          Text(
                                            "Type your first message to send.",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey[900],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : chatList(context,
                                      changeIsLoadingForListViewAndCallApi),
                            )
                          ],
                        )),
                  ),
                ),
                _buildMessageComposer(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Function? changeIsLoadingForListViewAndCallApi() {
    setState(() {
      isLoadingListView = !isLoadingListView;
    });
    startIndex = startIndex + 10;
    getChatList();
    return null;
  }

  T getTargetState<T>(Offset globalPosition) {
    final HitTestResult result = new HitTestResult();
    WidgetsBinding.instance.hitTest(result, globalPosition);
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    for (HitTestEntry entry in result.path) {
      if (entry.target is RenderMetaData) {
        final renderMetaData = entry.target as RenderMetaData;
        if (renderMetaData.metaData is T) return renderMetaData.metaData as T;
      }
    }
    return null!;
  }

  /*Widget chatList(
      BuildContext context, Function changeIsLoadingForListViewAndCallApi) {
    ScrollController _scrollController = ScrollController();
    debugPrint("before listener all videos");
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        debugPrint("scrolled to end...");
        changeIsLoadingForListViewAndCallApi();
        debugPrint("Hidden");
      } else {
        debugPrint("Showing");
      }
    });
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: EdgeInsets.only(top: 15.0),
      itemCount: listMessages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = listMessages[index];
        String matchingLetter = "";
        if (userType == "doctor")
          matchingLetter = "D";
        else if (userType == "patient") matchingLetter = "P";
        final bool isMe = message.messageFrom == matchingLetter;
        _keys[index] = RectGetter.createGlobalKey();
        return _buildMessage(message, isMe, index, matchingLetter) */ /*)*/ /*;
      },
    );
  }*/

  Widget chatList(
      BuildContext context, Function changeIsLoadingForListViewAndCallApi) {
    ScrollController _scrollController = ScrollController();
    debugPrint("before listener all videos");
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        debugPrint("scrolled to end...");
        changeIsLoadingForListViewAndCallApi();
        debugPrint("Hidden");
      } else {
        debugPrint("Showing");
      }
    });
    return ListView.builder(
      shrinkWrap: true,
      reverse: true,
      controller: _scrollController,
      padding: EdgeInsets.only(top: 15.0),
      itemCount: listMessagesDateWise.length,
      itemBuilder: (BuildContext context, int index) {
        return _StickyHeaderList(
          list: listMessagesDateWise[index],
          date: listDates[index],
          userType: userType!,
          patientName: widget.patientName!,
          patientImage: widget.patientImage!,
          patientIDP: widget.patientIDP!,
          getChatListFromPatient: getChatList,
        );
      },
    );
  }

  void getChatList() async {
    setState(() {
      isLoadingListView = true;
    });
    String getMedicalProfileUrl = "${baseURL}doctorPatientChat.php";
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String patientIDPValue = "";
    String doctorIDPValue = "";
    String fromType = "";

    if (userType == "patient") {
      patientIDPValue = patientIDP;
      doctorIDPValue = widget.patientIDP!;
      fromType = "D";
    } else if (userType == "doctor") {
      patientIDPValue = widget.patientIDP!;
      doctorIDPValue = patientIDP;
      fromType = "P";
    }

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPValue +
        "\"" +
        "," +
        "\"DoctorIDP\":\"$doctorIDPValue\"," +
        "\"startvalue\":\"$startIndex\"," +
        "\"FromType\":\"$fromType\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: getMedicalProfileUrl,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );

    debugPrint(response.body.toString());

    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);

    setState(() {
      isLoadingListView = false;
    });

    if (chatTimer != null) chatTimer!.cancel();
    Future.delayed(Duration(seconds: 2), () {});
    chatTimer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (_state == null || _state == AppLifecycleState.resumed)
        getUnreadMessages();
    });
    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      debugPrint("json data length - ${jsonData.length}");
      if (startIndex == 0) {
        listMessages = [];
        listDates = [];
        listMessagesDateWise = [];
      }
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        if (!listDates.contains(jo['ChatDate'].toString()))
          listDates.add(jo['ChatDate'].toString());
        if (startIndex == 0) {
          listMessages.add(Message(
            chatIDP: jo['ChatIDP'],
            patientIDP: jo['PatientIDF'],
            doctorIDP: jo['DoctorIDF'],
            messageContent: jo['MessageContent'],
            imageStatus: jo['ImageStatus'],
            imageName: jo['ImageName'],
            date: jo['ChatDate'].toString(),
            time: jo['ChatTime'].toString(),
            messageFrom: jo['MessageFrom'],
            videoCallRequestStatus: jo['VideoCallRequest'].toString(),
            videoCallStartedStatus: jo['VideoCallStarted'].toString(),
            audioCallRequestStatus: jo['AudioCallRequest'].toString(),
            audioCallStartedStatus: jo['AudioCallStarted'].toString(),
            healthRecordsDisplayStatus:
                jo['HealthRecordsDisplayStatus'].toString(),
            notificationDisplayStatus:
                jo['NotificationDisplayStatus'].toString(),
          ));
        } else {
          listMessages.add(Message(
            chatIDP: jo['ChatIDP'],
            patientIDP: jo['PatientIDF'],
            doctorIDP: jo['DoctorIDF'],
            messageContent: jo['MessageContent'],
            imageStatus: jo['ImageStatus'],
            imageName: jo['ImageName'],
            date: jo['ChatDate'].toString(),
            time: jo['ChatTime'].toString(),
            messageFrom: jo['MessageFrom'],
            videoCallRequestStatus: jo['VideoCallRequest'].toString(),
            videoCallStartedStatus: jo['VideoCallStarted'].toString(),
            audioCallRequestStatus: jo['AudioCallRequest'].toString(),
            audioCallStartedStatus: jo['AudioCallStarted'].toString(),
            healthRecordsDisplayStatus: jo['HealthRecordsDisplayStatus'].toString(),
          ));
        }
      }
      getDateWiseListFromMessagesAndSetState();
    }
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  showImageTypeSelectionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: dialogContent(context, "Select Image from"),
            ));
  }

  Future getImageFromCamera() async {
    File imgSelected =
        await chooseImageWithExIfRotate(picker, ImageSource.camera);
 widget.image = imgSelected;
    Navigator.of(context).pop();
    setState(() {});
  }

  Future removeImage() async {
    widget.image = null;
    setState(() {});
  }

  Future getImageFromGallery() async {
    File imgSelected =
        await chooseImageWithExIfRotate(picker, ImageSource.gallery);
 widget.image = imgSelected;
    Navigator.of(context).pop();
    setState(() {});
  }

  dialogContent(BuildContext context, String title) {
    SizeConfig().init(context);

    Future removeImage() async {
      widget.image = null;
      Navigator.of(context).pop();
      setState(() {});
    }

    return Stack(
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal !* 90,
          height: SizeConfig.blockSizeVertical !* 25,
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical !* 1,
            bottom: SizeConfig.blockSizeVertical !* 1,
            left: SizeConfig.blockSizeHorizontal !* 1,
            right: SizeConfig.blockSizeHorizontal !* 1,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MaterialButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                      size: SizeConfig.blockSizeVertical !* 2.8,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical !* 2.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical !* 0.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal !* 10,
                      height: SizeConfig.blockSizeVertical !* 10,
                      //height: 80,
                      image: AssetImage("images/ic_camera.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      getImageFromGallery();
                    },
                    child: Image(
                      fit: BoxFit.contain,
                      width: SizeConfig.blockSizeHorizontal !* 10,
                      height: SizeConfig.blockSizeVertical !* 10,
                      //height: 80,
                      image: AssetImage("images/ic_gallery.png"),
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal !* 1,
                  ),
                  MaterialButton(
                    onPressed: () {
                      removeImage();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: SizeConfig.blockSizeHorizontal !* 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void submitChat(BuildContext context) async {
    if (widget.image == null && textController.text.trim() == "") {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Type something to send"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    setState(() {
      isLoadingTextMessage = true;
    });
    String submitChat = "${baseURL}doctorPatientChatAdd.php";
    if (widget.image != null)
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ProgressDialogWithPercentage(
              key: progressKey,
            );
          });
    final multipartRequest = MultipartRequest(
      'POST',
      Uri.parse(submitChat),
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        if (widget.image != null)
          progressKey.currentState!.setProgress(progress);
      },
    );
    /*setState(() {
      isLoadingBottomProgress = true;
    });*/
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String patientIDPValue = "";
    String doctorIDPValue = "";
    String imgCount = "0";

    if (widget.image != null) imgCount = "1";

    if (userType == "patient") {
      patientIDPValue = patientIDP;
      doctorIDPValue = widget.patientIDP!;
    } else if (userType == "doctor") {
      patientIDPValue = widget.patientIDP!;
      doctorIDPValue = patientIDP;
    }

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPValue +
        "\"" +
        "," +
        "\"DoctorIDP\":\"$doctorIDPValue\"," +
        "\"messagecontent\":\"${replaceNewLineBySlashN(textController.text.toString().trim())}\"," +
        "\"messagefrom\":\"${userType == "patient" ? "P" : userType == "doctor" ? "D" : ""}\"," +
        "\"imagecount\":\"$imgCount\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    multipartRequest.fields['getjson'] = encodedJSONStr;
    Map<String, String> headers = Map();
    headers['u'] = patientUniqueKey;
    headers['type'] = userType;
    multipartRequest.headers.addAll(headers);
    if (widget.image != null) {
      var imgLength = await widget.image!.length();
      multipartRequest.files.add(new http.MultipartFile(
          'image1', widget.image!.openRead(), imgLength,
          filename: widget.image!.path));
    }
    var response = await apiHelper.callMultipartApi(multipartRequest);
    setState(() {
      isLoadingTextMessage = false;
    });
    if (widget.image != null) {
      Navigator.of(context).pop();
    }
    response.stream.transform(utf8.decoder).listen((value) async {
      debugPrint(value);
      final jsonResponse = json.decode(value);
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);

      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array Dashboard : " + strData);
        final jsonData = json.decode(strData);
        final jo = jsonData[0];
        listMessages.insert(
            0,
            Message(
              chatIDP: jo['ChatIDP'].toString(),
              patientIDP: jo['PatientIDF'].toString(),
              doctorIDP: jo['DoctorIDF'].toString(),
              messageContent: jo['MessageContent'],
              imageStatus: jo['ImageStatus'].toString(),
              imageName: jo['ImageName'],
              date: jo['ChatDate'].toString(),
              time: jo['ChatTime'].toString(),
              messageFrom: jo['MessageFrom'],
              videoCallRequestStatus: jo['VideoCallRequest'].toString(),
              videoCallStartedStatus: jo['VideoCallStarted'].toString(),
              audioCallRequestStatus: jo['AudioCallRequest'].toString(),
              audioCallStartedStatus: jo['AudioCallStarted'].toString(),
            ));
        widget.image = null;
        if (!listDates.contains(jo['ChatDate'].toString()))
          listDates.insert(0, jo['ChatDate'].toString());
        textController = TextEditingController();
        getDateWiseListFromMessagesAndSetState();
      }
    });

    /*await http.post(
      Uri.encodeFull(submitChat),

      //Uri.parse(loginUrl),
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },

      body: {"getjson": encodedJSONStr},
    );*/
  }

  Widget getCircularImage(
      Message message, Message previousMessage, Message nextMessage) {
    return widget.patientImage != "" &&
            widget.patientImage != null &&
            widget.patientImage != "null"
        ? CircleAvatar(
            radius: SizeConfig.blockSizeHorizontal !* 6,
            backgroundImage: NetworkImage(userType == "patient"
                ? "$doctorImgUrl${widget.patientImage}"
                : "$userImgUrl${widget.patientImage}"))
        : CircleAvatar(
            radius: SizeConfig.blockSizeHorizontal !* 6,
            backgroundColor: Colors.grey,
            backgroundImage: AssetImage("images/ic_user_placeholder.png"));
  }

  void getDateWiseListFromMessagesAndSetState() {
    listMessagesDateWise = [];
    for (int i = 0; i < listDates.length; i++) {
      final String date = listDates[i];
      List<Message> listTempMessages = [];
      for (int j = 0; j < listMessages.length; j++) {
        if (listMessages[j].date == date) listTempMessages.add(listMessages[j]);
      }
      listMessagesDateWise.add(listTempMessages);
    }
    debugPrint(
        "list length after for loop - ${listMessages.length} -  ${listMessagesDateWise.length}");
    setState(() {});
  }

  void getUnreadMessages() async {
    String getMedicalProfileUrl = "${baseURL}doctorPatientUnreadChat.php";
    String patientIDP = await getPatientOrDoctorIDP();
    String patientUniqueKey = await getPatientUniqueKey();
    String userType = await getUserType();
    debugPrint("Key and type");
    debugPrint(patientUniqueKey);
    debugPrint(userType);

    String patientIDPValue = "";
    String doctorIDPValue = "";
    String fromType = "";

    if (userType == "patient") {
      patientIDPValue = patientIDP;
      doctorIDPValue = widget.patientIDP!;
      fromType = "P";
    } else if (userType == "doctor") {
      patientIDPValue = widget.patientIDP!;
      doctorIDPValue = patientIDP;
      fromType = "D";
    }

    String jsonStr = "{" +
        "\"" +
        "PatientIDP" +
        "\"" +
        ":" +
        "\"" +
        patientIDPValue +
        "\"" +
        "," +
        "\"DoctorIDP\":\"$doctorIDPValue\"," +
        "\"startvalue\":\"$startIndex\"," +
        "\"FromType\":\"$fromType\"" +
        "}";

    debugPrint("Vital value");
    debugPrint(jsonStr);

    String encodedJSONStr = encodeBase64(jsonStr);
    var response = await apiHelper.callApiWithHeadersAndBody(
      url: getMedicalProfileUrl,
      headers: {
        "u": patientUniqueKey,
        "type": userType,
      },
      body: {"getjson": encodedJSONStr},
    );

    debugPrint(response.body.toString());

    final jsonResponse = json.decode(response.body.toString());
    ResponseModel model = ResponseModel.fromJSON(jsonResponse);

    setState(() {
      isLoadingListView = false;
    });

    if (model.status == "OK") {
      var data = jsonResponse['Data'];
      var strData = decodeBase64(data);
      debugPrint("Decoded Data Array Dashboard : " + strData);
      final jsonData = json.decode(strData);
      debugPrint("json data length - ${jsonData.length}");
      /*if (startIndex == 0) {
        listMessages = [];
        listDates = [];
        listMessagesDateWise = [];
      }*/
      for (int i = 0; i < jsonData.length; i++) {
        final jo = jsonData[i];
        /*if (!listDates.contains(jo['ChatDate'].toString()))
          listDates.add(jo['ChatDate'].toString());*/
        /*if (startIndex == 0) {*/
        Message message = Message(
          chatIDP: jo['ChatIDP'],
          patientIDP: jo['PatientIDF'],
          doctorIDP: jo['DoctorIDF'],
          messageContent: jo['MessageContent'],
          imageStatus: jo['ImageStatus'],
          imageName: jo['ImageName'],
          date: jo['ChatDate'].toString(),
          time: jo['ChatTime'].toString(),
          messageFrom: jo['MessageFrom'],
          videoCallRequestStatus: jo['VideoCallRequest'].toString(),
          videoCallStartedStatus: jo['VideoCallStarted'].toString(),
          audioCallRequestStatus: jo['AudioCallRequest'].toString(),
          audioCallStartedStatus: jo['AudioCallStarted'].toString(),
        );
        if (!listMessages.contains(message))
          listMessages.insert(0, message
              /*Message(
                chatIDP: jo['ChatIDP'].toString(),
                patientIDP: jo['PatientIDF'].toString(),
                doctorIDP: jo['DoctorIDF'].toString(),
                messageContent: jo['MessageContent'],
                imageStatus: jo['ImageStatus'].toString(),
                imageName: jo['ImageName'],
                date: jo['ChatDate'].toString(),
                time: jo['ChatTime'].toString(),
                messageFrom: jo['MessageFrom'],
                videoCallRequestStatus: jo['VideoCallRequest'].toString(),
                videoCallStartedStatus: jo['VideoCallStarted'].toString(),
              )*/
              );
        /*widget.image = null;*/
        if (!listDates.contains(jo['ChatDate'].toString()))
          listDates.insert(0, jo['ChatDate'].toString());
        //listMessages.add(message);
        /*} else {
          listMessages.add(Message(
            chatIDP: jo['ChatIDP'],
            patientIDP: jo['PatientIDF'],
            doctorIDP: jo['DoctorIDF'],
            messageContent: jo['MessageContent'],
            imageStatus: jo['ImageStatus'],
            imageName: jo['ImageName'],
            date: jo['ChatDate'].toString(),
            time: jo['ChatTime'].toString(),
            messageFrom: jo['MessageFrom'],
            videoCallRequestStatus: jo['VideoCallRequest'].toString(),
            videoCallStartedStatus: jo['VideoCallStarted'].toString(),
          ));
        }*/
      }
      getDateWiseListFromMessagesAndSetState();
    }
  }
}

class QuoteClipper extends CustomClipper<Path> {
  final double chatRadius;

  QuoteClipper(this.chatRadius);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, chatRadius);
    // path.lineTo(chatRadius, chatRadius + chatRadius / 2);
    final r = chatRadius;
    final angle = 0.785;
    path.conicTo(
      r - r * sin(angle),
      r + r * cos(angle),
      r - r * sin(angle * 0.5),
      r + r * cos(angle * 0.5),
      1,
    );

    final moveIn = 3 * r; // need to be > 2 * r
    path.lineTo(moveIn, r + moveIn * tan(angle));

    path.lineTo(moveIn, size.height - chatRadius);

    path.conicTo(
      moveIn + r - r * cos(angle),
      size.height - r + r * sin(angle),
      moveIn + r,
      size.height,
      1,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _LeftThread extends StatelessWidget {
  final String message;
  Widget child;
  final Color backgroundColor;
  final double r;

  _LeftThread(this.message, this.child,
      {this.r = 2.5, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: QuoteClipper(r),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(r)),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal !* 1.0 + 3 * r,
              SizeConfig.blockSizeHorizontal !* 2.0,
              SizeConfig.blockSizeHorizontal !* 1.0,
              SizeConfig.blockSizeHorizontal !* 2.0),
          color: this.backgroundColor,
          child:
              child /*Text(
            this.message,
            softWrap: true,
          )*/
          ,
        ),
      ),
    );
  }
}

class _RightThread extends StatelessWidget {
  final String message;
  Widget child;
  final Color backgroundColor;
  final double r;

  _RightThread(this.message, this.child,
      {this.r = 2.5, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final clipped = ClipPath(
      clipper: QuoteClipper(r),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(r)),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              SizeConfig.blockSizeHorizontal !* 1.0 + 3 * r,
              SizeConfig.blockSizeHorizontal !* 2.0,
              SizeConfig.blockSizeHorizontal !* 1.0,
              SizeConfig.blockSizeHorizontal !* 2.0),
          color: this.backgroundColor,
          child: Transform(
            transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
            child:
                child /*Text(
              this.message,
              softWrap: true,
            )*/
            ,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
    return Transform(
      transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
      child: clipped,
      alignment: Alignment.center,
    );
  }
}

class _StickyHeaderList extends StatelessWidget {
  const _StickyHeaderList({
    this.list,
    this.date,
    this.userType,
    this.patientName,
    this.patientImage,
    this.patientIDP,
    this.getChatListFromPatient,
  });

  final List<Message>? list;
  final String? date, userType, patientName, patientIDP, patientImage;
  final Function? getChatListFromPatient;

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      header: Header(date!),
      content: ListView.builder(
        shrinkWrap: true,
        reverse: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, i) {
          Message? nextMessage;
          final Message message = list![i];
          if (i != list!.length - 1)
            nextMessage = list![i + 1];
          else
            nextMessage = null;

          String matchingLetter = "";
          if (userType == "doctor")
            matchingLetter = "D";
          else if (userType == "patient") matchingLetter = "P";
          final bool isMe = message.messageFrom == matchingLetter;
          final Widget messageWidget = getMessageWidget(context, message,
              nextMessage, matchingLetter, patientName, patientImage);
          return Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              /*SizedBox(
              width: SizeConfig.blockSizeHorizontal * 3.0,
            ),
            !isMe
                ? (message.date != previousMessage.date) ||
                        (message.date == previousMessage.date &&
                            nextMessage.messageFrom != matchingLetter)
                    ? getCircularImage(message, previousMessage, nextMessage)
                    : CircleAvatar(
                        radius: SizeConfig.blockSizeHorizontal * 6,
                        backgroundColor: Colors.transparent,
                      )
                : Container()*/
              Container(
                margin: isMe
                    ? EdgeInsets.only(
                        top: message.messageFrom != nextMessage?.messageFrom
                            ? SizeConfig.blockSizeVertical !* 4.0
                            : 2.0,
                        bottom: 2.0,
                        left: SizeConfig.blockSizeHorizontal !* 1,
                        right: SizeConfig.blockSizeHorizontal !* 1,
                      )
                    : EdgeInsets.only(
                        top: message.messageFrom != nextMessage?.messageFrom
                            ? SizeConfig.blockSizeVertical !* 4.0
                            : 2.0,
                        bottom: 2.0,
                        right: SizeConfig.blockSizeHorizontal !* 1,
                        left: SizeConfig.blockSizeHorizontal !* 1,
                      ),
                child: message.videoCallRequestStatus == "1" ||
                        message.audioCallRequestStatus == "1"
                    ? messageWidget
                    : isMe
                        ? _RightThread(
                            "",
                            messageWidget,
                            backgroundColor:
                                isMe ? Color(0xFFE7FBCC) : Colors.white,
                            r: 3,
                          )
                        : _LeftThread(
                            "",
                            messageWidget,
                            backgroundColor:
                                isMe ? Color(0xFFE7FBCC) : Colors.white,
                            r: 3,
                          ),
              ),
            ],
          );
        },
        itemCount: list!.length,
      ),
    );
  }

  Widget getMessageWidget(
      BuildContext context,
      Message message,
      Message? nextMessage,
      String? matchingLetter,
      String? patientName,
      String? patientImage) {
    if (message.videoCallStartedStatus == "1") {
      return Container(
        width: SizeConfig.blockSizeHorizontal !* 98,
        child: Align(
          alignment: Alignment.centerRight,
          child: _RightThread(
            "",
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 55,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.missed_video_call,
                              color: Colors.black,
                              size: SizeConfig.blockSizeHorizontal !* 5.6,
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal !* 1.5,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  getTextVideoCallStarted(
                                      message, matchingLetter!),
                                  /* from $patientName*/
                                  softWrap: true,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 3.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /*MaterialButton(
                          onPressed: () {},
                          color: Colors.red,
                          splashColor: Colors.red[800],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(1.0),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.blockSizeHorizontal * 3.4,
                            ),
                          ),
                        ),*/
                            isMessageOfToday(message, matchingLetter)
                                ? MaterialButton(
                                    onPressed: () {
                                      getChannelIDForCall(
                                        context,
                                        patientIDP!,
                                        "0",
                                        message.chatIDP!,
                                        "video",
                                        message,
                                        patientName!,
                                        patientImage!,
                                      );
                                    },
                                    color: Colors.green,
                                    splashColor: Colors.green[800],
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal !* 2.0,
                                    ),
                                    child: Row(
                                      children: [
                                        BlinkingWidget(
                                            child: FaIcon(
                                          FontAwesomeIcons.video,
                                          size: SizeConfig.blockSizeHorizontal !*
                                              4.8,
                                          color: Colors.white,
                                        )),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.0,
                                        ),
                                        Text(
                                          "Connect",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).pO(
                                    right: SizeConfig.blockSizeHorizontal !* 3.0)
                                : Container(
                                    height: SizeConfig.blockSizeVertical !* 3.0,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: SizeConfig.blockSizeHorizontal !* 1.0,
                    bottom: SizeConfig.blockSizeVertical !* 0.6,
                    child: Text(
                      message.time!,
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      softWrap: true,
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Color(0xFFE7FBCC),
            r: 3,
          ),
        ),
      );
    } else if (message.videoCallRequestStatus == "1" &&
        message.videoCallStartedStatus == "0") {
      if (message.messageFrom == matchingLetter) {
        return Container(
          width: SizeConfig.blockSizeHorizontal !* 98,
          child: Align(
            alignment: Alignment.centerRight,
            child: _RightThread(
              "",
              SizedBox(
                width: SizeConfig.blockSizeHorizontal !* 98,
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.missed_video_call,
                            color: Colors.black,
                            size: SizeConfig.blockSizeHorizontal !* 5.6,
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 1.5,
                          ),
                          Text(
                            getTextVideoCallStartedForRequest(
                                message, matchingLetter!),
                            softWrap: true,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal !* 3.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 6.8,
                    ),
                    Positioned(
                      right: SizeConfig.blockSizeHorizontal !* 1.0,
                      bottom: SizeConfig.blockSizeVertical !* 0.6,
                      child: Text(
                        message.time!,
                        /*textAlign: TextAlign.right,*/
                        style: TextStyle(
                          color: Colors.blueGrey[600],
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        softWrap: true,
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Color(0xFFE7FBCC),
              r: 3,
            ),
          ),
        );
      } else {
        return Container(
          width: SizeConfig.blockSizeHorizontal !* 98,
          child: Align(
            alignment: Alignment.centerRight,
            child: _RightThread(
              "",
              SizedBox(
                width: SizeConfig.blockSizeHorizontal !* 55,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.missed_video_call,
                                color: Colors.black,
                                size: SizeConfig.blockSizeHorizontal !* 5.6,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1.5,
                              ),
                              Center(
                                child: Text(
                                  getTextVideoCallStartedForRequest(
                                      message, matchingLetter!),
                                  /* from $patientName*/
                                  softWrap: true,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 3.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*MaterialButton(
                          onPressed: () {},
                          color: Colors.red,
                          splashColor: Colors.red[800],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.all(1.0),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.blockSizeHorizontal * 3.4,
                            ),
                          ),
                        ),*/

                              isMessageOfToday(message, matchingLetter)
                                  ? MaterialButton(
                                      onPressed: () {
                                        getChannelIDForCall(
                                          context,
                                          patientIDP!,
                                          "0",
                                          message.chatIDP!,
                                          "video",
                                          message,
                                          patientName!,
                                          patientImage!,
                                        );
                                      },
                                      color: Colors.green,
                                      splashColor: Colors.green[800],
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.blockSizeHorizontal !*
                                                2.0,
                                      ),
                                      child: Row(
                                        children: [
                                          BlinkingWidget(
                                              child: FaIcon(
                                            FontAwesomeIcons.video,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4.8,
                                            color: Colors.white,
                                          )),
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.0,
                                          ),
                                          Text(
                                            "Connect",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  3.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).pO(
                                      right:
                                          SizeConfig.blockSizeHorizontal !* 3.0)
                                  : Container(
                                      height:
                                          SizeConfig.blockSizeVertical !* 3.0,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: SizeConfig.blockSizeHorizontal !* 1.0,
                      bottom: SizeConfig.blockSizeVertical !* 0.6,
                      child: Text(
                        message.time!,
                        /*textAlign: TextAlign.right,*/
                        style: TextStyle(
                          color: Colors.blueGrey[600],
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        softWrap: true,
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Color(0xFFE7FBCC),
              r: 3,
            ),
          ),
        );
      }
    } else if (message.audioCallStartedStatus == "1") {
      return Container(
        width: SizeConfig.blockSizeHorizontal !* 98,
        child: Align(
          alignment: Alignment.centerRight,
          child: _RightThread(
            "",
            SizedBox(
              width: SizeConfig.blockSizeHorizontal !* 55,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.call_missed_outgoing,
                              color: Colors.black,
                              size: SizeConfig.blockSizeHorizontal !* 5.6,
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal !* 1.5,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  getTextAudioCallStarted(
                                      message, matchingLetter!),
                                  /* from $patientName*/
                                  softWrap: true,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 3.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isMessageOfToday(message, matchingLetter)
                                ? MaterialButton(
                                    onPressed: () {
                                      getChannelIDForCall(
                                        context,
                                        patientIDP!,
                                        "0",
                                        message.chatIDP!,
                                        "audio",
                                        message,
                                        patientName!,
                                        patientImage!,
                                      );
                                    },
                                    color: Colors.green,
                                    splashColor: Colors.green[800],
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          SizeConfig.blockSizeHorizontal !* 2.0,
                                    ),
                                    child: Row(
                                      children: [
                                        BlinkingWidget(
                                            child: Icon(
                                          Icons.call,
                                          size: SizeConfig.blockSizeHorizontal !*
                                              4.8,
                                          color: Colors.white,
                                        )),
                                        SizedBox(
                                          width:
                                              SizeConfig.blockSizeHorizontal !*
                                                  3.0,
                                        ),
                                        Text(
                                          "Connect",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).pO(
                                    right: SizeConfig.blockSizeHorizontal !* 3.0)
                                : Container(
                                    height: SizeConfig.blockSizeVertical !* 3.0,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: SizeConfig.blockSizeHorizontal !* 1.0,
                    bottom: SizeConfig.blockSizeVertical !* 0.6,
                    child: Text(
                      message.time!,
                      /*textAlign: TextAlign.right,*/
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                      ),
                      softWrap: true,
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Color(0xFFE7FBCC),
            r: 3,
          ),
        ),
      );
    } else if (message.audioCallRequestStatus == "1" &&
        message.audioCallStartedStatus == "0") {
      if (message.messageFrom == matchingLetter) {
        return Container(
          width: SizeConfig.blockSizeHorizontal !* 98,
          child: Align(
            alignment: Alignment.centerRight,
            child: _RightThread(
              "",
              SizedBox(
                width: SizeConfig.blockSizeHorizontal !* 98,
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call_missed_outgoing,
                            color: Colors.black,
                            size: SizeConfig.blockSizeHorizontal !* 5.6,
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal !* 1.5,
                          ),
                          Text(
                            getTexAudioCallStartedForRequest(
                                message, matchingLetter!),
                            softWrap: true,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal !* 3.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical !* 6.8,
                    ),
                    Positioned(
                      right: SizeConfig.blockSizeHorizontal !* 1.0,
                      bottom: SizeConfig.blockSizeVertical !* 0.6,
                      child: Text(
                        message.time!,
                        /*textAlign: TextAlign.right,*/
                        style: TextStyle(
                          color: Colors.blueGrey[600],
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        softWrap: true,
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Color(0xFFE7FBCC),
              r: 3,
            ),
          ),
        );
      } else {
        return Container(
          width: SizeConfig.blockSizeHorizontal !* 98,
          child: Align(
            alignment: Alignment.centerRight,
            child: _RightThread(
              "",
              SizedBox(
                width: SizeConfig.blockSizeHorizontal !* 55,
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.missed_video_call,
                                color: Colors.black,
                                size: SizeConfig.blockSizeHorizontal !* 5.6,
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal !* 1.5,
                              ),
                              Center(
                                child: Text(
                                  getTexAudioCallStartedForRequest(
                                      message, matchingLetter!),
                                  /* from $patientName*/
                                  softWrap: true,
                                  maxLines: 10,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 3.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isMessageOfToday(message, matchingLetter)
                                  ? MaterialButton(
                                      onPressed: () {
                                        getChannelIDForCall(
                                          context,
                                          patientIDP!,
                                          "0",
                                          message.chatIDP!,
                                          "audio",
                                          message,
                                          patientName!,
                                          patientImage!,
                                        );
                                      },
                                      color: Colors.green,
                                      splashColor: Colors.green[800],
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            SizeConfig.blockSizeHorizontal !*
                                                2.0,
                                      ),
                                      child: Row(
                                        children: [
                                          BlinkingWidget(
                                              child: Icon(
                                            Icons.call,
                                            size:
                                                SizeConfig.blockSizeHorizontal !*
                                                    4.8,
                                            color: Colors.white,
                                          )),
                                          SizedBox(
                                            width:
                                                SizeConfig.blockSizeHorizontal !*
                                                    3.0,
                                          ),
                                          Text(
                                            "Connect",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal !*
                                                  3.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).pO(
                                      right:
                                          SizeConfig.blockSizeHorizontal !* 3.0)
                                  : Container(
                                      height:
                                          SizeConfig.blockSizeVertical !* 3.0,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: SizeConfig.blockSizeHorizontal !* 1.0,
                      bottom: SizeConfig.blockSizeVertical !* 0.6,
                      child: Text(
                        message.time!,
                        /*textAlign: TextAlign.right,*/
                        style: TextStyle(
                          color: Colors.blueGrey[600],
                          fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
                        ),
                        softWrap: true,
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Color(0xFFE7FBCC),
              r: 3,
            ),
          ),
        );
      }
    }
    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            minWidth: SizeConfig.blockSizeHorizontal !* 15.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal !* 1.3,
                  ),
                  child: message.imageStatus == "0"
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              constraints: BoxConstraints(
                                maxWidth: SizeConfig.blockSizeHorizontal !* 85,
                              ),
                              child: Text(
                                message.messageContent!,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal !* 3.8,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 100,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              )))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return FullScreenImage(
                                    '$chatImgUrl${message.imageName}',
                                    heroTag:
                                        "fullImg_${message.patientIDP}_${message.doctorIDP}_${message.chatIDP}",
                                  );
                                }));
                              },
                              child: Hero(
                                tag:
                                    "fullImg_${message.patientIDP}_${message.doctorIDP}_${message.chatIDP}",
                                child: Image(
                                  image: NetworkImage(
                                      '$chatImgUrl${message.imageName}'),
                                  width: SizeConfig.blockSizeHorizontal !* 45,
                                  height: SizeConfig.blockSizeHorizontal !* 45,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical !* 0.5,
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal !* 45,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  message.messageContent!,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal !* 3.8,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                            message.messageContent != ""
                                ? SizedBox(
                                    height: SizeConfig.blockSizeVertical !* 1.0,
                                  )
                                : Container(),
                          ],
                        )),
              message.messageContent != ""
                  ? SizedBox(
                      height: SizeConfig.blockSizeVertical !* 2.5,
                    )
                  : Container(),
            ],
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            child: Text(
              message.time!,
              /*textAlign: TextAlign.right,*/
              style: TextStyle(
                color: Colors.grey,
                fontSize: SizeConfig.blockSizeHorizontal !* 3.0,
              ),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  void getChannelIDForCall(
    BuildContext context,
    String doctorIDP,
    String startOrEnd,
    String chatIDP,
    String callType,
    Message message,
    String patientName,
    String patientImage,
  ) async {
    String urlGetChannelIDForVidCall = "${baseURL}videocall.php";
    if (callType == "audio")
      urlGetChannelIDForVidCall = "${baseURL}audiocall.php";
    ProgressDialog pr = ProgressDialog(context);
    pr.show();

    try {
      String patientUniqueKey = await getPatientUniqueKey();
      String userType = await getUserType();
      String patientIDPFromSp = await getPatientOrDoctorIDP();
      debugPrint("Key and type");
      debugPrint(patientUniqueKey);
      debugPrint(userType);
      /*String fromType = "";
      if (userType == "patient") {
        fromType = "P";
      } else if (userType == "doctor") {
        fromType = "D";
      }*/
      String patientIDPValue = "";
      String doctorIDPValue = "";
      String fromType = "";

      if (userType == "patient") {
        patientIDPValue = patientIDPFromSp;
        doctorIDPValue = patientIDP!;
        fromType = "P";
      } else if (userType == "doctor") {
        patientIDPValue = patientIDP!;
        doctorIDPValue = patientIDPFromSp;
        fromType = "D";
      }
      String startOrEndCall = "";
      if (startOrEnd == "0") {
        startOrEndCall = "startcall";
      } else if (startOrEnd == "1") {
        startOrEndCall = "endcall";
      }
      String jsonStr = "{" +
          "\"PatientIDP\":\"$patientIDPValue\"" +
          ",\"DoctorIDP\":\"$doctorIDPValue\"" +
          ",\"FromType\":\"$fromType\"" +
          ",\"CallType\":\"$startOrEndCall\"" +
          ",\"ChatIDP\":\"$chatIDP\"" +
          "}";

      debugPrint(jsonStr);

      String encodedJSONStr = encodeBase64(jsonStr);
      var response = await apiHelper.callApiWithHeadersAndBody(
        url: urlGetChannelIDForVidCall,
        //Uri.parse(loginUrl),
        headers: {
          "u": patientUniqueKey,
          "type": userType,
        },
        body: {"getjson": encodedJSONStr},
      );
      debugPrint(response.body.toString());
      final jsonResponse = json.decode(response.body.toString());
      ResponseModel model = ResponseModel.fromJSON(jsonResponse);
      pr.hide();
      if (model.status == "OK") {
        var data = jsonResponse['Data'];
        var strData = decodeBase64(data);
        debugPrint("Decoded Data Array : " + strData);
        final jsonData = json.decode(strData);
        await _handlePermission(Permission.camera);
        await _handlePermission(Permission.microphone);
        debugPrint("video id");
        debugPrint(jsonData[0]['VideoID'].toString());
        if (callType == "audio") {
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //   return AudioCallScreen(
          //     patientIDP: doctorIDP,
          //     channelID: jsonData[0]['VideoID'].toString(),
          //     message: message,
          //     patientName: patientName,
          //     patientImage: patientImage,
          //     chatIDP: chatIDP,
          //   );
          // })).then((value) {
          //   getChatListFromPatient();
          // });
        } else {
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //   return VideoCallScreen(
          //     patientIDP: doctorIDP,
          //     channelID: jsonData[0]['VideoID'].toString(),
          //     chatIDP: chatIDP,
          //   );
          // })).then((value) {
          //   getChatListFromPatient();
          // });
        }
      } else {}
    } catch (exception) {}
  }

  Future<void> _handlePermission(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  String encodeBase64(String text) {
    var bytes = utf8.encode(text);
    return base64.encode(bytes);
  }

  String decodeBase64(String text) {
    var bytes = base64.decode(text);
    return String.fromCharCodes(bytes);
  }

  String getTextVideoCallStarted(Message message, String matchingLetter) {
    if (isMessageOfToday(message, matchingLetter)) {
      if (message.messageFrom == matchingLetter)
        return "You can now connect video call";
      else
        return "Video call request received";
    } else
      return "Video call request expired";
  }

  String getTextAudioCallStarted(Message message, String matchingLetter) {
    if (isMessageOfToday(message, matchingLetter)) {
      if (message.messageFrom == matchingLetter)
        return "You can now connect Audio call";
      else
        return "Audio call request received";
    } else
      return "Audio call request expired";
  }

  String getTextVideoCallStartedForRequest(
      Message message, String matchingLetter) {
    if (isMessageOfToday(message, matchingLetter)) {
      if (message.messageFrom == matchingLetter)
        return "You Requested Video Call, Waiting for the response";
      else
        return "Video call request received";
    } else
      return "Video call request expired";
  }

  String getTexAudioCallStartedForRequest(
      Message message, String matchingLetter) {
    if (isMessageOfToday(message, matchingLetter)) {
      if (message.messageFrom == matchingLetter)
        return "You Requested Audio Call, Waiting for the response";
      else
        return "Audio call request received";
    } else
      return "Audio call request expired";
  }

  bool isMessageOfToday(Message message, String matchingLetter) {
    List<String> dateList = message.date!.split("-");
    DateTime now = DateTime.now();
    debugPrint(
        "0 -     ${dateList[0]}   ${now.day.toString().padLeft(2, '0')}");
    debugPrint(
        "1 -     ${dateList[1]}   ${now.month.toString().padLeft(2, '0')}");
    debugPrint("2 -     ${dateList[2]}   ${now.year.toString()}");
    if (dateList[0] == now.day.toString().padLeft(2, '0') &&
        dateList[1] == now.month.toString().padLeft(2, '0') &&
        dateList[2] == now.year.toString()) {
      return true;
    } else
      return false;
  }
}

class Header extends StatelessWidget {
  const Header(this.headerText);

  final String headerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical !* 2.2,
      ),
      alignment: Alignment.centerLeft,
      child: Center(
          child: Container(
        color: Colors.brown[500],
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal !* 2.0,
            vertical: SizeConfig.blockSizeHorizontal !* 1.3),
        child: Text(
          headerText,
          style: const TextStyle(color: Colors.white),
        ),
      )),
    );
  }
}
