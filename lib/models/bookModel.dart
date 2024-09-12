// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class BookModel {
  String bookId = '';
  String bookName = '';
  String bookDescription = '';
  String date = '';
  double expense = 0.0;
  double income = 0.0;
  String time = '';
  String type = '';
  String uid = '';
  String createdAt = '';
  double targetAmount = 0;
  List<dynamic>? users = [];
  BookModel({
    required this.bookId,
    required this.bookName,
    required this.bookDescription,
    required this.date,
    required this.expense,
    required this.income,
    required this.time,
    required this.type,
    required this.uid,
    required this.createdAt,
    required this.targetAmount,
    this.users,
  });

  BookModel copyWith({
    String? bookId,
    String? bookName,
    String? bookDescription,
    String? date,
    double? expense,
    double? income,
    String? time,
    String? type,
    String? uid,
    String? createdAt,
    double? targetAmount,
    List<dynamic>? users,
  }) {
    return BookModel(
      bookId: bookId ?? this.bookId,
      bookName: bookName ?? this.bookName,
      bookDescription: bookDescription ?? this.bookDescription,
      date: date ?? this.date,
      expense: expense ?? this.expense,
      income: income ?? this.income,
      time: time ?? this.time,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      targetAmount: targetAmount ?? this.targetAmount,
      users: users ?? this.users,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookName': bookName,
      'bookDescription': bookDescription,
      'date': date,
      'expense': expense,
      'income': income,
      'time': time,
      'type': type,
      'uid': uid,
      'createdAt': createdAt,
      'targetAmount': targetAmount,
      'users': users,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      bookId: map['bookId'] ?? '',
      bookName: map['bookName'] ?? '',
      bookDescription: map['bookDescription'] ?? '',
      date: map['date'] ?? '',
      expense: map['expense']?.toDouble() ?? 0.0,
      income: map['income']?.toDouble() ?? 0.0,
      time: map['time'] ?? '',
      type: map['type'] ?? '',
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? '',
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      users: List<dynamic>.from(map['users']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BookModel.fromJson(String source) =>
      BookModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Book(bookId: $bookId, bookName: $bookName, bookDescription: $bookDescription, date: $date, expense: $expense, income: $income, time: $time, type: $type, uid: $uid, createdAt: $createdAt, users: $users)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookModel &&
        other.bookId == bookId &&
        other.bookName == bookName &&
        other.bookDescription == bookDescription &&
        other.date == date &&
        other.expense == expense &&
        other.income == income &&
        other.time == time &&
        other.type == type &&
        other.uid == uid &&
        other.createdAt == createdAt &&
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
        createdAt.hashCode ^
        users.hashCode;
  }
}
