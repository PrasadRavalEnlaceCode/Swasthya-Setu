// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
//
// class ApiHelper {
//   callApiWithHeadersAndBody(
//       {String? url, Map<String, String>? headers, dynamic body}) async {
//     /*headers['a'] = "aa";
//     debugPrint("Let's print - ${headers}");*/
//     var response = await http.post(
//       Uri.parse(url!),
//       headers: headers,
//       body: body,
//     );
//     return response;
//   }
//
//   Future<http.StreamedResponse> callMultipartApi(
//       MultipartRequest multipartRequest) async {
//     /*multipartRequest.headers['a'] = "aa";
//     debugPrint("Let's print - ${multipartRequest.headers}");*/
//     var response = await multipartRequest.send();
//     return response;
//   }
// }

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiHelper {

  // Add default headers here
  static Map<String, String> defaultHeaders = {
    "appid" : "1",
  };

  // Function to update the default headers
  static void updateDefaultHeaders(String organizationIDF) {
    defaultHeaders["appid"] = organizationIDF;
    // notifyListeners();
  }

  Future<http.Response> callApiWithHeadersAndBody({
    String? url,
    Map<String, String>? headers,
    dynamic body,
  }) async {

    // Merge default headers with provided headers (if any)
    Map<String, String> mergedHeaders = {...defaultHeaders, ...?headers};

    var response = await http.post(
      Uri.parse(url!),
      headers: mergedHeaders,
      body: body,
    );

    return response;
  }

  Future<http.StreamedResponse> callMultipartApi(
      MultipartRequest multipartRequest) async {
    // Add default headers for multipart requests if needed
    // multipartRequest.headers.addAll(defaultHeaders);

    var response = await multipartRequest.send();
    return response;
  }
}
