import 'package:flutter/material.dart';
import './mainRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globalVars.dart' as globals;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final userRef = Firestore.instance.collection('users');
  final _formKey = GlobalKey<FormState>();
  final passwordFormController = TextEditingController();
  final userNameFormController = TextEditingController();
  var loginFailed = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: userNameFormController,
            decoration: const InputDecoration(
              hintText: 'Enter username',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          TextFormField(
            controller: passwordFormController,
            decoration: const InputDecoration(
              hintText: 'Enter password',
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            obscureText: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  // Process data.
                  handleLogin();
                }
              },
              child: Text('Login'),
            ),
          ),
          Text((() {
            if (loginFailed) {
              return "Invalid username and password combination! Try again.";
            }
            return "";
          })())
        ],
      ),
    );
  }

  handleLogin() {
    userRef
        .where("username", isEqualTo: userNameFormController.text)
        .where("password", isEqualTo: passwordFormController.text)
        .snapshots()
        .listen((data) {
      if (data.documents.length > 0) {
        print("logged in as " + data.documents[0]["username"]);
        globals.currentUser = data.documents[0]["username"];
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MainRoute()));
        loginFailed = false;
      } else {
        setState(() {
          loginFailed = true;
        });
      }
    });
  }
}
