import 'dart:io';
import 'package:path/path.dart';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  Map<String, String> envVars = Platform.environment;
  // C:\Users\0736b\AppData\Local\Android\Sdk\platform-tools
  // print(envVars['UserProfile']);
  // var adbPath = "C:\\platform-tools\\adb.exe";
  var adbPath =
      '${envVars['UserProfile']}\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe';
  await Process.run(adbPath,
      ['shell', 'pm', 'grant', 'com.example.app', 'android.permission.CAMERA']);
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'com.example.app',
    'android.permission.WRITE_EXTERNAL_STORAGE'
  ]);
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'com.example.app',
    'android.permission.ACCESS_COARSE_LOCATION'
  ]);
  await Process.run(adbPath, [
    'shell',
    'pm',
    'grant',
    'com.example.app',
    'android.permission.ACCESS_FINE_LOCATION'
  ]);
  await integrationDriver();
}
