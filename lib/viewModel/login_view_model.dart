import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for Login screen: remember me, app version, download latest.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel();

  bool _rememberBoxValue = true;
  bool get rememberBoxValue => _rememberBoxValue;

  String _appVersion = '';
  String get appVersion => _appVersion;

  bool _isDownloadButtonPressed = false;
  bool get isDownloadButtonPressed => _isDownloadButtonPressed;

  Future<void> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberBoxValue = prefs.getBool('rememberMePreference') ?? true;
    notifyListeners();
  }

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMePreference', value);
    _rememberBoxValue = value;
    notifyListeners();
  }

  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    notifyListeners();
  }

  void setDownloadButtonPressed(bool value) {
    _isDownloadButtonPressed = value;
    notifyListeners();
  }

  bool isLatestVersion(String latestVersion) {
    return _appVersion == latestVersion;
  }
}
