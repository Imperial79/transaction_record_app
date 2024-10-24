import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:transaction_record_app/Components/WIdgets.dart';
import 'package:transaction_record_app/Repository/system_repository.dart';

import 'package:transaction_record_app/Utility/KScaffold.dart';
import 'package:transaction_record_app/Utility/constants.dart';
import 'package:transaction_record_app/Utility/newColors.dart';
import 'package:transaction_record_app/services/database.dart';

import '../../Repository/auth_repository.dart';
import '../../Utility/commons.dart';

class AccountUI extends ConsumerStatefulWidget {
  const AccountUI({super.key});

  @override
  ConsumerState<AccountUI> createState() => _AccountUIState();
}

class _AccountUIState extends ConsumerState<AccountUI> {
  //-------------------->
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  //------------------->

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final user = ref.read(userProvider);
        if (user != null) {
          nameController.text = user.name;
          emailController.text = user.email;
          setState(() {});
        }
      },
    );
  }

  updateAccountDetails(String uid) async {
    setState(() => isLoading = true);
    if (nameController.text.isNotEmpty) {
      Map<String, dynamic> accountMap = {
        'name': nameController.text,
      };

      await DatabaseMethods().updateAccountDetails(uid, accountMap);

      final userBox = await Hive.openBox("USERBOX");
      final userMap = userBox.get("userData");
      if (userMap != null) {
        userMap['userDisplayName'] = nameController.text;
        userBox.put('userData', userMap);
      }

      ref.read(userProvider.notifier).update(
            (state) => state!.copyWith(name: nameController.text),
          );

      KSnackbar(context, content: "Name Updated");
      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      KSnackbar(context, content: 'Please fill all the Fields', isDanger: true);
    }
  }

  //------------------------->
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(userProvider);

    return KScaffold(
      isLoading: isLoading,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  Text(
                    "v$kAppVersion",
                    style: TextStyle(),
                  ),
                ],
              ),
              height20,
              Hero(
                tag: 'profImg',
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user!.imgUrl),
                ),
              ),
              height10,
              Row(
                children: [
                  Icon(
                    Icons.tag,
                    color: isDark ? Dark.fadeText : Light.fadeText,
                  ),
                  width5,
                  Flexible(
                    child: Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Dark.fadeText : Light.fadeText,
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
                cursorWidth: 1,
                cursorColor: isDark ? Colors.white : Colors.black,
                decoration: InputDecoration(
                  focusColor: isDark ? Colors.white : Colors.black,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.white : Colors.black,
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey : Colors.grey.shade300,
                    ),
                  ),
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    fontSize: 25,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              height10,
              TextField(
                controller: emailController,
                enabled: false,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                cursorWidth: 1,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  focusColor: Colors.black,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              height20,
              kLabel("System Theme"),
              Row(
                children: [
                  _themeBtn(isDark, "Light"),
                  width10,
                  _themeBtn(isDark, "Dark"),
                  width10,
                  _themeBtn(isDark, "System"),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: MaterialButton(
            onPressed: () {
              updateAccountDetails(user.uid);
            },
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(12),
            ),
            elevation: 0,
            padding: EdgeInsets.zero,
            child: Ink(
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 25,
              ),
              decoration: BoxDecoration(
                borderRadius: kRadius(12),
                color: isDark ? Dark.primary : Light.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Update',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeBtn(bool isDark, String theme) {
    Color inactiveColor = isDark ? Dark.card : Light.card;
    Color inactiveBorderColor = isDark ? Dark.card : Light.card;
    Color activeColor =
        isDark ? Dark.primaryAccent.withOpacity(.3) : Light.primaryAccent;
    Color activeBorderColor = isDark ? Dark.primaryAccent : Light.primary;
    return Expanded(
      child: Consumer(
        builder: (context, ref, _) {
          final selectedTheme = ref.watch(themeProvider);
          bool isActive = selectedTheme == theme;

          return MaterialButton(
            onPressed: () async {
              ref.read(themeProvider.notifier).state = theme;
              var hiveBox = Hive.box("hiveBox");

              await hiveBox.put("theme", theme);
            },
            elevation: 0,
            highlightElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(7),
              side: BorderSide(
                color: isActive ? activeBorderColor : inactiveBorderColor,
              ),
            ),
            padding: EdgeInsets.all(15),
            color: isActive ? activeColor : inactiveColor,
            child: Text(theme),
          );
        },
      ),
    );
  }
}
