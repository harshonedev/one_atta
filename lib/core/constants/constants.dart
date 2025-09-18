class ApiEndpoints {
  static const String baseUrl = 'https://api.oneatta.com/api/app';
  static const String auth = '$baseUrl/auth';
  static const String blends = '$baseUrl/blends';
}

class AppConstants {
  static const String appName = 'One Atta';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String appAPIKey = "Q8vjsTrlKX12bFNw3VHAyqGZ4Ch9xRpUWoaMfdPziE";
}

class AppStrings {
  // Auth related strings
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String signInToYourAccount = 'Sign in to your account';
  static const String createYourAccount = 'Create your account';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';

  // Error messages
  static const String invalidEmail = 'Please enter a valid email';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';

  // Success messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logout successful';
  static const String passwordResetSent =
      'Password reset link sent to your email';
}
