import 'package:flutter/material.dart';
import 'package:transaction_record_app/Utility/components.dart';

import '../Utility/newColors.dart';
import '../models/userModel.dart';

Widget kBackButton(
  context, {
  bool isSearching = false,
}) {
  isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    child: IconButton(
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
          !isSearching ? width10 : SizedBox(),
          !isSearching
              ? Text(
                  'Return',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                )
              : SizedBox(),
        ],
      ),
    ),
  );
}

Padding kUserTile(
  bool isDark, {
  required List selectedUsers,
  required KUser userData,
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
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            selectedUsers.contains(userData.uid)
                ? CircleAvatar(
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
    padding: EdgeInsets.only(top: 20, bottom: 15),
    child: Text(
      text,
    ),
  );
}
