// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:twitterproject/database/users.dart';
import 'package:twitterproject/screen/login.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Account Information'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(120, 10, 0, 5),
            child: Text(
              "Scroll to see delete button",
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
          Icon(
            Icons.arrow_downward,
            color: Colors.red,
          ),
          SizedBox(
            height: 5,
          ),
          read(user.uid),
        ],
      ),
    );
  }

  Widget buildUser(Users user) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Divider(),
                SizedBox(height: 10),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.location,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Divider(),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              _showActionSheet(context, user.id);
            },
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 24.0,
            ),
            label: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );

  Widget read(uid) {
    var collection = FirebaseFirestore.instance.collection('Users');
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: collection.doc(uid).snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) return Text('Error = ${snapshot.error}');

              if (snapshot.hasData) {
                final users = snapshot.data!.data();
                final newUser = Users(
                  id: users!['id'],
                  name: users['name'],
                  username: users['username'],
                  password: users['password'],
                  email: users['email'],
                  bio: users['bio'],
                  location: users['location'],
                  birthdate: users['birthdate'],
                  age: users['age'],
                  image: users['image'],
                );

                return buildUser(newUser);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Stream<List<Users>> readUsers() =>
      FirebaseFirestore.instance.collection('Users').snapshots().map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => Users.fromJson(
                    doc.data(),
                  ),
                )
                .toList(),
          );

  deleteUser(String id) {
    final docUser = FirebaseFirestore.instance.collection('Users').doc(id);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: "Successfully registered",
    );
    docUser.delete();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
  }

  void _showActionSheet(BuildContext context, String id) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirmation'),
        message: const Text(
            'Are you sure you want to delete this user? Doing this will not undo any changes.'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              deleteUser(id);
            },
            child: const Text('Continue'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
