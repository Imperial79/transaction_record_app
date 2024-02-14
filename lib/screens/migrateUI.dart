import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/customScaffold.dart';

import '../Utility/colors.dart';
import '../Utility/constants.dart';
import '../services/user.dart';

class MigrateUI extends StatefulWidget {
  const MigrateUI({Key? key}) : super(key: key);

  @override
  State<MigrateUI> createState() => _MigrateUIState();
}

class _MigrateUIState extends State<MigrateUI> {
  void step1() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(globalUser.uid)
        .collection('transact_books')
        .orderBy('bookId', descending: true)
        .get()
        .then((snapshot) {
      // log(snapshot.docs.length.toString());
      snapshot.docs.forEach((book) async {
        // log("${element.data()['bookId']}");
        String bookId = book.data()['bookId'];
        Map<String, dynamic> newMap = {};
        newMap = book.data();
        newMap['uid'] = globalUser.uid;

        print(newMap);
        await FirebaseFirestore.instance
            .collection('transactBooks')
            .doc(bookId)
            .set(newMap);
        // ---------------------------->

        await FirebaseFirestore.instance
            .collection('users')
            .doc(globalUser.uid)
            .collection('transact_books')
            .doc(bookId)
            .collection('transacts')
            .get()
            .then((data) {
          data.docs.forEach((transact) async {
            log("$bookId-> ${transact.data()['transactMode']}");
            Map<String, dynamic> newTr = transact.data();
            newTr['uid'] = globalUser.uid;
            log('$newTr');
            await FirebaseFirestore.instance
                .collection('transactBooks')
                .doc(bookId)
                .collection('transacts')
                .add(newTr);
          });
        });
      });
      // if (snapshot.data() != null) log(snapshot.data()!['bookName']);
    });
  }

  void step2(String bookId) async {}
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    return KScaffold(
      body: SafeArea(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              step1();
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
      )),
    );
  }
}
