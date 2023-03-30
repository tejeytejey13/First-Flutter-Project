import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:twitterproject/screen/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // void showAlert() {
  //
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.success,
  //     text: "Successfully log in",
  //   );
  // }

  final formKey = GlobalKey<FormState>();

  late TextEditingController usernamecontroller;
  late TextEditingController passwordcontroller;
  late String error;

  @override
  void initState() {
    usernamecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    error = "";
    super.initState();
  }

  @override
  void dispose() {
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/512px-Twitter-logo.svg.png?20220821125553',
          width: 30,
          height: 30,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 50, 0, 0),
                  child: Text(
                    "See what's happening in the world right now.",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50, 50, 50, 30),
                  child: Text(
                    'To get started, first enter your email address and password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 45,
                vertical: 10,
              ),
              child: TextFormField(
                validator: (value) {
                  if (value != null && value.length < 1) {
                    return 'Please Enter Email Address';
                  } else {
                    return null;
                  }
                },
                controller: usernamecontroller,
                // ignore: prefer_const_constructors
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter your email address',
                  //icon: Icon(Icons.supervised_user_circle),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 45,
                vertical: 10,
              ),
              child: TextFormField(
                validator: (value) {
                  if (value != null && value.length < 1) {
                    return 'Please Enter Password';
                  } else {
                    return null;
                  }
                },
                obscureText: true,
                controller: passwordcontroller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your password',
                  //icon: Icon(Icons.key),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(45.5, 15, 45.5, 60),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    signIn();
                  } else {}
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: Icon(Icons.login_outlined),
                label: const Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register(),
                        ));
                  },
                  icon: const Icon(
                    Icons.app_registration_outlined,
                    size: 24.0,
                  ),
                  label: const Text('Create Account'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernamecontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      setState(() {
        Navigator.pop(context);
        MotionToast(
          //Duration(seconds: 3),
          primaryColor: Colors.green,
          description: Text("Successfully login"),
          icon: Icons.check_circle_outline_outlined,
          enableAnimation: true,
        ).show(context);
        Fluttertoast.showToast(msg: "Login Successfully");

        error = "";
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.toString().contains('user-not-found')) {
        setState(() {
          error = 'User not Found';
        });
      }
      if (e.toString().contains('wrong-password')) {
        setState(() {
          error = 'Wrong Password';
        });
      }
    }
    Navigator.pop(context);
  }
}
