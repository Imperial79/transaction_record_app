import 'package:flutter/material.dart';

import '../Utility/commons.dart';
import '../Utility/newColors.dart';
import '../models/userModel.dart';

Widget kBackButton(
  context, {
  bool isSearching = false,
}) {
  isDark = Theme.of(context).brightness == Brightness.dark;
  return IconButton(
    color: isDark ? Dark.profitText : Light.profitText,
    onPressed: () {
      Navigator.pop(context);
    },
    icon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_back,
          color: isDark ? Dark.profitCard : Colors.black,
        ),
        !isSearching ? width10 : const SizedBox(),
        !isSearching
            ? Text(
                'Return',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

Padding kUserTile(
  bool isDark, {
  required List selectedUsers,
  required UserModel userData,
  required bool isSelecting,
  void Function()? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: InkWell(
      onTap: onTap,
      borderRadius: kRadius(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: kRadius(15),
          color: selectedUsers.contains(userData.uid)
              ? isDark
                  ? Dark.profitCard.withOpacity(.6)
                  : Light.profitCard
              : Colors.transparent,
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            selectedUsers.contains(userData.uid)
                ? const CircleAvatar(
                    child: Icon(Icons.done),
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(userData.imgUrl),
                  ),
            width20,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userData.name),
                  Text(userData.username),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget kLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 15),
    child: Text(
      text,
    ),
  );
}

Widget kAlertDialog(
  bool isDark, {
  required String title,
  required String subTitle,
  Widget? content,
  required List<Widget> actions,
}) {
  return Dialog(
    elevation: 0,
    backgroundColor: isDark ? Dark.card : Light.card,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          height15,
          Text(
            subTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: content,
            ),
          height15,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ],
      ),
    ),
  );
}
