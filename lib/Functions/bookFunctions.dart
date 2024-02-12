//--------- DELETE BOOK--------------------------->
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';
import 'navigatorFns.dart';

class BookMethods {
  static Future<void> deleteBook(
    BuildContext context, {
    required String bookName,
    required String bookId,
  }) async {
    try {
      await DatabaseMethods().deleteBookWithCollections(bookId);

      ShowSnackBar(
        context,
        content: '"$bookName"' + ' book has been deleted!',
      );
    } catch (e) {
      ShowSnackBar(
        context,
        content:
            'Unable to delete book "$bookName"! Check your connection or try again after sometime.',
        isDanger: true,
      );
    }
  }

  static Future<void> editBookName(
    BuildContext context, {
    required String newBookName,
    required String bookId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactBooks')
          .doc(bookId)
          .update({'bookName': newBookName});

      ShowSnackBar(
        context,
        content: 'Book has been renamed to "$newBookName"!',
      );
    } catch (e) {
      ShowSnackBar(
        context,
        content:
            'Unable to rename book to "$newBookName"! Please try again after sometime',
        isDanger: true,
      );
    }

    Navigator.pop(context);
  }
}
