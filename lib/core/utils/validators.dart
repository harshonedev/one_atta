class EmailValidator {
  static bool isValid(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}

class PasswordValidator {
  static bool isValid(String password) {
    return password.length >= 6;
  }

  static bool isStrong(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special character
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(password);
  }
}
