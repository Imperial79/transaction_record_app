import 'package:flutter/material.dart';
import 'package:transaction_record_app/services/auth.dart';

class HomeMenuUI extends StatefulWidget {
  const HomeMenuUI({Key? key}) : super(key: key);

  @override
  State<HomeMenuUI> createState() => _HomeMenuUIState();
}

class _HomeMenuUIState extends State<HomeMenuUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HomeMenuBtn(
                onPress: () {
                  print('object');
                },
                label: 'Account',
                icon: Icon(Icons.person, color: Colors.blue.shade700),
                btnColor: Colors.blue.withOpacity(0.12),
                textColor: Colors.black,
              ),
              HomeMenuBtn(
                onPress: () {
                  AuthMethods().signOut(context);
                },
                label: 'Logout',
                icon: Icon(Icons.logout, color: Colors.red),
                btnColor: Colors.red.withOpacity(0.12),
                textColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget HomeMenuBtn(
      {required VoidCallback onPress, final label, icon, btnColor, textColor}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: onPress,
            icon: icon,
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
