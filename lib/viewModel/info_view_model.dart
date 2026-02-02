import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reports/utils/app_version_control.dart';

/// ViewModel for Info screen: app version, latest version, email launch.
class InfoViewModel extends ChangeNotifier {
  InfoViewModel();

  String _version = '';
  String get version => _version;

  String _latestVersionAvailable = '';
  String get latestVersionAvailable => _latestVersionAvailable;

  static const String devName = 'Alex De Pasquale';
  static const String devEmailAddress = 'depasquale.alex@gmail.com';

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    notifyListeners();
  }

  Future<void> loadLatestVersionAvailable() async {
    _latestVersionAvailable = await AppVersionControl().latestVersionAvailable;
    notifyListeners();
  }

  Future<void> launchEmail(String emailAddress) async {
    await Future.value();
  }
}
