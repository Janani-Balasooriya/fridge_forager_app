import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Listen to Firebase Auth changes (Logged In / Logged Out)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Get the Current User ID (Helper)
// If logged in -> returns Real UID
// If logged out -> returns "user_1" (Temporary Default so app works while testing)
final userIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.uid ?? "user_1"; 
});