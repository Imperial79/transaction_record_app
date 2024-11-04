import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/models/bookModel.dart';

import '../models/transactModel.dart';

final transactListProvider = StateProvider.autoDispose<List<Transact>>(
  (ref) => [],
);
final bookListProvider = StateProvider<List<BookModel>>(
  (ref) => [],
);

final bookCountProvider = StateProvider<int>(
  (ref) => 5,
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

final bookListStream = StreamProvider.autoDispose<List<BookModel>>((ref) {
  String uid = ref.read(userProvider)!.uid;
  int bookCount = ref.read(bookCountProvider);
  return FirebaseFirestore.instance
      .collection('transactBooks')
      .where(
        Filter.or(
          Filter(
            'users',
            arrayContains: uid,
          ),
          Filter('uid', isEqualTo: uid),
        ),
      )
      .orderBy('createdAt', descending: true)
      .limit(bookCount)
      .snapshots()
      .map((snapshot) {
    List<BookModel> data =
        snapshot.docs.map((doc) => BookModel.fromMap(doc.data())).toList();
    ref.read(bookListProvider.notifier).state = data;
    return data;
  });
});

final bookdataStream = StreamProvider.family<BookModel, String>((ref, bookId) {
  return FirebaseFirestore.instance
      .collection('transactBooks')
      .doc(bookId)
      .snapshots()
      .map((snapshot) {
    return BookModel.fromMap(snapshot.data()!);
  });
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
