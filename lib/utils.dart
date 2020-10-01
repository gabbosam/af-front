import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get serverIp {
  return DotEnv().env['SERVER_IP'];
}

String get apiKey {
  return DotEnv().env['API_KEY'];
}

String get environment {
  return DotEnv().env['ENV'];
}

bool isNullOrEmpty(String value) {
  return value == null || value.isEmpty;
}

bool isAdult(String birthDate) {
  DateTime now = DateTime.now();
  List<String> parts = birthDate.split("/");
  DateTime dateOfBirth =
      DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  int yearDiff = now.year - dateOfBirth.year;
  int monthDiff = now.month - dateOfBirth.month;
  int dayDiff = now.day - dateOfBirth.day;
  return yearDiff > 18 || yearDiff == 18 && monthDiff == 0 && dayDiff == 0;
}

List<int> surveyDayLeft(String lastEdit) {
  if (isNullOrEmpty(lastEdit)) return [];
  DateTime now = DateTime.now();
  List<String> parts = lastEdit.split("/");
  DateTime lastEditDate =
      DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  Duration difference = now.difference(lastEditDate);
  int dayDiff = 14 - difference.inDays;
  int yearDiff = now.year - lastEditDate.year;
  int monthDiff = now.month - lastEditDate.month;
  return [yearDiff, monthDiff, dayDiff];
}

bool needSurvey(String lastEdit) {
  var dayLeft = surveyDayLeft(lastEdit);
  if (dayLeft.isEmpty) return true;
  if (dayLeft[0] == 0 && dayLeft[1] == 0 && dayLeft[2] < 1) return true;
  return false;
}

SnackBar doneSnack(String message) {
  return SnackBar(
      content: Row(children: [
    Icon(Icons.done_outline),
    SizedBox(
      width: 5.0,
    ),
    Text(message)
  ]));
}

SnackBar failSnack(String message) {
  return SnackBar(
      content: Row(children: [
    Icon(Icons.error),
    SizedBox(
      width: 5.0,
    ),
    Text(message)
  ]));
}

void displayDialog(context, title, text) => showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );
