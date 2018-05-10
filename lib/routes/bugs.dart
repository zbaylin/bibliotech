import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bibliotech/config.dart' as config;

//Allows a user to report a bug, which will appear in the admin panel of the library
Future<Map> submitBugReport(String message) async {
  final response = await http.post("${config.hostname}/report/${config.username}/submit", body: {'message': message});
  if (response.statusCode == 200) {
    return {'success': true, 'message': "Successfully reported a bug!"};
  } else {
    return {'success': false, 'message': "Couldn't report the bug: ${response.reasonPhrase}!"};
  }
}