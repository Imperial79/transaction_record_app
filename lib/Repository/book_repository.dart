import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/models/bookModel.dart';

final bookListProvider = StateProvider<List<BookModel>>(
  (ref) => [],
);

final bookCountProvider = StateProvider<int>(
  (ref) => 5,
);

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

  Future<bool> updateBook({
    required String bookId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(bookId)
          .update(data);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBook({required String bookId}) async {
    try {
      // Reference to the book document
      DocumentReference bookDocRef =
          FirebaseFirestore.instance.collection('transactBooks').doc(bookId);

      // Reference to the nested transacts collection
      CollectionReference transactsCollectionRef =
          bookDocRef.collection('transacts');

      // Function to delete all documents in a collection
      Future<void> deleteAllDocumentsInCollection(
          CollectionReference collectionRef) async {
        // Get all documents in the collection
        final querySnapshot = await collectionRef.get();
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete(); // Delete each document
        }
      }

      // Delete all documents in the transacts collection
      await deleteAllDocumentsInCollection(transactsCollectionRef);

      // Now delete the book document itself
      await bookDocRef.delete();
      log("Book and its transacts deleted successfully.");
      return true;
    } catch (e) {
      log("Error deleting book and transacts: $e");
      rethrow;
    }
  }
}
