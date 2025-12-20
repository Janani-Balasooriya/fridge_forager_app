import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/auth_service.dart';
import '../logic/auth_exceptions.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid ?? "user_1";
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    final user = _authService.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await _authService.signup(
        email: email,
        password: password,
        name: name,
      );
      state = AsyncValue.data(userCredential.user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await _authService.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(userCredential.user);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    try {
      await _authService.sendPasswordResetOTP(email);
    } on AuthException catch (e) {
      debugPrint('Auth error: $e');
      rethrow;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      return await _authService.verifyOTP(email, otp);
    } on AuthException catch (e) {
      debugPrint('Verification error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      await _authService.resetPassword(
        email: email,
        newPassword: newPassword,
        otp: otp,
      );
    } on AuthException catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } on AuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
