import 'dart:io';
import 'package:path_provider/path_provider.dart';

logOut() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  File configFile = new File("${appDocDir.path}/config.json");
  await configFile.delete();
}