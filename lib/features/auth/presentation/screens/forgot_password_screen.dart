import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/validators.dart';
import '../../logic/auth_notifier.dart';
import '../../logic/auth_exceptions.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  int _otpCountdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startOTPCountdown() {
    setState(() => _otpCountdown = 60);
    Future.delayed(const Duration(seconds: 1), _decrementCountdown);
  }

  void _decrementCountdown() {
    if (_otpCountdown > 0) {
      setState(() => _otpCountdown--);
      Future.delayed(const Duration(seconds: 1), _decrementCountdown);
    }
  }

  void _handleSendOTP() async {
    if (_emailController.text.isEmpty ||
        !AuthValidator.isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPasswordResetOTP(_emailController.text.trim());

      setState(() => _otpSent = true);
      _startOTPCountdown();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent to your email')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _handleVerifyOTP() async {
    if (_otpController.text.isEmpty ||
        AuthValidator.validateOTP(_otpController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    try {
      final isValid = await ref
          .read(authNotifierProvider.notifier)
          .verifyOTP(_emailController.text.trim(), _otpController.text);

      if (isValid) {
        setState(() => _otpVerified = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verified successfully')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _handleResetPassword() async {
    if (_newPasswordController.text.isEmpty ||
        AuthValidator.validatePassword(_newPasswordController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      await ref.read(authNotifierProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
            newPassword: _newPasswordController.text,
            otp: _otpController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email to receive an OTP',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_otpSent) ...[
                AuthInputField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AuthValidator.validateEmail,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleSendOTP,
                  child: const Text('Send OTP'),
                ),
              ] else if (!_otpVerified) ...[
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${_emailController.text}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                AuthInputField(
                  label: 'OTP',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  validator: AuthValidator.validateOTP,
                ),
                const SizedBox(height: 12),
                if (_otpCountdown > 0)
                  Text(
                    'Resend OTP in ${_otpCountdown}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  )
                else
                  TextButton(
                    onPressed: _handleSendOTP,
                    child: const Text('Resend OTP'),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleVerifyOTP,
                  child: const Text('Verify OTP'),
                ),
              ] else ...[
                Text(
                  'New Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                AuthInputField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  validator: AuthValidator.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showNewPassword = !_showNewPassword);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AuthInputField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  validator: (value) => AuthValidator.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(
                          () => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleResetPassword,
                  child: const Text('Reset Password'),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
