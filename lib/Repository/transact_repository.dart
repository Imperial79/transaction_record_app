import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/models/transactModel.dart';

final transactListProvider = StateProvider.autoDispose<List<Transact>>(
  (ref) => [],
);
final transactListStream =
    StreamProvider.family<List<Transact>, String>((ref, data) {
  final body = jsonDecode(data);
  String bookId = body["bookId"];
  int count = body["count"];
  return FirebaseFirestore.instance
      .collection('transactBooks')
      .doc(bookId)
      .collection('transacts')
      .orderBy('ts', descending: true)
      .limit(count)
      .snapshots()
      .map((snapshot) {
    List<Transact> data =
        snapshot.docs.map((doc) => Transact.fromMap(doc.data())).toList();
    ref.read(transactListProvider.notifier).state = data;
    return data;
  });
});
