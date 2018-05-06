import 'dart:io';
import 'package:path_provider/path_provider.dart';

// This function simply removes the config file in order to
// log out the user. Once called, the will no longer be a
// user on file so the app will go to the login screen.
logOut() async {
  // Find the directory where the app stores its files
  Directory appDocDir = await getApplicationDocumentsDirectory();
  // Get a handle for the config.json file
  File configFile = new File("${appDocDir.path}/config.json");
  // Delete the config file
  await configFile.delete();
}