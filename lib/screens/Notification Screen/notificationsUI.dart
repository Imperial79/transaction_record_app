import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transaction_record_app/Repository/auth_repository.dart';
import 'package:transaction_record_app/Utility/components.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/newColors.dart';

import '../../Utility/commons.dart';

class NotificationsUI extends ConsumerStatefulWidget {
  const NotificationsUI({super.key});

  @override
  ConsumerState<NotificationsUI> createState() => _NotificationsUIState();
}

class _NotificationsUIState extends ConsumerState<NotificationsUI> {
  bool isLoading = false;

  Future<void> _addToBook({
    required String uid,
    required String bookId,
    required String bookName,
    required String requestId,
  }) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseRefs.transactBookRef(bookId).get().then((book) async {
        if (book.exists) {
          await FirebaseRefs.transactBookRef(bookId).update({
            'users': FieldValue.arrayUnion([uid])
          }).then((value) async {
            await _removeFromRequest(uid: uid, requestId: requestId).then(
              (value) => KSnackbar(
                context,
                content: "\"$bookName\" Book joined successfully!",
              ),
            );
          });
        } else {
          KSnackbar(
            context,
            content: "Book does not exists anymore!",
            isDanger: true,
          );
          await _removeFromRequest(uid: uid, requestId: requestId);
        }
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      KSnackbar(context, content: "Something went wrong!", isDanger: true);
    }
  }

  Future<void> _removeFromRequest(
      {required String uid, required String requestId}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseRefs.requestRef.doc(requestId).get().then((value) async {
        if (value.data()!['users'].length == 1 &&
            value.data()!['users'].contains(uid)) {
          await FirebaseRefs.requestRef.doc(requestId).delete();
        } else {
          await FirebaseRefs.requestRef.doc(requestId).update({
            'users': FieldValue.arrayRemove([uid]),
          }).then(
            (value) => KSnackbar(
              context,
              content: 'Request Rejected!',
            ),
          );
        }
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      KSnackbar(
        context,
        content: "Something went wrong!",
        isDanger: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);
    return KScaffold(
      isLoading: isLoading,
      appBar: AppBar(
        backgroundColor: isDark ? Dark.scaffold : Light.scaffold,
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: StreamBuilder(
            stream: FirebaseRefs.requestRef
                .where('users', arrayContains: user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: snapshot.hasData
                    ? snapshot.data!.docs.isEmpty
                        ? NoData(context, customText: 'No Notifications Yet')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Recent Notifications'),
                              height10,
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> data =
                                      snapshot.data!.docs[index].data();
                                  return _notificationCard(
                                    isDark,
                                    uid: user.uid,
                                    data: data,
                                  );
                                },
                                separatorBuilder: (context, index) => height10,
                              ),
                            ],
                          )
                    : snapshot.hasError
                        ? const Text('Has Error')
                        : _dummyNotificationsCard(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dummyNotificationsCard() {
    return const Card(
      child: SizedBox(
        height: 150,
        width: double.infinity,
      ),
    );
  }

  Widget _notificationCard(
    bool isDark, {
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: kRadius(15),
        color: isDark ? Dark.card : Light.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<dynamic>(
            future: FirebaseRefs.userRef.doc(data['senderId']).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() != null) {
                  return _notificationCardHeader(data: snapshot.data.data());
                }
              }
              return Transform.scale(
                scale: .5,
                child: const CircularProgressIndicator(),
              );
            },
          ),
          height10,
          Text(
            'Join my book "${data['bookName']}" so that we can share the expense details!',
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          height10,
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _addToBook(
                    uid: uid,
                    bookId: data['bookId'],
                    bookName: data['bookName'],
                    requestId: data['id'],
                  );
                },
                child: const Text('Accept'),
              ),
              width10,
              ElevatedButton(
                onPressed: () async {
                  await _removeFromRequest(
                    uid: uid,
                    requestId: data['id'],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Dark.lossCard : Light.lossCard,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _notificationCardHeader({dynamic data}) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(data['imgUrl']),
        ),
        width10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["name"] ?? "User",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(data["username"] ?? 'username'),
            ],
          ),
        ),
      ],
    );
  }
}
