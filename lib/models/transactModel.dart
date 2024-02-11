import 'package:cloud_firestore/cloud_firestore.dart';

class Transact {
  String? transactId;
  String? amount;
  String? source;
  String? transactMode;
  String? description;
  String? type;
  String? date;
  String? time;
  String? bookId;
  String? ts;

  Transact({
    this.amount,
    this.bookId,
    this.date,
    this.description,
    this.source,
    this.time,
    this.transactId,
    this.transactMode,
    this.ts,
    this.type,
  });

  factory Transact.fromMap(Map<String, dynamic> map) {
    return Transact(
      transactId: map['transactId'],
      amount: map['amount'],
      bookId: map['bookId'],
      date: map['date'],
      description: map['description'],
      source: map['source'],
      time: map['time'],
      transactMode: map['transactMode'],
      ts: map['ts'],
      type: map['type'],
    );
  }

  factory Transact.fromDocumentSnap(DocumentSnapshot map) {
    return Transact(
      transactId: map['transactId'],
      amount: map['amount'],
      bookId: map['bookId'],
      date: map['date'],
      description: map['description'],
      source: map['source'],
      time: map['time'],
      transactMode: map['transactMode'],
      ts: map['ts'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactId': transactId,
      "amount": amount,
      "source": source,
      "transactMode": transactMode,
      "description": description,
      "type": type,
      'date': date,
      'time': time,
      'bookId': bookId,
      'ts': ts,
    };
  }
}
