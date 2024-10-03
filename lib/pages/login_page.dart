import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = TextEditingController();
  var _enteredPassword = TextEditingController();
  var passwordVisible = false;

  bool _isAuthenticating = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  void _login() async {
    UserCredential? userCredential;
    String email = _enteredEmail.text;
    String password = _enteredPassword.text;
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isAuthenticating = true;
    });
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential != null) {
        String uid = userCredential.user!.uid;
        UserModel user = UserModel(
          uid: uid,
          email: _enteredEmail.text,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen(userData: user);
            },
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication failed")));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _enteredEmail.dispose();
    _enteredPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 6, left: 6, bottom: 6),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              controller: _enteredEmail,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                } else if (!value.contains('@')) {
                  return 'Incorrect Mail ID';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  child: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText: passwordVisible ? false : true,
              controller: _enteredPassword,
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 7) {
                  return "insufficient length";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: _isAuthenticating
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
