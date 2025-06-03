import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _soundEnabledKey = 'sound_enabled';
  
  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding preferences
  Future<bool> getHasSeenOnboarding() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_hasSeenOnboardingKey, value);
  }

  // Sound preferences
  Future<bool> getSoundEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_soundEnabledKey, value);
  }
}
