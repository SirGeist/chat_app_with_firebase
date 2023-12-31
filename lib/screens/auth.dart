import 'package:chat_app_with_firebase/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Possibily connected to validator argument
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;
  var _enteredUsername = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    // Invalid inputs means we immediately return
    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredientials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredientials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Uploading new image to firebase
        // .child('user_images') is a folder that firebase dives in
        // The jpg gets the uid that was created by firebase that we receive from the input
        // We are basically creating a new jpg that carries the uid of who the images belongs
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredientials.user!.uid}.jpg');

        // Returns an upload task
        await storageRef.putFile(_selectedImage!);

        // Gives us a url to display later in firebase
        final imageUrl = await storageRef.getDownloadURL();

        // Used to talk to the instance on the firestore website
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredientials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
        // Temporary
        // Plan to show image later, but for now making sure it works
        print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed.'),
        ),
      );

      // Resetting authenticating because if we get an error, the user will be able to
      // have access to the buttons
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              // Login/Signup widget for inserting user info
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // If you are logged in, a userimagepicker will be displayed
                          // otherwise, nothing will show
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          // Email address text form field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,

                            // Text validation
                            // Making sure value has no white space, null, or empty
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }

                              return null;
                            },

                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),

                          // If we are logging in, the below shouldn't be showing
                          // up
                          if (!_isLogin)
                            // Adding a username field for signing up
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              // Suggestions do not matter when creating a username
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter at least 4 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          // Password text form field
                          TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              obscureText: true,

                              // Minimum requirements for password
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              }),

                          const SizedBox(height: 12),

                          // If it is authenticating the info, display a spinning circle
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),

                          // If its not authenticating, display the buttons for signin/signup
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),

                              // If the button to create an account is pressed
                              // The text will change to signup
                              child: Text(_isLogin ? 'Login' : 'Signup'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },

                              // Pressing the button to change from login to signup
                              // and vice versa
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account. Login'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
