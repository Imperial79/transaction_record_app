// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Book {
  String bookId = '';
  String bookName = '';
  String bookDescription = '';
  String date = '';
  double expense = 0.0;
  double income = 0.0;
  String time = '';
  String type = '';
  String uid = '';
  List<dynamic>? users = [];
  Book({
    required this.bookId,
    required this.bookName,
    required this.bookDescription,
    required this.date,
    required this.expense,
    required this.income,
    required this.time,
    required this.type,
    required this.uid,
    this.users,
  });

  Book copyWith({
    String? bookId,
    String? bookName,
    String? bookDescription,
    String? date,
    double? expense,
    double? income,
    String? time,
    String? type,
    String? uid,
    List<dynamic>? users,
  }) {
    return Book(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      bookDescription: bookDescription ?? this.bookDescription,
      date: date ?? this.date,
      expense: expense ?? this.expense,
      income: income ?? this.income,
      time: time ?? this.time,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bookId': bookId,
      'bookName': bookName,
      'bookDescription': bookDescription,
      'date': date,
      'expense': expense,
      'income': income,
      'time': time,
      'type': type,
      'uid': uid,
      'users': users,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      bookId: map['bookId'] as String,
      bookName: map['bookName'] as String,
      bookDescription: map['bookDescription'] as String,
      date: map['date'] as String,
      expense: double.parse("${map['expense']}"),
      income: double.parse("${map['income']}"),
      time: map['time'] as String,
      type: map['type'] as String,
      uid: map['uid'] as String,
      users: map['users'] != null
          ? List<dynamic>.from((map['users'] as List<dynamic>))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) =>
      Book.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Book(bookId: $bookId, bookName: $bookName, bookDescription: $bookDescription, date: $date, expense: $expense, income: $income, time: $time, type: $type, uid: $uid, users: $users)';
  }

  @override
  bool operator ==(covariant Book other) {
    if (identical(this, other)) return true;

    return other.bookId == bookId &&
        other.bookName == bookName &&
        other.bookDescription == bookDescription &&
        other.date == date &&
        other.expense == expense &&
        other.income == income &&
        other.time == time &&
        other.type == type &&
        other.uid == uid &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return bookId.hashCode ^
        bookName.hashCode ^
        bookDescription.hashCode ^
        date.hashCode ^
        expense.hashCode ^
        income.hashCode ^
        time.hashCode ^
        type.hashCode ^
        uid.hashCode ^
        users.hashCode;
  }
}
