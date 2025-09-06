class Validators {
  static bool isValidEmail(String email) {
    const pattern = r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }

  static bool isNonEmpty(String value) => value.trim().isNotEmpty;
}
