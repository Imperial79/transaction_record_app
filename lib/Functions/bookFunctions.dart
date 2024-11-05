//--------- DELETE BOOK--------------------------->
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Utility/commons.dart';

class BookMethods {
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

      KSnackbar(
        context,
        content: 'Book has been renamed to "$newBookName"!',
      );
    } catch (e) {
      KSnackbar(
        context,
        content:
            'Unable to rename book to "$newBookName"! Please try again after sometime',
        isDanger: true,
      );
    }

    Navigator.pop(context);
  }
}
