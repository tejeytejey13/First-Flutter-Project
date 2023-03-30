// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:twitterproject/crudpage/updatepost.dart';
import 'package:twitterproject/crudpage/updateprofile.dart';
import 'package:twitterproject/database/post.dart';
import 'package:twitterproject/database/users.dart';
import 'package:twitterproject/screen/home.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          Header(),
          read(user.uid),
          tabsContainer(size),
        ],
      ),
    );
  }

  Widget iconImgExist(img) => CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(img),
      );

  Widget iconImgNotExist() => Icon(
        Icons.account_circle_outlined,
        color: Colors.grey,
      );

  Widget Header() => Stack(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/twitter-logo1.png',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ));
                },
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white60,
                ),
              ),
            ),
          )
        ],
      );

  Widget tabsContainer(Size size) => Stack(
        children: [
          Container(
            height: size.height * 5,
            width: double.infinity,
            child: tabs(size),
          )
        ],
      );

  Widget tabs(Size size) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 100,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: size * 0.10,
              child: SafeArea(
                // ignore: prefer_const_literals_to_create_immutables
                child: Column(
                  children: const [
                    TabBar(
                      unselectedLabelColor: Colors.black,
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(width: 3, color: Colors.blue),
                          insets: EdgeInsets.symmetric(horizontal: 3)),
                      labelColor: Colors.blue,
                      isScrollable: true,
                      tabs: [
                        Text(
                          'Tweets',
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(
                          'Media',
                          style: TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                    Divider(
                      height: 1,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                Column(
                  children: [
                    fetchtweets(),
                  ],
                ),
                Column(
                  children: [
                    fetchMedia(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget newpost(Post userpost) => GestureDetector(
        onTap: () {
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TweetView(
                userPost: userpost,
              ),
            ),
          );*/
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            tweets(userpost),
            newbuttons(userpost),
            Divider()
          ],
        ),
      );

  Widget tweets(Post userpost) => Stack(
        children: [
          readTweets(user.uid),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 40, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(userpost.postcontent),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  child: (userpost.postimg != "-")
                      ? imgExist(userpost.postimg)
                      : imgNotExist(),
                ),
              ],
            ),
          ),
        ],
      );

  Widget mediapost(Post userpost) => GestureDetector(
        onTap: () {
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TweetView(
              
              ),
            ),
          );*/
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            mtweets(userpost),
            newbuttons(userpost),
            Divider()
          ],
        ),
      );

  Widget mtweets(Post userpost) => Stack(
        children: [
          readTweets(user.uid),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 40, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: (userpost.postimg != "-")
                      ? imgExist(userpost.postimg)
                      : imgNotExist(),
                ),
              ],
            ),
          ),
        ],
      );

  Widget buildTweets(Users user) => Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.white,
                      child: (user.image != "-")
                          ? iconImgExist(user.image)
                          : iconImgNotExist(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  Widget readTweets(uid) {
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

                return buildTweets(newUser);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget imgExist(img) => Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(img),
            fit: BoxFit.fill,
          ),
        ),
      );

  Widget imgNotExist() => const Icon(
        Icons.account_circle_rounded,
        size: 40,
      );

  Widget newbuttons(Post userpost) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 65),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  style: TextButton.styleFrom(
                    primary: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: const FaIcon(FontAwesomeIcons.edit, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePost(
                          userPost: userpost,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      primary: (!userpost.isLiked) ? Colors.grey : Colors.red,
                      splashFactory: NoSplash.splashFactory),
                  onPressed: () {
                    setState(() {
                      if (!userpost.isLiked) {
                        userpost.isLiked = true;
                        updateLike(userpost.post_id, true);
                      } else {
                        userpost.isLiked = false;
                        updateLike(userpost.post_id, false);
                      }
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.heart, size: 20),
                  label: Text(""),
                ),
                IconButton(
                  style: TextButton.styleFrom(
                    primary: Colors.grey,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    _showActionSheet(context, userpost.post_id);
                  },
                  icon: const FaIcon(FontAwesomeIcons.trashAlt, size: 20),
                ),
              ],
            ),
          ),
          const Divider()
        ],
      );

  updateLike(String id, bool status) {
    final docUser = FirebaseFirestore.instance.collection('Post').doc(id);
    docUser.update({
      'isLiked': status,
    });
  }

  Widget fetchtweets() {
    return StreamBuilder<List<Post>>(
      stream: readUserPost(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final users = snapshot.data!;

          return ListView(
            shrinkWrap: true,
            children: users.map(newpost).toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget fetchMedia() {
    return StreamBuilder<List<Post>>(
      stream: readUserPost(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        } else if (snapshot.hasData) {
          final users = snapshot.data!;

          return ListView(
            shrinkWrap: true,
            children: users.map(mediapost).toList(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Stream<List<Post>> readUserPost(id) => FirebaseFirestore.instance
      .collection('Post')
      .where('id', isEqualTo: id)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Post.fromJson(
                doc.data(),
              ),
            )
            .toList(),
      );

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

  deleteUser(String id) {
    final docUser = FirebaseFirestore.instance.collection('Post').doc(id);
    docUser.delete();
    Navigator.pop(context);
    MotionToast(
      //Duration(seconds: 3),
      primaryColor: Colors.redAccent,
      description: Text("Tweet Successfully deleted"),
      icon: Icons.delete,
      enableAnimation: true,
    ).show(context);
  }

  Widget buildUser(Users user) => Container(
        transform: Matrix4.translationValues(0.0, -40.0, 0.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: (user.image != "-")
                        ? iconImgExist(user.image)
                        : iconImgNotExist(),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 0.0,
                    onPrimary: Colors.black,
                    side: BorderSide(color: Colors.blueGrey.shade300),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfile(
                            user: user,
                          ),
                        ));
                  },
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              user.bio,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 15,
                ),
                Text(
                  user.birthdate,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.location_on_outlined,
                  size: 15,
                ),
                Text(
                  user.location,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: const [
                Text(
                  '90',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Following',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '100',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Followers',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
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
}
