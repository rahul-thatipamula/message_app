import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/registration_page.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginState = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!isLoginState) {
                      setState(() {
                        isLoginState = true;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: isLoginState ? 22 : 18,
                          fontWeight: isLoginState
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isLoginState)
                        Container(
                          height: 3,
                          width: 60,
                          color: Colors.yellowAccent,
                        )
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                GestureDetector(
                  onTap: () {
                    if (isLoginState) {
                      setState(() {
                        isLoginState = false;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: isLoginState ? 18 : 22,
                          fontWeight: isLoginState
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      if (!isLoginState)
                        Container(
                          height: 3,
                          width: 60,
                          color: Colors.yellowAccent,
                        ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 1000) {
                    if (!isLoginState) {
                      setState(() {
                        isLoginState = true;
                      });
                    }
                  } else if (details.primaryVelocity! < -1000) {
                    if (isLoginState) {
                      setState(() {
                        isLoginState = false;
                      });
                    }
                  }
                }
              },
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: SizedBox(
                  // Add proper constraints here
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  child: isLoginState
                      ? const LoginPage(key: ValueKey('login'))
                      : const RegistrationPage(key: ValueKey('register')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
