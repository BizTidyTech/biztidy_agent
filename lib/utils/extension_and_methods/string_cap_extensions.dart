import 'dart:math';

extension StringCasesExtension on String {
  String get toSentenceCase =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  String get allToCapital => toUpperCase();
  String get toTitleCase =>
      split(" ").map((str) => str.toSentenceCase).join(" ");
}

String generateRandomString() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List.generate(15, (index) => chars[random.nextInt(chars.length)])
      .join();
}

Future<bool> validateEmail(String emailText) async {
  bool emailValidator = false;
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (emailText == '---') {
    emailValidator = false;
  } else {
    if (!regex.hasMatch(emailText)) {
      emailValidator = false;
    } else {
      emailValidator = true;
    }
  }
  return emailValidator;
}
