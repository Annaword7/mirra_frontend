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
    _safeInit(() {
      _freeScanLimit = prefs.getInt('ff_freeScanLimit') ?? _freeScanLimit;
    });
    _safeInit(() {
      _showLinkTelegram = prefs.getBool('ff_showLinkTelegram') ?? _showLinkTelegram;
    });
    _safeInit(() {
      _onboardingDone = prefs.getBool('ff_onboardingDone') ?? _onboardingDone;
    });
    _safeInit(() {
      _homePipelineDoneUsers =
          prefs.getStringList('ff_homePipelineDoneUsers') ??
              _homePipelineDoneUsers;
    });
    _safeInit(() {
      _bagOnboardingDone =
          prefs.getBool('ff_bagOnboardingDone') ?? _bagOnboardingDone;
    });
    _safeInit(() {
      _bagScanCount = prefs.getInt('ff_bagScanCount') ?? _bagScanCount;
    });
    _safeInit(() {
      _bagOnboardingActive =
          prefs.getBool('ff_bagOnboardingActive') ?? _bagOnboardingActive;
    });
    _safeInit(() {
      _pendingBagSlot = prefs.getInt('ff_pendingBagSlot') ?? _pendingBagSlot;
    });
    _safeInit(() {
      _feedbackCollectorEnabled = prefs.getBool('ff_feedbackCollectorEnabled') ?? _feedbackCollectorEnabled;
    });
    _safeInit(() {
      _feedbackReviewSubmitted = prefs.getBool('ff_feedbackReviewSubmitted') ?? _feedbackReviewSubmitted;
    });
    _safeInit(() {
      _feedbackBannerDismissed = prefs.getBool('ff_feedbackBannerDismissed') ?? _feedbackBannerDismissed;
    });
    _safeInit(() {
      _feedbackLastShownVersion = prefs.getString('ff_feedbackLastShownVersion') ?? _feedbackLastShownVersion;
    });
    _safeInit(() {
      _feedbackLastShownMs = prefs.getInt('ff_feedbackLastShownMs') ?? _feedbackLastShownMs;
    });
    _safeInit(() {
      _feedbackUserId = prefs.getString('ff_feedbackUserId') ?? _feedbackUserId;
    });
    _safeInit(() {
      _userProfilePicture = prefs.getString('ff_userProfilePicture') ?? _userProfilePicture;
    });
    _safeInit(() {
      _obSkinType = prefs.getString('ff_obSkinType') ?? _obSkinType;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_obSensitive')) {
        _obSensitive = prefs.getBool('ff_obSensitive');
      }
    });
    _safeInit(() {
      _obPregnancy = prefs.getString('ff_obPregnancy') ?? _obPregnancy;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_obAcneProne')) {
        _obAcneProne = prefs.getBool('ff_obAcneProne');
      }
    });
    _safeInit(() {
      _obGoals = prefs.getStringList('ff_obGoals') ?? _obGoals;
    });
    _safeInit(() {
      _obAgeRange = prefs.getString('ff_obAgeRange') ?? _obAgeRange;
    });
    _safeInit(() {
      _obBudgetRange = prefs.getString('ff_obBudgetRange') ?? _obBudgetRange;
    });
    _safeInit(() {
      _obTrustedBrands = prefs.getStringList('ff_obTrustedBrands') ?? _obTrustedBrands;
    });
    _safeInit(() {
      _obPendingFlush = prefs.getBool('ff_obPendingFlush') ?? _obPendingFlush;
    });
    _safeInit(() {
      _obStep = prefs.getInt('ff_obStep') ?? _obStep;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;
  set onboardingDone(bool value) {
    _onboardingDone = value;
    prefs.setBool('ff_onboardingDone', value);
  }

  // Home 3-step "try all features" pipeline: hidden for good once a user has
  // completed all three steps at least once. Stored per user id, so it neither
  // leaks across accounts on logout nor reappears if products are later removed.
  List<String> _homePipelineDoneUsers = [];
  List<String> get homePipelineDoneUsers => _homePipelineDoneUsers;
  set homePipelineDoneUsers(List<String> value) {
    _homePipelineDoneUsers = value;
    prefs.setStringList('ff_homePipelineDoneUsers', value);
  }

  // Косметичка game-flow: whether the user has finished the initial 3-scan
  // intro. Separate from [onboardingDone] (the skin-type quiz) on purpose.
  bool _bagOnboardingDone = false;
  bool get bagOnboardingDone => _bagOnboardingDone;
  set bagOnboardingDone(bool value) {
    _bagOnboardingDone = value;
    prefs.setBool('ff_bagOnboardingDone', value);
  }

  // True only while a NEW user is inside the 3-scan game-flow. Gates the
  // scan-success reroute so existing users' scans are never hijacked.
  bool _bagOnboardingActive = false;
  bool get bagOnboardingActive => _bagOnboardingActive;
  set bagOnboardingActive(bool value) {
    _bagOnboardingActive = value;
    prefs.setBool('ff_bagOnboardingActive', value);
  }

  // Slot index awaiting a fresh scan (persistent bag "new scan" flow), or -1.
  // Persisted so it survives the scan round-trip even if the widget unmounts.
  int _pendingBagSlot = -1;
  int get pendingBagSlot => _pendingBagSlot;
  set pendingBagSlot(int value) {
    _pendingBagSlot = value;
    prefs.setInt('ff_pendingBagSlot', value);
  }

  // How many of the first 3 onboarding scans are done (0..3). Distinct from
  // [obStep] (the quiz resume point), which has its own lifecycle.
  int _bagScanCount = 0;
  int get bagScanCount => _bagScanCount;
  set bagScanCount(int value) {
    _bagScanCount = value;
    prefs.setInt('ff_bagScanCount', value);
  }

  bool _darkModeSet = false;
  bool get darkModeSet => _darkModeSet;
  set darkModeSet(bool value) {
    _darkModeSet = value;
    prefs.setBool('ff_darkModeSet', value);
  }

  // Free weekly scan limit. Source of truth is the app_config DB row
  // ('free_scan_limit'), fetched once per session; persisted so the value
  // survives offline / first paint before the DB read returns.
  int _freeScanLimit = 10;
  int get freeScanLimit => _freeScanLimit;
  set freeScanLimit(int value) {
    _freeScanLimit = value;
    prefs.setInt('ff_freeScanLimit', value);
  }

  // Whether to show the "Link Telegram" item in the profile menu.
  // Source of truth is app_config ('show_link_telegram'), default true.
  bool _showLinkTelegram = true;
  bool get showLinkTelegram => _showLinkTelegram;
  set showLinkTelegram(bool value) {
    _showLinkTelegram = value;
    prefs.setBool('ff_showLinkTelegram', value);
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
    prefs.setString('ff_userProfilePicture', value);
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

  String _countrycodeiso = '';
  String get countrycodeiso => _countrycodeiso;
  set countrycodeiso(String value) {
    _countrycodeiso = value;
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

  // Session-only: start of the current 7-day scan window (from users.last_reset_date).
  // Null means the user has not started a window yet (0 scans used).
  DateTime? weekResetDate;

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

  // Feedback Collector
  bool feedbackPendingScan = false; // session-only, not persisted

  bool _feedbackCollectorEnabled = false;
  bool get feedbackCollectorEnabled => _feedbackCollectorEnabled;
  set feedbackCollectorEnabled(bool value) {
    _feedbackCollectorEnabled = value;
    prefs.setBool('ff_feedbackCollectorEnabled', value);
  }

  bool _feedbackReviewSubmitted = false;
  bool get feedbackReviewSubmitted => _feedbackReviewSubmitted;
  set feedbackReviewSubmitted(bool value) {
    _feedbackReviewSubmitted = value;
    prefs.setBool('ff_feedbackReviewSubmitted', value);
  }

  bool _feedbackBannerDismissed = false;
  bool get feedbackBannerDismissed => _feedbackBannerDismissed;
  set feedbackBannerDismissed(bool value) {
    _feedbackBannerDismissed = value;
    prefs.setBool('ff_feedbackBannerDismissed', value);
  }

  String _feedbackLastShownVersion = '';
  String get feedbackLastShownVersion => _feedbackLastShownVersion;
  set feedbackLastShownVersion(String value) {
    _feedbackLastShownVersion = value;
    prefs.setString('ff_feedbackLastShownVersion', value);
  }

  int _feedbackLastShownMs = 0;
  int get feedbackLastShownMs => _feedbackLastShownMs;
  set feedbackLastShownMs(int value) {
    _feedbackLastShownMs = value;
    prefs.setInt('ff_feedbackLastShownMs', value);
  }

  String _feedbackUserId = '';
  String get feedbackUserId => _feedbackUserId;
  set feedbackUserId(String value) {
    _feedbackUserId = value;
    prefs.setString('ff_feedbackUserId', value);
  }

  // ── Onboarding skin-profile buffer ──
  // Answers are collected pre-login and persisted so the quiz survives an app
  // kill mid-flow (spec §5 "бросил на середине"). Flushed to users + cleared
  // on the first authenticated screen when [obPendingFlush] is true.

  String? _obSkinType;
  String? get obSkinType => _obSkinType;
  set obSkinType(String? value) {
    _obSkinType = value;
    value == null
        ? prefs.remove('ff_obSkinType')
        : prefs.setString('ff_obSkinType', value);
  }

  bool? _obSensitive;
  bool? get obSensitive => _obSensitive;
  set obSensitive(bool? value) {
    _obSensitive = value;
    value == null
        ? prefs.remove('ff_obSensitive')
        : prefs.setBool('ff_obSensitive', value);
  }

  bool? _obAcneProne;
  bool? get obAcneProne => _obAcneProne;
  set obAcneProne(bool? value) {
    _obAcneProne = value;
    value == null
        ? prefs.remove('ff_obAcneProne')
        : prefs.setBool('ff_obAcneProne', value);
  }

  // Карта клиента (M1): pregnancy_status из квиза (буфер до логина).
  String? _obPregnancy;
  String? get obPregnancy => _obPregnancy;
  set obPregnancy(String? value) {
    _obPregnancy = value;
    value == null
        ? prefs.remove('ff_obPregnancy')
        : prefs.setString('ff_obPregnancy', value);
  }

  List<String> _obGoals = [];
  List<String> get obGoals => _obGoals;
  set obGoals(List<String> value) {
    _obGoals = value;
    prefs.setStringList('ff_obGoals', value);
  }

  String? _obAgeRange;
  String? get obAgeRange => _obAgeRange;
  set obAgeRange(String? value) {
    _obAgeRange = value;
    value == null
        ? prefs.remove('ff_obAgeRange')
        : prefs.setString('ff_obAgeRange', value);
  }

  String? _obBudgetRange;
  String? get obBudgetRange => _obBudgetRange;
  set obBudgetRange(String? value) {
    _obBudgetRange = value;
    value == null
        ? prefs.remove('ff_obBudgetRange')
        : prefs.setString('ff_obBudgetRange', value);
  }

  List<String> _obTrustedBrands = [];
  List<String> get obTrustedBrands => _obTrustedBrands;
  set obTrustedBrands(List<String> value) {
    _obTrustedBrands = value;
    prefs.setStringList('ff_obTrustedBrands', value);
  }

  bool _obPendingFlush = false;
  bool get obPendingFlush => _obPendingFlush;
  set obPendingFlush(bool value) {
    _obPendingFlush = value;
    prefs.setBool('ff_obPendingFlush', value);
  }

  // Resume point for an interrupted quiz (step index).
  int _obStep = 0;
  int get obStep => _obStep;
  set obStep(int value) {
    _obStep = value;
    prefs.setInt('ff_obStep', value);
  }

  /// Wipe the buffered onboarding answers (after a successful flush, or on
  /// "Пропустить"). Does not touch [onboardingDone].
  void clearOnboardingBuffer() {
    obSkinType = null;
    obSensitive = null;
    obAcneProne = null;
    obPregnancy = null;
    obGoals = [];
    obAgeRange = null;
    obBudgetRange = null;
    obTrustedBrands = [];
    obPendingFlush = false;
    obStep = 0;
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
