import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

String? _hour, _minute, _time;

DateTime selectedDate = DateTime.now();
TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);

TextEditingController _dateController = TextEditingController();
TextEditingController _timeController = TextEditingController();

Future<Map<String, dynamic>> selectDate(
  BuildContext context,
  StateSetter setState,
  DateTime currentDate,
) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    initialDatePickerMode: DatePickerMode.day,
    firstDate: DateTime(2015),
    lastDate: DateTime(2101),
    currentDate: currentDate,
  );
  if (picked != null)
    setState(() {
      selectedDate = picked;
      _dateController.text = DateFormat.yMMMMd().format(selectedDate);
    });

  // return picked!;
  Map<String, dynamic> dateMap = {
    'displayDate': _dateController.text,
    'tsDate': picked,
  };
  // return _dateController.text;
  return dateMap;
}

Future<String> selectTime(BuildContext context, StateSetter setState) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
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

String convertTimeToTS(date, time) {
  var nowNanoSec = DateTime.now().toString().split('.').last;
  String _selectedTimeStamp = date.toString().split(' ').first +
      ' ' +
      time.toString().split(' ').first +
      ':00.$nowNanoSec';
  print(_selectedTimeStamp);
  return _selectedTimeStamp;
}
