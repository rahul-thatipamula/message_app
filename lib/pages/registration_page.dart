import 'dart:io';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _enteredEmail = TextEditingController();
  final _enteredPassword = TextEditingController();
  final _enteredUsername = TextEditingController();

  File? _image;
  bool isAuthenticating = false;
  bool passwordVisible = false;

  @override
  void dispose() {
    _enteredEmail.dispose();
    _enteredPassword.dispose();
    _enteredUsername.dispose();
    super.dispose();
  }

  // Method to select an image from the camera or gallery
  Future<void> selectImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Method to show a dialog for selecting image source
  void uploadImage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to handle user registration
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isAuthenticating = true;
    });

    try {
      if (_image == null) {
        throw Exception('Please select an image before uploading');
      }

      UserCredential cUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _enteredEmail.text.trim(),
        password: _enteredPassword.text.trim(),
      );

      UploadTask uploadTask = FirebaseStorage.instance
          .ref('profile_pics')
          .child(cUser.user!.uid)
          .putFile(_image!);

      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      String uid = cUser.user!.uid;
      UserModel user = UserModel(
        uid: uid,
        email: cUser.user!.email!,
        fullname: _enteredUsername.text.trim(),
        profilePic: imageUrl,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the home screen after successful registration
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen(userData: user);
            },
          ),
        );
        ;
      }
    } on FirebaseAuthException catch (error) {
      String errorMessage = "Authentication failed.";
      if (error.code == 'email-already-in-use') {
        errorMessage += ' The email is already registered.';
      } else if (error.code == 'weak-password') {
        errorMessage += ' The password is too weak.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CupertinoButton(
              onPressed: uploadImage,
              child: CircleAvatar(
                radius: 50,
                child: _image == null ? const Icon(Icons.person) : null,
                backgroundImage: _image != null ? FileImage(_image!) : null,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
              controller: _enteredUsername,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Invalid username';
                } else if (value.length < 7) {
                  return 'Length should be greater than 7';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              controller: _enteredEmail,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                } else if (!value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !passwordVisible,
              controller: _enteredPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 8) {
                  return 'Password should be at least 8 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            isAuthenticating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Register'),
                  ),
          ],
        ),
      ),
    );
  }
}
