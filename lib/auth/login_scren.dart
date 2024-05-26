import 'package:canvas_app/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widget/round_button.dart';
import '../canvas/canvas_room.dart';
import '../screens/image_edit.dart';

import '../utils/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //
  final _auth = FirebaseAuth.instance;
  //
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController pswd = TextEditingController();

  bool loginLoading = false;
  //
  void login() async {
    setState(() {
      loginLoading = true;
    });
    _auth
        .signInWithEmailAndPassword(
            email: email.text.toString(), password: pswd.text.toString())
        .then((value) {
      setState(() {
        loginLoading = false;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CanvasScreen()));
      // Utils().snackBar(value.user.toString(), context);
    }).onError((error, stackTrace) {
      setState(() {
        loginLoading = false;
      });
      Utils().snackBar(error.toString(), context);
    });
  }

  @override
  void dispose() {
    email.dispose();
    pswd.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("log in"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(
                        helperText: "enter the email",
                        hintText: " Email",
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: pswd,
                        decoration: const InputDecoration(
                          helperText: "enter the Passward",
                          hintText: " Passward",
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedButton(
                      loading: loginLoading,
                      title: 'Login',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    RoundedButton(
                        title: "Sign Up",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpScreen()));
                        }),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
