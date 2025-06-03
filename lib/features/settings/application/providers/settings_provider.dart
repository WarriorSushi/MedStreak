import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/game/domain/models/medical_parameter.dart';

/// Keys for storing settings in SharedPreferences
class SettingsKeys {
  static const String unitSystem = 'unit_system';
  static const String sexContext = 'sex_context';
  static const String darkMode = 'dark_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String language = 'language';
}

/// Settings state model that holds all user preferences
class SettingsState {
  final UnitSystem unitSystem;
  final SexContext sexContext;
  final bool darkMode;
  final bool notificationsEnabled;
  final String language;

  const SettingsState({
    required this.unitSystem,
    required this.sexContext,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.language,
  });

  /// Default settings
  factory SettingsState.defaults() {
    return const SettingsState(
      unitSystem: UnitSystem.si, // Default to SI units
      sexContext: SexContext.neutral, // Default to neutral sex context
      darkMode: false,
      notificationsEnabled: true,
      language: 'en', // Default to English
    );
  }

  /// Copy the current state with specified modifications
  SettingsState copyWith({
    UnitSystem? unitSystem,
    SexContext? sexContext,
    bool? darkMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return SettingsState(
      unitSystem: unitSystem ?? this.unitSystem,
      sexContext: sexContext ?? this.sexContext,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }
}

/// Provider to access the shared preferences instance
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Provider to manage user settings
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences? _prefs;

  SettingsNotifier(this._prefs) : super(SettingsState.defaults()) {
    if (_prefs != null) {
      _loadSettings();
    }
  }

  /// Constructor that creates a notifier with default settings and no persistence
  /// Used as a fallback when SharedPreferences is not yet initialized
  factory SettingsNotifier.withDefaults() {
    return SettingsNotifier(null);
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    if (_prefs == null) return;

    final unitSystemIndex = _prefs.getInt(SettingsKeys.unitSystem);
    final sexContextIndex = _prefs.getInt(SettingsKeys.sexContext);
    final darkMode = _prefs.getBool(SettingsKeys.darkMode);
    final notificationsEnabled = _prefs.getBool(
      SettingsKeys.notificationsEnabled,
    );
    final language = _prefs.getString(SettingsKeys.language);

    state = state.copyWith(
      unitSystem: unitSystemIndex != null
          ? UnitSystem.values[unitSystemIndex]
          : UnitSystem.si,
      sexContext: sexContextIndex != null
          ? SexContext.values[sexContextIndex]
          : SexContext.neutral,
      darkMode: darkMode ?? false,
      notificationsEnabled: notificationsEnabled ?? true,
      language: language ?? 'en',
    );
  }

  /// Update the unit system preference (SI or Conventional)
  Future<void> setUnitSystem(UnitSystem unitSystem) async {
    // Update state immediately regardless of persistence
    state = state.copyWith(unitSystem: unitSystem);

    // Persist if possible
    if (_prefs != null) {
      await _prefs.setInt(SettingsKeys.unitSystem, unitSystem.index);
    }
  }

  /// Toggle between SI and Conventional units
  Future<void> toggleUnitSystem() async {
    final newUnitSystem = state.unitSystem == UnitSystem.si
        ? UnitSystem.conventional
        : UnitSystem.si;
    await setUnitSystem(newUnitSystem);
  }

  /// Update the sex context preference (Male, Female, or Neutral)
  Future<void> setSexContext(SexContext sexContext) async {
    // Update state immediately regardless of persistence
    state = state.copyWith(sexContext: sexContext);

    // Persist if possible
    if (_prefs != null) {
      await _prefs.setInt(SettingsKeys.sexContext, sexContext.index);
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newValue = !state.darkMode;
    state = state.copyWith(darkMode: newValue);

    // Persist if possible
    if (_prefs != null) {
      await _prefs.setBool(SettingsKeys.darkMode, newValue);
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newValue);

    // Persist if possible
    if (_prefs != null) {
      await _prefs.setBool(SettingsKeys.notificationsEnabled, newValue);
    }
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    state = state.copyWith(language: languageCode);

    // Persist if possible
    if (_prefs != null) {
      await _prefs.setString(SettingsKeys.language, languageCode);
    }
  }
}

/// Provider to access settings state with fallback to defaults if SharedPreferences is not ready
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    // Create a placeholder notifier with default settings
    final asyncPrefs = ref.watch(sharedPreferencesProvider);

    if (asyncPrefs.hasValue) {
      return SettingsNotifier(asyncPrefs.value!);
    } else {
      // Return a notifier with default settings that doesn't persist changes
      // This is temporary until SharedPreferences is initialized
      return SettingsNotifier.withDefaults();
    }
  },
);

/// Helper providers for individual settings
final unitSystemProvider = Provider<UnitSystem>((ref) {
  return ref.watch(settingsProvider).unitSystem;
});

final sexContextProvider = Provider<SexContext>((ref) {
  return ref.watch(settingsProvider).sexContext;
});

final darkModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).darkMode;
});
