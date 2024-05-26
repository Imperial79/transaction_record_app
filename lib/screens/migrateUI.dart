import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';
import '../Utility/constants.dart';
import '../Utility/newColors.dart';

class MigrateUI extends StatefulWidget {
  const MigrateUI({Key? key}) : super(key: key);

  @override
  State<MigrateUI> createState() => _MigrateUIState();
}

class _MigrateUIState extends State<MigrateUI> {
  void fetch() async {
    int i = 1;
    await FirebaseFirestore.instance.collection("transactBooks").get().then(
      (value) {
        value.docs.forEach((book) async {
          final bookId = book.id;
          log(DateFormat('hh:mm a').format(DateTime.parse(bookId)));
          await FirebaseFirestore.instance
              .collection('transactBooks')
              .doc(bookId)
              .set({
            'bookId': bookId,
            'bookDescription': '',
            'bookName': 'Book$i',
            'date': DateFormat('MMM dd, yyyy').format(DateTime.parse(bookId)),
            'time': DateFormat('hh:mm a').format(DateTime.parse(bookId)),
            'type': 'regular',
            'uid': '6co5G5VbMfdVMuQCmPLW9sRO2x03',
            'income': 0,
            'expense': 0,
            'users': [],
          });
          i += 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                fetch();
              },
              child: Text('migrate'),
            ),
            Flexible(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('transactBooks')
                    .where('uid', isEqualTo: FirebaseRefs.myRef)
                    .snapshots(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) =>
                        Text(snapshot.data!.docs[index].data()['bookName']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
