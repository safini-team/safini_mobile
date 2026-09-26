import 'package:shared_preferences/shared_preferences.dart';

/// What setup has already been seen on this phone. Local on purpose: a step
/// once done stays ticked even if the parent later deletes the task or prize
/// that ticked it, and nothing here is worth an API round trip.
///
/// Every call is a no-op when the prefs plugin is missing (see
/// `configureDependencies`), which only costs a checklist that forgets.
class OnboardingStore {
  OnboardingStore(this._prefs);

  final SharedPreferences? _prefs;

  static String _doneKey(String familyId) => 'onboarding.done.$familyId';
  static String _hiddenKey(String familyId) => 'onboarding.hidden.$familyId';
  static String _helloKey(String childId) => 'onboarding.kidHello.$childId';

  Set<String> done(String familyId) =>
      (_prefs?.getStringList(_doneKey(familyId)) ?? const []).toSet();

  Future<void> saveDone(String familyId, Set<String> steps) async =>
      _prefs?.setStringList(_doneKey(familyId), steps.toList()..sort());

  bool isHidden(String familyId) =>
      _prefs?.getBool(_hiddenKey(familyId)) ?? false;

  Future<void> hide(String familyId) async =>
      _prefs?.setBool(_hiddenKey(familyId), true);

  bool kidHelloSeen(String childId) =>
      _prefs?.getBool(_helloKey(childId)) ?? false;

  Future<void> markKidHelloSeen(String childId) async =>
      _prefs?.setBool(_helloKey(childId), true);
}
