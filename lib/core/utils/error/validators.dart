class Validators {
  static bool isEmail(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value.trim());
  }

  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  const Validators._();
}
