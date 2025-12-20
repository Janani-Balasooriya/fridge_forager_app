import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  static const String _boxName = 'preferences_box';
  static const String _onboardingKey = 'has_completed_onboarding';

  Future<void> initializeBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  bool hasCompletedOnboarding() {
    try {
      final box = Hive.box(_boxName);
      return box.get(_onboardingKey, defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return false;
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_onboardingKey, true);
      debugPrint('Onboarding marked as complete');
    } catch (e) {
      debugPrint('Error marking onboarding complete: $e');
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_onboardingKey, false);
      debugPrint('Onboarding reset');
    } catch (e) {
      debugPrint('Error resetting onboarding: $e');
    }
  }
}
