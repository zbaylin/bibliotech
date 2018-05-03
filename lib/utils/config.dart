import 'package:bibliotech/config.dart' as config;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

cacheConfig() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  File configFile = new File("${appDocDir.path}/config.json");
  Map json = JSON.decode(await configFile.readAsString());
  json['goodreads']['user_key'] = config.goodreads['userKey'];
  await configFile.writeAsString(JSON.encode(json));
}