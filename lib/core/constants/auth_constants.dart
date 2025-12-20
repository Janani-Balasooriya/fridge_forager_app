class AuthConstants {
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String sessionBox = 'session_box';
  static const String preferencesBox = 'preferences_box';

  // Session Keys
  static const String userEmailKey = 'user_email';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userPhotoKey = 'user_photo';
  static const String rememberEmailKey = 'remember_email';

  // Error Messages
  static const String emailRequiredError = 'Email is required';
  static const String passwordRequiredError = 'Password is required';
  static const String invalidEmailError = 'Invalid email address';
  static const String weakPasswordError = 'Password is too weak';
  static const String emailInUseError = 'Email already in use';
  static const String userNotFoundError = 'User not found';
  static const String wrongPasswordError = 'Wrong password';
  static const String networkError = 'Network error. Check your connection';

  // OTP
  static const String otpLength = '6';
  static const int otpExpiryMinutes = 10;
}
