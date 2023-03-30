// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twitterproject/component/checkweather.dart';
import 'package:twitterproject/component/searchpage.dart';
import 'package:twitterproject/component/tweetpage.dart';
import 'package:twitterproject/component/twitterdrawer.dart';
import 'package:twitterproject/database/users.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

bool _iconBool = false;
IconData _iconLight = Icons.wb_sunny_outlined;
IconData _iconDark = Icons.nights_stay_outlined;

ThemeData _light = ThemeData(
  primarySwatch: Colors.cyan,
  brightness: Brightness.light,
);

ThemeData _dark = ThemeData(
  primarySwatch: Colors.cyan,
  brightness: Brightness.dark,
);

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  int _tapIcon = 0;

  get userPost => null;
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _iconBool ? _dark : _light,
      home: Scaffold(
        appBar: AppBar(
          title: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Twitter-logo.svg/512px-Twitter-logo.svg.png?20220821125553',
            width: 30,
            height: 30,
            color: Colors.white,
          ),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: read(user.uid),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _iconBool = !_iconBool;
                });
              },
              icon: Icon(_iconBool ? _iconDark : _iconLight),
              color: Colors.white,
            ),
          ],
        ),
        drawer: TwitterDrawer(),
        body: Container(
          child: [
            TweetPage(),
            CheckWeather(),
            SearchPage(),
          ].elementAt(_tapIcon),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tapIcon,
          onTap: (int index) {
            setState(() {
              _tapIcon = index;
            });
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color: (_tapIcon == 0) ? Colors.blue : Colors.black,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                (FontAwesomeIcons.temperatureEmpty),
                color: (_tapIcon == 1) ? Colors.blue : Colors.black,
              ),
              label: "",
            ),
             BottomNavigationBarItem(
              icon: FaIcon(
                (FontAwesomeIcons.search),
                color: (_tapIcon == 2) ? Colors.blue : Colors.black, size: 20,
              ),
              label: "",
            ),
          ],
        ),
      ),
    );
  }

  Widget iconImgExist(img) => CircleAvatar(
        radius: 45,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => const Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );

  Widget buildUser(Users user) => CircleAvatar(
        radius: 45,
        child:
            (user.image != "-") ? iconImgExist(user.image) : iconImgNotExist(),
      );

  Widget read(uid) {
    var collection = FirebaseFirestore.instance.collection('Users');
    return Column(
      children: [
        SizedBox(
          height: 30,
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
}
