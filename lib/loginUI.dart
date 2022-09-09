import 'package:flutter/material.dart';
import 'package:transaction_record_app/colors.dart';
import 'package:transaction_record_app/services/auth.dart';

class LoginUI extends StatefulWidget {
  LoginUI({Key? key}) : super(key: key);

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Transact Record',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Your Personal Money manager',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '#OpenSource',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF04C282),
                        fontWeight: FontWeight.w800,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.backup,
                    color: primaryColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      'SYNC YOUR DATA ON TRANSACT CLOUD',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(22),
                splashColor: Colors.red,
                onTap: () {
                  AuthMethods().signInWithgoogle(context);
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink,
                        Colors.pink.shade200,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 6,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Login with Google",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'By signing in, you agree with our ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextLink(
                      text: 'Terms and Conditions',
                      link: 'Terms and Conditions',
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
                  Expanded(
                    child: TextLink(
                      text: 'Privacy Policy',
                      link: 'Privacy Policy',
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget TextLink({final text, link, alignment}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: alignment,
        color: Colors.transparent,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
