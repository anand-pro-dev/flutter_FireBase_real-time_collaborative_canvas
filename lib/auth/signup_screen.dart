import 'package:canvas_app/canvas/canvas_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../utils/snack_bar.dart';
import '../../widget/round_button.dart';
import '../screens/image_edit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  //
  final _formKey = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _pswd = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
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
                    const SizedBox(height: 100),
                    TextFormField(
                      controller: _email,
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
                    const SizedBox(height: 50),
                    SizedBox(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _pswd,
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
                    const SizedBox(height: 100),
                    RoundedButton(
                      loading: loading,
                      title: 'Sign Up',
                      onTap: () {
                        SignUp();
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void SignUp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      _auth
          .createUserWithEmailAndPassword(
              email: _email.text.trim().toString(),
              password: _pswd.text.toString().trim())
          .then((value) {
        setState(() {
          loading = false;
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CanvasScreen()));
      }).onError(
        (error, stackTrace) {
          setState(() {
            loading = false;
          });
          Utils().snackBar(error.toString(), context);
        },
      );
    }
  }
}
