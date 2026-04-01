import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _darkModeSet = prefs.getBool('ff_darkModeSet') ?? _darkModeSet;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _darkModeSet = false;
  bool get darkModeSet => _darkModeSet;
  set darkModeSet(bool value) {
    _darkModeSet = value;
    prefs.setBool('ff_darkModeSet', value);
  }

  String _uploadedimageurl = '';
  String get uploadedimageurl => _uploadedimageurl;
  set uploadedimageurl(String value) {
    _uploadedimageurl = value;
  }

  int _numberofparametrs = 0;
  int get numberofparametrs => _numberofparametrs;
  set numberofparametrs(int value) {
    _numberofparametrs = value;
  }

  String _userProfilePicture = '';
  String get userProfilePicture => _userProfilePicture;
  set userProfilePicture(String value) {
    _userProfilePicture = value;
  }

  bool _subscriptionmonth = false;
  bool get subscriptionmonth => _subscriptionmonth;
  set subscriptionmonth(bool value) {
    _subscriptionmonth = value;
  }

  bool _isprouser = false;
  bool get isprouser => _isprouser;
  set isprouser(bool value) {
    _isprouser = value;
  }

  bool _analysisloading = false;
  bool get analysisloading => _analysisloading;
  set analysisloading(bool value) {
    _analysisloading = value;
  }

  String _countrycode = '';
  String get countrycode => _countrycode;
  set countrycode(String value) {
    _countrycode = value;
  }

  String _uploudedimagepath = '';
  String get uploudedimagepath => _uploudedimagepath;
  set uploudedimagepath(String value) {
    _uploudedimagepath = value;
  }

  List<int> _spamlist = [];
  List<int> get spamlist => _spamlist;
  set spamlist(List<int> value) {
    _spamlist = value;
  }

  void addToSpamlist(int value) {
    spamlist.add(value);
  }

  void removeFromSpamlist(int value) {
    spamlist.remove(value);
  }

  void removeAtIndexFromSpamlist(int index) {
    spamlist.removeAt(index);
  }

  void updateSpamlistAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    spamlist[index] = updateFn(_spamlist[index]);
  }

  void insertAtIndexInSpamlist(int index, int value) {
    spamlist.insert(index, value);
  }

  int _analysesused = 0;
  int get analysesused => _analysesused;
  set analysesused(int value) {
    _analysesused = value;
  }

  int _Producanalysstate = 0;
  int get Producanalysstate => _Producanalysstate;
  set Producanalysstate(int value) {
    _Producanalysstate = value;
  }

  String _extractedProductName = '';
  String get extractedProductName => _extractedProductName;
  set extractedProductName(String value) {
    _extractedProductName = value;
  }

  String _extractedBrand = '';
  String get extractedBrand => _extractedBrand;
  set extractedBrand(String value) {
    _extractedBrand = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
