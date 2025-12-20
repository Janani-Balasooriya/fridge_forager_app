import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/hive_service.dart';
import '../logic/auth_exceptions.dart';
import '../logic/user_model.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final HiveService _hiveService = HiveService();

  static final AuthService _instance = AuthService._internal();
  static final Map<String, String> _otpStorage = {};

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String _generateOTP() {
    final random = Random();
    return List<int>.generate(6, (i) => random.nextInt(10)).join();
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _hiveService.saveUser(user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final cachedUser = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );
        await _hiveService.saveUser(cachedUser);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    try {
      final otp = _generateOTP();
      _otpStorage[email] = otp;

      debugPrint('OTP for password reset: $otp');

      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error generating OTP: $e');
      throw GenericAuthException();
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final storedOtp = _otpStorage[email];
      if (storedOtp == null || storedOtp != otp) {
        throw OTPAuthException();
      }
      return true;
    } catch (e) {
      throw OTPAuthException();
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      final isValidOtp = await verifyOTP(email, otp);
      if (!isValidOtp) {
        throw OTPAuthException();
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);

      debugPrint('Password reset email sent to: $email');

      _otpStorage.remove(email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _hiveService.clearSession();
    } catch (e) {
      debugPrint('Error logging out: $e');
      throw GenericAuthException();
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  UserModel? getCachedUser(String uid) {
    return _hiveService.getUser(uid);
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return UserNotFoundAuthException();
      case 'wrong-password':
        return WrongPasswordAuthException();
      case 'weak-password':
        return WeakPasswordAuthException();
      case 'email-already-in-use':
        return EmailAlreadyInUseAuthException();
      case 'invalid-email':
        return InvalidEmailAuthException();
      case 'user-disabled':
        return UserDisabledAuthException();
      case 'network-request-failed':
        return NetworkAuthException();
      default:
        return UnknownAuthException(e.message ?? 'Unknown error');
    }
  }
}
