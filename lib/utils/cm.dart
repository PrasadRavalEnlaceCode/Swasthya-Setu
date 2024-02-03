
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Dateformate {
  ///"MM/dd/yyyy"
  static const String MMsddsyyyy = "MM/dd/yyyy";

  /// "dd MMM yyyy"
  static const String ddMMMyyyy = "dd MMM yyyy";
  static const String MMMddyyyy = "MMM dd, yyyy";

  /// "dd/MMM/yyyy"
  static const String ddsMMMsyyyy = "dd/MMM/yyyy";

  ///"yyyy-MMM-dd"
  static const String yyyy_MMM_dd = "yyyy-MMM-dd";

  ///"yyyy-MM-dd'T'HH:mm:ss"
  static const String inPutFormate = "yyyy-MM-dd'T'HH:mm:ss";

  ///"h:mm a"
  static const String hmma = "h:mm a";
  static const String hhmm = "hh:mm";
  static const String EEEEMMMdyyyy = 'EEEE, MMMM d, ' 'yyyy';
}
class CM {


  static printWrapped(String title, String text) {
    if (!kReleaseMode) {
      text = title + ":- " + text;
      final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
      pattern.allMatches(text).forEach((match) => print(match.group(0)));
    }
  }
  static String convertDateFormate(
      BuildContext context, String dateFormate, String dateStr) {
    if (dateStr.isEmpty) {
      return "";
    }
    var formatter = new DateFormat(dateFormate);
    DateTime dateTime = DateTime.parse(dateStr);
    return formatter.format(dateTime).toString();
  }

}
