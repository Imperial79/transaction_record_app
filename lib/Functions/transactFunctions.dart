import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

String? _hour, _minute, _time;

DateTime selectedDate = DateTime.now();
TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

TextEditingController _dateController = TextEditingController();
TextEditingController _timeController = TextEditingController();

Future<DateTime> selectDate(BuildContext context, StateSetter setState) async {
  final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101));
  if (picked != null)
    setState(() {
      selectedDate = picked;
      _dateController.text = DateFormat.yMd().format(selectedDate);
    });

  return selectedDate;
}

Future<String> selectTime(BuildContext context, StateSetter setState) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: selectedTime,
  );
  if (picked != null)
    setState(() {
      selectedTime = picked;
      _hour = selectedTime.hour.toString();
      _minute = selectedTime.minute.toString();
      _time = _hour! + ' : ' + _minute!;
      _timeController.text = _time!;
      _timeController.text = formatDate(
          DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
          [hh, ':', nn, " ", am]).toString();
    });

  return _timeController.text;
}
