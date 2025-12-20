sealed class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class UserNotFoundAuthException extends AuthException {
  UserNotFoundAuthException() : super('User not found');
}

class WrongPasswordAuthException extends AuthException {
  WrongPasswordAuthException() : super('Wrong password');
}

class WeakPasswordAuthException extends AuthException {
  WeakPasswordAuthException() : super('Password is too weak');
}

class EmailAlreadyInUseAuthException extends AuthException {
  EmailAlreadyInUseAuthException() : super('Email already in use');
}

class InvalidEmailAuthException extends AuthException {
  InvalidEmailAuthException() : super('Invalid email address');
}

class UserDisabledAuthException extends AuthException {
  UserDisabledAuthException() : super('User account has been disabled');
}

class GenericAuthException extends AuthException {
  GenericAuthException() : super('An authentication error occurred');
}

class NetworkAuthException extends AuthException {
  NetworkAuthException() : super('Network error. Check your connection');
}

class OTPAuthException extends AuthException {
  OTPAuthException() : super('Invalid or expired OTP');
}

class UnknownAuthException extends AuthException {
  UnknownAuthException(String message) : super(message);
}
