import 'package:bibliotech/config.dart' as config;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

// Allows us to update the configuration file in order to
// save the GoodReads key once logged in.
cacheConfig() async {
  // Find the location the operating system gave to our
  // app for configuration
  Directory appDocDir = await getApplicationDocumentsDirectory();
  // Create a handle for the config.json file in that dir
  File configFile = new File("${appDocDir.path}/config.json");
  // Read in the current config.json and parse it
  Map json = JSON.decode(await configFile.readAsString());
  // Write the new JSON object asynchronously to the file
  await configFile.writeAsString(JSON.encode(json));
}