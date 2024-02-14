// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Transact {
  String uid = "";
  String transactId = "";
  String amount = "";
  String source = "";
  String transactMode = "";
  String description = "";
  String type = "";
  String date = "";
  String time = "";
  String bookId = "";
  String ts = "";
  Transact({
    required this.uid,
    required this.transactId,
    required this.amount,
    required this.source,
    required this.transactMode,
    required this.description,
    required this.type,
    required this.date,
    required this.time,
    required this.bookId,
    required this.ts,
  });

  Transact copyWith({
    String? uid,
    String? transactId,
    String? amount,
    String? source,
    String? transactMode,
    String? description,
    String? type,
    String? date,
    String? time,
    String? bookId,
    String? ts,
  }) {
    return Transact(
      uid: uid ?? this.uid,
      transactId: transactId ?? this.transactId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      transactMode: transactMode ?? this.transactMode,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      bookId: bookId ?? this.bookId,
      ts: ts ?? this.ts,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'transactId': transactId,
      'amount': amount,
      'source': source,
      'transactMode': transactMode,
      'description': description,
      'type': type,
      'date': date,
      'time': time,
      'bookId': bookId,
      'ts': ts,
    };
  }

  factory Transact.fromMap(Map<String, dynamic> map) {
    return Transact(
      uid: map['uid'] as String,
      transactId: map['transactId'] as String,
      amount: map['amount'] as String,
      source: map['source'] as String,
      transactMode: map['transactMode'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      bookId: map['bookId'] as String,
      ts: map['ts'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transact.fromJson(String source) =>
      Transact.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Transact(uid: $uid, transactId: $transactId, amount: $amount, source: $source, transactMode: $transactMode, description: $description, type: $type, date: $date, time: $time, bookId: $bookId, ts: $ts)';
  }

  @override
  bool operator ==(covariant Transact other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.transactId == transactId &&
        other.amount == amount &&
        other.source == source &&
        other.transactMode == transactMode &&
        other.description == description &&
        other.type == type &&
        other.date == date &&
        other.time == time &&
        other.bookId == bookId &&
        other.ts == ts;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        transactId.hashCode ^
        amount.hashCode ^
        source.hashCode ^
        transactMode.hashCode ^
        description.hashCode ^
        type.hashCode ^
        date.hashCode ^
        time.hashCode ^
        bookId.hashCode ^
        ts.hashCode;
  }
}
