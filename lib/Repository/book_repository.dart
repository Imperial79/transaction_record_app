import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/models/transactModel.dart';

final transactListStream =
    StreamProvider.family<List<Transact>, String>((ref, data) {
  final body = jsonDecode(data);
  String bookId = body["bookId"];
  int bookCount = body["bookCount"];
  return FirebaseFirestore.instance
      .collection('transactBooks')
      .doc(bookId)
      .collection('transacts')
      .orderBy('ts', descending: true)
      .limit(bookCount)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Transact.fromMap(doc.data())).toList());
});

final bookRepository = Provider(
  (ref) => BookRepository(),
);

class BookRepository {
  Future<bool> createBook({
    required String bookId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(bookId)
          .set(data);

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
