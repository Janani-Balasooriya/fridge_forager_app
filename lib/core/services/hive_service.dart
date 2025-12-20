import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/logic/user_model.dart';
import '../../core/constants/auth_constants.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Future<void> initializeUserBox() async {
    if (!Hive.isBoxOpen(AuthConstants.userBox)) {
      await Hive.openBox<UserModel>(AuthConstants.userBox);
    }
  }

  Future<void> initializeSessionBox() async {
    if (!Hive.isBoxOpen(AuthConstants.sessionBox)) {
      await Hive.openBox(AuthConstants.sessionBox);
    }
  }

  Future<void> initializePreferencesBox() async {
    if (!Hive.isBoxOpen(AuthConstants.preferencesBox)) {
      await Hive.openBox(AuthConstants.preferencesBox);
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final box = Hive.box<UserModel>(AuthConstants.userBox);
      await box.put(user.uid, user);
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  UserModel? getUser(String uid) {
    try {
      final box = Hive.box<UserModel>(AuthConstants.userBox);
      return box.get(uid);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      final box = Hive.box<UserModel>(AuthConstants.userBox);
      await box.delete(uid);
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }

  Future<void> saveSession(String key, dynamic value) async {
    try {
      final box = Hive.box(AuthConstants.sessionBox);
      await box.put(key, value);
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  dynamic getSession(String key) {
    try {
      final box = Hive.box(AuthConstants.sessionBox);
      return box.get(key);
    } catch (e) {
      debugPrint('Error getting session: $e');
      return null;
    }
  }

  Future<void> deleteSession(String key) async {
    try {
      final box = Hive.box(AuthConstants.sessionBox);
      await box.delete(key);
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }

  Future<void> clearSession() async {
    try {
      final box = Hive.box(AuthConstants.sessionBox);
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  Future<void> savePreference(String key, dynamic value) async {
    try {
      final box = Hive.box(AuthConstants.preferencesBox);
      await box.put(key, value);
    } catch (e) {
      debugPrint('Error saving preference: $e');
    }
  }

  dynamic getPreference(String key) {
    try {
      final box = Hive.box(AuthConstants.preferencesBox);
      return box.get(key);
    } catch (e) {
      debugPrint('Error getting preference: $e');
      return null;
    }
  }

  String? getSavedEmail() {
    try {
      final box = Hive.box(AuthConstants.preferencesBox);
      return box.get(AuthConstants.rememberEmailKey) as String?;
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }

  Future<void> saveEmail(String email, bool remember) async {
    try {
      final box = Hive.box(AuthConstants.preferencesBox);
      if (remember) {
        await box.put(AuthConstants.rememberEmailKey, email);
      } else {
        await box.delete(AuthConstants.rememberEmailKey);
      }
    } catch (e) {
      debugPrint('Error saving email preference: $e');
    }
  }
}
