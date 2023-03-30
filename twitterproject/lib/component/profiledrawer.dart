// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitterproject/database/users.dart';

class ProfileDrawer extends StatelessWidget {
  final int following;
  final int followers;

  const ProfileDrawer({
    super.key,
    required this.following,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          read(user),
        ],
      ),
    );
  }

  Widget buildUser(Users user) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 43,
              backgroundColor: Colors.white,
              child: (user.image != "-")
                  ? iconImgExist(user.image)
                  : iconImgNotExist(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Expanded(child: Text(user.email)),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  following.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    'Following',
                    style: TextStyle(letterSpacing: 1),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  following.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    'Followers',
                    style: TextStyle(letterSpacing: 1),
                  ),
                ),
              ],
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
                    image: users['image']);

                return buildUser(newUser);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget iconImgExist(img) => CircleAvatar(
        radius: 43,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );
}
