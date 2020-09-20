import 'package:flutter/material.dart';

bool isAdult(String birthDate) {
  DateTime now = DateTime.now();
  List<String> parts = birthDate.split("/");
  DateTime dateOfBirth = DateTime(
      int.parse(parts[2]), int.parse(parts[1]) - 1, int.parse(parts[0]));
  int yearDiff = now.year - dateOfBirth.year;
  int monthDiff = now.month - dateOfBirth.month;
  int dayDiff = now.day - dateOfBirth.day;
  return yearDiff > 18 || yearDiff == 18 && monthDiff == 0 && dayDiff == 0;
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
